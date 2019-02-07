# -*- coding: utf-8 -*-

"""
Quick script to validate the the Chart.yaml `version` corresponds
to the git tag. Raise an Exception if not
"""

import os
import sys
import logging
import argparse
import itertools
from glob import glob

from ruamel.yaml import load


logging.basicConfig(level=os.environ.get('LOG_LEVEL', logging.INFO))

CHART_GLOB = '*/Chart.yaml'

def validate(args):
    all_files = list(itertools.chain(*[glob(f) for f in args.chartfiles]))

    for chartfile in all_files:
        logging.debug(f'Checking chartfile {chartfile} against tag {args.release_tag}')
        with open(chartfile, 'r') as cfile:
            chart = load(cfile)
            # See https://github.com/helm/helm/blob/master/docs/chart_best_practices/conventions.md#version-numbers
            # for why we replace '+' with '_'
            if chart['version'] != args.release_tag.replace('+', '_'):
                print(f'The Chart.yaml `version` field: {chart["version"]} '
                      f'does not correspond to the git tag: {args.release_tag}, failing')
                sys.exit(1)
            logging.info(f"Chartfile {chartfile} has the correct version for the current tag {args.release_tag}")

def main():
    parser = argparse.ArgumentParser(description='Validate tag corresponds to chart release')
    parser.add_argument('--release_tag', default=None, help='Tag to validate or $CI_BUILD_TAG')
    parser.add_argument('--chartfiles', default=None, help='glob/s of Chart.yaml files to validate or */Chart.yaml')

    arguments = parser.parse_args()
    logging.debug(f'Passed "{arguments.release_tag}" for tag and "{arguments.chartfiles}" for chartfiles')
    arguments.chartfiles = arguments.chartfiles or [CHART_GLOB]
    arguments.release_tag = arguments.release_tag or os.getenv('CI_BUILD_TAG')

    logging.debug(f'With defaults now "{arguments.release_tag}" for tag and "{arguments.chartfiles}" for chartfiles')

    validate(arguments)

if __name__ == '__main__':
    main()
