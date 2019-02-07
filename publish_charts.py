# -*- coding: utf-8 -*-

"""
WARNING! This only works on PUBLIC repos - there doesn't
appear to be an endpoint for getting project uploads without
having authenticated using user/password on the website

Quick script to publish a Kubernetes Helm chart repo index.yaml file to a given path
from a Gitlab repositories tag description files, for semver tagged commits

When Gitlab releases 11.8, this will be migrated to Release Links

The script optionally downloads and copies the released chart .tgz files to a directory,
or can simply include URLs to the files on Gitlab

This can be used with Gitlab pages to create a complete Gitlab-centric Chart Repo

It can keep the entire history or only the last X releases
"""

import os
import re
import sys
import logging
import argparse
import tempfile
import subprocess
import pathlib
from distutils.dir_util import copy_tree
import shutil
from urllib.parse import quote, urlparse

import semver
import gitlab
from ruamel import yaml
import requests

logging.basicConfig(level=os.environ.get('LOG_LEVEL', logging.INFO))

CHART_GLOB = '*/Chart.yaml'

def publish_charts(args):
    uri = urlparse(args.project_url)
    server = f'{uri.scheme}://{uri.netloc}'
    project_id = quote(uri.path[1:], safe='')
    gl = gitlab.Gitlab(server, private_token=args.private_token, timeout=args.timeout,
                       ssl_verify=args.ssl_verify)
    project = gl.projects.get(project_id)

    tags = []
    # FIXME: use search when it comes out in 11.8
    # Guarantee semver ordering
    for tag in project.tags.list():
        try:
            sv = semver.parse_version_info(tag.name)
            pre = sv.prerelease or sv.build
            if args.prereleases or not pre:
                tags.append(sv)
        except:
            logging.debug(f"{tag.name} is not semver compliant, skipping")

    sorted_tags = sorted(tags) if not args.max_releases else sorted(tags, reverse=True)[:args.max_releases]
    entries = {}
    with tempfile.TemporaryDirectory() as dname:
        # write all the files in the tags to a tempdir
        for sv in sorted_tags:
            try:
                tag_desc = project.tags.get(str(sv)).release['description']
                url_segment = re.search(f'.+\((\/uploads\/\w+\/{args.chart_name}-\d\.\d\.\d\.tgz)\)', tag_desc)[1]
            except:
                logging.exception(f'Tag {sv} has an invalid description, stopping')
                exit(1)

            filename = url_segment[url_segment.rfind("/") + 1:]
            full_url = args.project_url + url_segment
            entries[filename] = full_url
            logging.debug(f'Getting {filename} from {full_url}')
            r = requests.get(full_url, stream=True)
            with open(os.path.join(dname, filename), 'wb') as f:
                for chunk in r:
                    f.write(chunk)

        # use the helm binary to generate the index file and copy to dir
        helm_command = ["helm", "repo", "index", dname]
        if args.base_url:
            helm_command = helm_command + ['--url', args.base_url]
        helm = subprocess.run(helm_command, check=True)
        index_yaml_path = os.path.join(dname, 'index.yaml')
        if args.base_url:
            copy_tree(dname, args.output_dir)
        else:
            # Replace the filename with a url to the Gitlab upload
            with open(index_yaml_path) as yamlf:
                # index_yaml = yaml.load(yamlf)
                index_yaml = yaml.load(yamlf, Loader=yaml.RoundTripLoader)

            logging.debug(f'Got \n\n{index_yaml}\n\nAs the contents of index_yaml')
            if not index_yaml['entries']:
                print('There are no semver compatible tags in the repo, nothing to do')
                exit(0)

            for rel in index_yaml['entries'][args.chart_name]:
                rel['urls'] = [entries[rel['urls'][0]]]

            with open(index_yaml_path, 'w') as yamlf:
                yaml.dump(index_yaml, yamlf, default_flow_style=False, Dumper=yaml.RoundTripDumper)

            shutil.copy2(index_yaml_path, args.output_dir)

def main():

    parser = argparse.ArgumentParser(description='Upload files to gitlab tag (release)')
    parser.add_argument('--project_url', default=None
                        , help='Full url of the project on the gitlab server or $CI_PROJECT_URL')
    parser.add_argument('--chart_name', default=None, help='Chart name or $CI_PROJECT_NAME')
    parser.add_argument('--timeout', type=int, default=120, help='Timeout for http requests')
    parser.add_argument('--ssl_verify', action="store_false", help='Verify SSL certificates')
    parser.add_argument('--max_releases', type=int, default=0, help='Default: 0 = unlimited')
    parser.add_argument('--prereleases', action="store_true",
                        help="Default: False. Publish prerelease/build releases")
    parser.add_argument('--base_url', default=None,
                        help='If present, copy .tgz files to output_dir instead of using upload links')
    parser.add_argument('private_token', help='login token with permissions to commit to repo')
    parser.add_argument('output_dir',
                        help='The directory to output the index.yaml file and optionally .tgz files')

    args = parser.parse_args()

    args.project_url = args.project_url or os.environ.get('CI_PROJECT_URL')
    if not args.project_url:
        print("Must provide --project_url if not running from CI")
        exit(1)
    logging.debug(f'Using {args.project_url} for value "project_url"')

    args.chart_name = args.chart_name or os.environ['CI_PROJECT_NAME']
    if not args.chart_name:
        print("Must provide --chart_name if not running from CI")
        exit(1)

    if os.path.isfile(args.output_dir):
        print(f"{args.output_dir} points to an existing file, please provide a directory")
        exit(1)
    pathlib.Path(args.output_dir).mkdir(parents=True, exist_ok=True)
    logging.debug(f'Attempting to publish tagged chart versions from {args.project_url} to {args.output_dir}')

    # FIXME: check for base_url

    publish_charts(args)

    logging.info(f'Published tagged chart versions from {args.project_url} to {args.output_dir}')

if __name__ == '__main__':
    main()
