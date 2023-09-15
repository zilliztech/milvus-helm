# Milvus Helm Charts

This GitHub repository is the official source for Milvus's Helm charts.

![GitHub](https://img.shields.io/github/license/milvus-io/milvus-helm)
[![](https://github.com/zilliztech/milvus-helm/workflows/Release%20Charts/badge.svg?branch=master)](https://github.com/zilliztech/milvus-helm/actions)

For instructions about how to install charts from this repository, visit the public website at:
[Milvus Helm Charts](https://artifacthub.io/packages/helm/milvus-helm/milvus)

## Make changes to an existing chart without publishing

If you make changes to an existing chart, but do not change its version, nothing new will be published to the _charts repository_.

## Publishing a new version of a chart

When a commit to master includes a new version of a _chart_, a GitHub action will make it available on the _charts repository_.

### Detailed explanation of publish procedure

With each commit to _master_, a GitHub action will compare all charts versions at the `charts` folder on _master_ branch with published versions at the `index.yaml` chart list on _gh-pages_ branch.

When it detects that the version in the folder doesn't exist in  `index.yaml`, it will create a release with the packaged chart content on the _GitHub repository_, and update `index.yaml` to include it on the `charts repository`.

`index.yaml` is accesible from [zilliztech.github.io/milvus-helm/index.yaml](https://github.com/zilliztech/milvus-helm/blob/gh-pages/index.yaml) and is the list of all _charts_ and their _versions_ available when you interact with the _charts repository_ using Helm.

The packaged referenced in `index.yaml`, when it's updated using the GitHub action, will link for download to the URL provided by the _GitHub repository_ release files.

## Add a new chart

To add a new chart, create a directory inside _charts_ with it contents at _master_ branch.

When you commit it, it will be picked up by the GitHub action, and if it contains a chart and version that doesn't already exist in the _charts repository_, a new release with the package for the chart will be published on the _GitHub repository_,
and the list of all charts at `index.yaml` on _gh-pages_ branch will be updated on the _charts repository_.

## More information

You can find more information at:
*   [zilliztech.github.io/milvus-helm](https://github.com/zilliztech/milvus-helm)
*   [The Helm package manager](https://helm.sh/)
*   [Chart Releaser](https://github.com/helm/chart-releaser)
*   [Chart Releaser GitHub Action](https://github.com/helm/chart-releaser-action)

---

![Milvus logo](https://raw.githubusercontent.com/milvus-io/milvus-docs/master/assets/milvus_logo.png)
