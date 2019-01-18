# Gitlab Pages Setup

In order to set up Gitlab pages as a chart repository with automatic Let's Encrypt certificate update, certain manual steps are needed. This page describes the steps taken for setting up the repository to serve at https://charts.transcrob.es, and can be used as inspiration for a different domain.

## Domain setup

Most of the instructions you find for setting up Gitlab pages on the internet assume that you will also be needing an XYZ.gitlab.io domain, and that places restrictions on both project naming and project placement (sub-groups, etc.). As we only want to serve from https://charts.transcrob.es, the project can be any Gitlab project.

Transcrobes *also* has a Gitlab pages site for the group, at https://transcrob.es, which is configured by the repo https://gitlab.com/transcrobes/transcrobes.gitlab.io. This is a "traditional" pages repo in that it is available at https://transcrobes.gitlab.io as well as https://transcrob.es. Because the transcrob.es domain is not a sub-domain, it requires an A record pointing to the current Gitlab Pages IP (35.185.44.232 on this files commit date, check the Gitlab site for the current IP when reading this). The DNS record for charts.transcrob.es was set up as a CNAME to transcrobes.gitlab.io, but could equally have been set up as a CNAME to transcrob.es or an A record to the Pages IP.

```charts.transcrob.es.  300 CNAME   transcrobes.gitlab.io.```

## Pages setup
Go to the charts repo Pages setup page, e.g., https://gitlab.com/transcrobes/charts/pages. Uncheck "Force domains with SSL certificates to use HTTPS" and save. There is currently a bug on Gitlab.com - this checkbox means "HTTPS-only" and we will set up SSL in the following steps. Now click on `New Domain` and add charts.transcrob.es. This will then generate a DNS TXT record that needs to be added to the DNS zone. Something like the following (changed from the real value):

### Pages DNS TXT setup

```charts.transcrob.es.  60  TXT "_gitlab-pages-verification-code.charts.transcrob.es TXT gitlab-pages-verification-code=changed"```

Verify this has been setup properly:

```
$ dig charts.transcrob.es
$ dig charts.transcrob.es TXT
```

Once the record has been added, go back to the custom domain setup page (e.g. https://gitlab.com/transcrobes/charts/pages/domains/charts.transcrob.es) and click the `Verify` button. Wait until the dig commands above give you what you expect before verifying.

Info! It may take some time for the domain DNS to get propagated AND for the pages pipeline to deploy your pages, so don't fret if you can't see the chart right away.

## Set up a schedule for creating/updating the Let's Encrypt certificate

Set up a schedule in `CI / CD`, `Schedules` (e.g., https://gitlab.com/transcrobes/charts/pipeline_schedules). Give it a name (e.g., `letsencrypt-renewal`) and an interval. Once a day or once a week are appropriate options. The code first checks the expiry date of any existing certificate and will attempt to renew only if the expiry date is less than 30 days in the future.


## Push a commit
