# Milvus Helm Charts

This GitHub repository is the official source for Milvus's Helm charts.

![GitHub](https://img.shields.io/github/license/milvus-io/milvus-helm)
[![](https://github.com/zilliztech/milvus-helm/workflows/Release%20Charts/badge.svg?branch=master)](https://github.com/zilliztech/milvus-helm/actions)

For instructions about how to install charts from this repository, visit the public website at:
[Milvus Helm Charts](https://artifacthub.io/packages/helm/milvus-helm/milvus)

## Prerequisites

- Kubernetes >= 1.20.0
- Helm >= 3.14.0

## Compatibility Notice
- As of version 4.2.21, the Milvus Helm chart introduced pulsar-v3.x chart as dependency. For backward compatibility, please upgrade your helm to v3.14 or later version, and be sure to add the `--reset-then-reuse-values` option whenever you use `helm upgrade`.

- As of version 4.2.0, the Milvus Helm chart no longer supports Milvus v2.3.x. If you need to deploy Milvus v2.3.x using Helm, please use Milvus Helm chart version less than 4.2.0 (e.g 4.1.36).

> **IMPORTANT** The master branch is for the development of Milvus v2.x. On March 9th, 2021, we released Milvus v1.0, the first stable version of Milvus with long-term support. To use Milvus v1.x, switch to [branch 1.1](https://github.com/zilliztech/milvus-helm/tree/1.1).

## Make changes to an existing chart without publishing

If you make changes to an existing chart, but do not change its version, nothing new will be published to the _charts repository_.

## Publishing a new version of a chart

When a commit to master includes a new version of a _chart_, a GitHub action will make it available on the _charts repository_.

### Detailed explanation of publish procedure

With each commit to _master_, a GitHub action will compare all charts versions at the `charts` folder on _master_ branch with published versions at the `index.yaml` chart list on _gh-pages_ branch.

When it detects that the version in the folder doesn't exist in  `index.yaml`, it will create a release with the packaged chart content on the _GitHub repository_, and update `index.yaml` to include it on the `charts repository`.

`index.yaml` is accesible from [zilliztech.github.io/milvus-helm/index.yaml](https://github.com/zilliztech/milvus-helm/blob/gh-pages/index.yaml) and is the list of all _charts_ and their _versions_ available when you interact with the _charts repository_ using Helm.

The packaged referenced in `index.yaml`, when it's updated using the GitHub action, will link for download to the URL provided by the _GitHub repository_ release files.

## More information

You can find more information at:
*   [zilliztech.github.io/milvus-helm](https://github.com/zilliztech/milvus-helm)
*   [The Helm package manager](https://helm.sh/)
*   [Chart Releaser](https://github.com/helm/chart-releaser)
*   [Chart Releaser GitHub Action](https://github.com/helm/chart-releaser-action)

---

![Milvus logo](https://raw.githubusercontent.com/milvus-io/milvus-docs/master/assets/milvus_logo.png)
