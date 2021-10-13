# transcrobes

[transcrobes](https://github.com/transcrobes/charts) is a Kubernetes Helm Chart to install Transcrobes.

## TL;DR;

```console
$ git clone https://github.com/transcrobes/charts
$ cd charts
$ helm upgrade --install my-release ./transcrobes --set transcrobes.bingSubscriptionKey=my_bing_key --set transcrobes.nodeHosts={node1.example.com} --set transcrobes.haHost=transcrobes.example.com
```

## Introduction

This chart bootstraps a [Transcrobes](https://transcrob.es) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites
### Installation
  - A publicly accessible Kubernetes 1.22+ (may work on other versions but is currently untested)
### Working installation
  - A publicly available FQDN pointing to your Kubernetes cluster. In the following examples this is `transcrobes.example.com`. Currently only `HostNetwork` and `NodePort` are implemented but loadbalancer IPs will be supported soon.
  - A valid Microsoft Azure Cognitive services API token. Microsoft currently provides 2M characters (translations, dictionary lookups, etc.) free per month. This requires a valid credit card to set up but the default configuration will stop translating at 2M characters rather than start charging you. More details [here](https://azure.microsoft.com/en-us/pricing/details/cognitive-services/translator-text-api/).

## Installing the Chart

The command deploys transcrobes on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the transcrobes chart and their default values.

Parameter | Description | Default
--------- | ----------- | -------
`transcrobes.enabled` | If true, create transcrobes | `true`
FIXME: see values.yaml for detailed descriptions
