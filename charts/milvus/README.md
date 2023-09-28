# Milvus Helm Chart

For more information about installing and using Helm, see the [Helm Docs](https://helm.sh/docs/). For a quick introduction to Charts, see the [Chart Guide](https://helm.sh/docs/topics/charts/).

To install Milvus, refer to [Milvus installation](https://milvus.io/docs/v2.0.x/install_cluster-helm.md).

## Introduction
This chart bootstraps Milvus deployment on a Kubernetes cluster using the Helm package manager.

## Prerequisites

- Kubernetes 1.14+ (Attu requires 1.18+)
- Helm >= 3.2.0

> **IMPORTANT** The master branch is for the development of Milvus v2.x. On March 9th, 2021, we released Milvus v1.0, the first stable version of Milvus with long-term support. To use Milvus v1.x, switch to [branch 1.1](https://github.com/zilliztech/milvus-helm/tree/1.1).

## Install the Chart

1. Add the stable repository
```bash
$ helm repo add milvus https://zilliztech.github.io/milvus-helm/
```

2. Update charts repositories
```
$ helm repo update
```

### Deploy Milvus with standalone mode

Assume the release name is `my-release`:

```bash
# Helm v3.x
$ helm upgrade --install my-release --set cluster.enabled=false --set etcd.replicaCount=1 --set pulsar.enabled=false --set minio.mode=standalone milvus/milvus
```
By default, milvus standalone uses `rocksmq` as message queue. You can also use `pulsar` or `kafka` as message queue:

```bash
# Helm v3.x
# Milvus Standalone with pulsar as message queue
$ helm upgrade --install my-release --set cluster.enabled=false --set standalone.messageQueue=pulsar --set etcd.replicaCount=1 --set pulsar.enabled=true --set minio.mode=standalone milvus/milvus
```

```bash
# Helm v3.x
# Milvus Standalone with kafka as message queue
$ helm upgrade --install my-release --set cluster.enabled=false --set standalone.messageQueue=kafka --set etcd.replicaCount=1 --set pulsar.enabled=false --set kafka.enabled=true --set minio.mode=standalone milvus/milvus
```
> **Tip**: To list all releases, using `helm list`.

### Deploy Milvus with cluster mode

Assume the release name is `my-release`:

```bash
# Helm v3.x
$ helm upgrade --install my-release milvus/milvus
```
By default, milvus cluster uses `pulsar` as message queue. You can also use `kafka` instead of `pulsar` for milvus cluster:

```bash
# Helm v3.x
$ helm upgrade --install my-release milvus/milvus --set pulsar.enabled=false --set kafka.enabled=true
```

By default, milvus cluster uses several separate coordinators. You can also use mixCoordinator instead which contains all coordinators.

```bash
# Helm v3.x
$ cat << EOF > values-custom.yaml
mixCoordinator:
  enabled: true
rootCoordinator:
  enabled: false
indexCoordinator:
  enabled: false
queryCoordinator:
  enabled: false
dataCoordinator:
  enabled: false
EOF
$ helm upgrade --install my-release milvus/milvus -f values-custom.yaml
```

### Upgrade an existing Milvus cluster

> **IMPORTANT** If you have installed a milvus cluster with version below v2.1.x, you need follow the instructions at here: https://github.com/milvus-io/milvus/blob/master/deployments/migrate-meta/README.md. After meta migration, you use `helm upgrade` to update your cluster again.

E.g. to scale out query node from 1(default) to 2:

```bash
# Helm v3.x
$ helm upgrade --install --set queryNode.replicas=2 my-release milvus/milvus
```

### Milvus Coordinator Active Standby
> **IMPORTANT** Milvus helm chart 4.0.7 (Milvus 2.2.3) support deploying multiple coordinators. For example, you run a Milvus cluster with two rootcoord pods:

```bash
helm upgrade --install my-release milvus/milvus --set rootCoordinator.activeStandby.enabled=true --set rootCoordinator.replicas=2
```

### Breaking Changes

> **IMPORTANT** Milvus helm chart 4.0.0 has breaking changes for milvus configuration. Previously, you can set segment size like this `--set dataCoordinator.segment.maxSize=1024`. Now we have remove all the shortcut config option. Instead, you can set using `extraConfigFiles` like this:
```bash
extraConfigFiles:
  user.yaml: |+
    dataCoord:
      segment:
        maxSize: 1024
```

So if you had deployed a cluster with helm chart version below 4.0.0 and also specified extra config, you need set the configs under `extraConfigFiles` when running `helm upgrade`.

### Enable log to file

By default, all the logs of milvus components will output stdout. If you wanna log to file, you'd install milvus with `--set log.persistence.enabled=true`. Note that you should have a storageclass with `ReadWriteMany` access modes.

```bash
# Install a milvus cluster with file log output
helm install my-release milvus/milvus --set log.persistence.enabled=true --set log.persistence.persistentVolumeClaim.storageClass=<read-write-many-storageclass>
```

It will output log to `/milvus/logs/` directory.

## Uninstall the Chart

```bash
# Helm v3.x
$ helm uninstall my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

- Completely uninstall Milvus

> **IMPORTANT** Please run this command with care. Maybe you want to keep ETCD data
```bash
MILVUS_LABELS="app.kubernetes.io/instance=my-release"
kubectl delete pvc $(kubectl get pvc -l "${MILVUS_LABELS}" -o jsonpath='{range.items[*]}{.metadata.name} ')
```

## Configuration

### Milvus Service Configuration

The following table lists the configurable parameters of the Milvus Service and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `cluster.enabled`                         | Enable or disable Milvus Cluster mode         | `true`                                                 |
| `image.all.repository`                    | Image repository                              | `milvusdb/milvus`                                       |
| `image.all.tag`                           | Image tag                                     | `v2.3.1`                           |
| `image.all.pullPolicy`                    | Image pull policy                             | `IfNotPresent`                                          |
| `image.all.pullSecrets`                   | Image pull secrets                            | `{}`                                                    |
| `image.tools.repository`                  | Config image repository                       | `milvusdb/milvus-config-tool`                                       |
| `image.tools.tag`                         | Config image tag                              | `v0.1.1`                           |
| `image.tools.pullPolicy`                  | Config image pull policy                      | `IfNotPresent`                                          |
| `extraConfigFiles`                        | Extra config to override default milvus.yaml  | `user.yaml:`                                                     |
| `service.type`                            | Service type                                  | `ClusterIP`                                             |
| `service.port`                            | Port where service is exposed                 | `19530`                                                 |
| `service.portName`                        | Useful for [Istio protocol selection](https://istio.io/latest/docs/ops/configuration/traffic-management/protocol-selection/)   | `milvus`                                                |
| `service.nodePort`                        | Service nodePort                              | `unset`                                                 |
| `service.annotations`                     | Service annotations                           | `{}`                                                    |
| `service.labels`                          | Service custom labels                         | `{}`                                                    |
| `service.clusterIP`                       | Internal cluster service IP                   | `unset`                                                 |
| `service.loadBalancerIP`                  | IP address to assign to load balancer (if supported) | `unset`                                          |
| `service.loadBalancerSourceRanges`        | List of IP CIDRs allowed access to lb (if supported) | `[]`                                             |
| `service.externalIPs`                     | Service external IP addresses                 | `[]`                                                    |
| `ingress.enabled`                         | If true, Ingress will be created              | `false`                                                 |
| `ingress.annotations`                     | Ingress annotations                           | `{}`                                                    |
| `ingress.labels`                          | Ingress labels                                | `{}`                                                    |
| `ingress.rules`                           | Ingress rules                                 | `[]`                                                    |
| `ingress.tls`                             | Ingress TLS configuration                     | `[]`                                                    |
| `serviceAccount.create`                   | Create a custom service account               | `false`                                                 |
| `serviceAccount.name`                     | Service Account name                          | `milvus`                                                |
| `serviceAccount.annotations`              | Service Account Annotations                   | `{}`                                                    |
| `serviceAccount.labels`                   | Service Account labels                        | `{}`                                                    |
| `metrics.enabled`                         | Export Prometheus monitoring metrics          | `true`                                                  |
| `metrics.serviceMonitor.enabled`          | Create ServiceMonitor for Prometheus operator | `false`                                                 |
| `metrics.serviceMonitor.additionalLabels` | Additional labels that can be used so ServiceMonitor will be discovered by Prometheus | `unset`         |
| `log.level`                               | Logging level to be used. Valid levels are `debug`, `info`, `warn`, `error`, `fatal` | `info`          |
| `log.file.maxSize`                        | The size limit of the log file (MB)           | `300`                                                   |
| `log.file.maxAge`                         | The maximum number of days that the log is retained. (day) | `10`                                       |
| `log.file.maxBackups`                     | The maximum number of retained logs.          | `20`                                                    |
| `log.format`                              | Format used for the logs. Valid formats are `text` and `json` | `text`                                  |
| `log.persistence.enabled`                 | Use persistent volume to store Milvus logs data | `false`                                               |
| `log.persistence.mountPath`               | Milvus logs data persistence volume mount path | `/milvus/logs`                                         |
| `log.persistence.annotations`             | PersistentVolumeClaim annotations             | `{}`                                                    |
| `log.persistence.persistentVolumeClaim.existingClaim` | Use your own data Persistent Volume existing claim name | `unset`                           |
| `log.persistence.persistentVolumeClaim.storageClass` | The Milvus logs data Persistent Volume Storage Class | `unset`                               |
| `log.persistence.persistentVolumeClaim.accessModes` | The Milvus logs data Persistence access modes | `ReadWriteOnce`                               |
| `log.persistence.persistentVolumeClaim.size` | The size of Milvus logs data Persistent Volume Storage Class | `5Gi`                                 |
| `log.persistence.persistentVolumeClaim.subPath` | SubPath for Milvus logs data mount | `unset`                                                      |
| `externalS3.enabled`                      | Enable or disable external S3                 | `false`                                                 |
| `externalS3.host`                         | The host of the external S3                   | `unset`                                                 |
| `externalS3.port`                         | The port of the external S3                   | `unset`                                                 |
| `externalS3.rootPath`                     | The path prefix of the external S3            | `unset`                                                 |
| `externalS3.accessKey`                    | The Access Key of the external S3             | `unset`                                                 |
| `externalS3.secretKey`                    | The Secret Key of the external S3             | `unset`                                                 |
| `externalS3.bucketName`                   | The Bucket Name of the external S3            | `unset`                                                 |
| `externalS3.useSSL`                       | If true, use SSL to connect to the external S3 | `false`                                                |
| `externalS3.useIAM`                       | If true, use iam to connect to the external S3 | `false`                                                |
| `externalS3.cloudProvider`                | When `useIAM` enabled, only "aws" & "gcp" is supported for now | `aws`                                  |
| `externalS3.iamEndpoint`                  | The IAM endpoint of  the external S3 | ``                                                |
| `externalGcs.bucketName`                  | The Bucket Name of the external GCS. Requires GCS gateway to be enabled in the minIO configuration | `unset`                                                |
| `externalEtcd.enabled`                    | Enable or disable external Etcd               | `false`                                                 |
| `externalEtcd.endpoints`                  | The endpoints of the external etcd            | `{}`                                                    |
| `externalPulsar.enabled`                  | Enable or disable external Pulsar             | `false`                                                 |
| `externalPulsar.host`                     | The host of the external Pulsar               | `localhost`                                             |
| `externalPulsar.port`                     | The port of the external Pulsar               | `6650`                                                  |
| `externalPulsar.tenant`                   | The tenant of the external Pulsar             | `public`                                                  |
| `externalPulsar.namespace`                | The namespace of the external Pulsar          | `default`                                                  |
| `externalPulsar.authPlugin`               | The authPlugin of the external Pulsar         | `""`                                                  |
| `externalPulsar.authParams`               | The authParams of the external Pulsar         | `""`                                                  |
| `externalKafka.enabled`                   | Enable or disable external Kafka             | `false`                                                 |
| `externalKafka.brokerList`                | The brokerList of the external Kafka separated by comma               | `localhost:9092`                                             |
| `externalKafka.securityProtocol`          | The securityProtocol used for kafka authentication                    | `SASL_SSL`                                                   |
| `externalKafka.sasl.mechanisms`           | SASL mechanism to use for kafka authentication                        | `PLAIN`                                                      |
| `externalKafka.sasl.username`             | username for PLAIN or SASL/PLAIN authentication                       | ``                                                           |
| `externalKafka.sasl.password`             | password for PLAIN or SASL/PLAIN authentication                       | ``                                                           |
| `externalMysql.enabled`                   | Enable or disable external MySQL             | `false`                                                 |
| `externalMysql.username`                  | MySQL username                               |                                        ``                                                      |
| `externalMysql.password`                  | MySQL password                               | ``                                                      |
| `externalMysql.address`                   | MySQL address                                | `localhost`                                             |
| `externalMysql.port`                      | MySQL port                                   | `3306`                                                  |
| `externalMysql.dbName`                    | MySQL meta database                          | `milvus_meta`                                           |
| `externalMysql.maxOpenConns`              | MySQL client maxOpenConns                    | `20`                                                    |
| `externalMysql.maxIdleConns`              | MySQL client maxIdleConns                    | `5`                                                     |

### Milvus Standalone Deployment Configuration

The following table lists the configurable parameters of the Milvus Standalone component and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `standalone.resources`                    | Resource requests/limits for the Milvus Standalone pods | `{}`                                          |
| `standalone.nodeSelector`                 | Node labels for Milvus Standalone pods assignment | `{}`                                                |
| `standalone.affinity`                     | Affinity settings for Milvus Standalone pods assignment | `{}`                                          |
| `standalone.tolerations`                  | Toleration labels for Milvus Standalone pods assignment | `[]`                                          |
| `standalone.heaptrack.enabled`            | Whether to enable heaptrack                             | `false`                                          |
| `standalone.disk.enabled`                 | Whether to enable disk                             | `true`                                          |
| `standalone.profiling.enabled`            | Whether to enable live profiling                   | `false`                                          |
| `standalone.extraEnv`                     | Additional Milvus Standalone container environment variables | `[]`                                     |
| `standalone.messageQueue`                 | Message queue for Milvus Standalone: rocksmq, natsmq, pulsar, kafka | `rocksmq`                                     |
| `standalone.persistence.enabled`          | Use persistent volume to store Milvus standalone data | `true`                                          |
| `standalone.persistence.mountPath` | Milvus standalone data persistence volume mount path | `/var/lib/milvus`                                       |
| `standalone.persistence.annotations`      | PersistentVolumeClaim annotations             | `{}`                                                    |
| `standalone.persistence.persistentVolumeClaim.existingClaim` | Use your own data Persistent Volume existing claim name | `unset`                    |
| `standalone.persistence.persistentVolumeClaim.storageClass` | The Milvus standalone data Persistent Volume Storage Class | `unset`                  |
| `standalone.persistence.persistentVolumeClaim.accessModes` | The Milvus standalone data Persistence access modes | `ReadWriteOnce`                  |
| `standalone.persistence.persistentVolumeClaim.size` | The size of Milvus standalone data Persistent Volume Storage Class | `5Gi`                    |
| `standalone.persistence.persistentVolumeClaim.subPath` | SubPath for Milvus standalone data mount | `unset`                                         |

### Milvus Proxy Deployment Configuration

The following table lists the configurable parameters of the Milvus Proxy component and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `proxy.enabled`                           | Enable or disable Milvus Proxy Deployment     | `true`                                                  |
| `proxy.replicas`                          | Desired number of Milvus Proxy pods            | `1`                                                    |
| `proxy.resources`                         | Resource requests/limits for the Milvus Proxy pods | `{}`                                               |
| `proxy.nodeSelector`                      | Node labels for Milvus Proxy pods assignment | `{}`                                                     |
| `proxy.affinity`                          | Affinity settings for Milvus Proxy pods assignment | `{}`                                               |
| `proxy.tolerations`                       | Toleration labels for Milvus Proxy pods assignment | `[]`                                               |
| `proxy.heaptrack.enabled`                 | Whether to enable heaptrack                             | `false`                                          |
| `proxy.profiling.enabled`                 | Whether to enable live profiling                   | `false`                                          |
| `proxy.extraEnv`                          | Additional Milvus Proxy container environment variables | `[]`                                          |
| `proxy.http.enabled`                          | Enable rest api for Milvus Proxy | `true`                                          |
| `proxy.http.debugMode.enabled`                          | Enable debug mode for rest api | `false`                                          |

### Milvus Root Coordinator Deployment Configuration

The following table lists the configurable parameters of the Milvus Root Coordinator component and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `rootCoordinator.enabled`                 | Enable or disable Milvus Root Coordinator component  | `true`                                           |
| `rootCoordinator.resources`               | Resource requests/limits for the Milvus Root Coordinator pods | `{}`                                    |
| `rootCoordinator.nodeSelector`            | Node labels for Milvus Root Coordinator pods assignment | `{}`                                          |
| `rootCoordinator.affinity`                | Affinity settings for Milvus Root Coordinator pods assignment | `{}`                                    |
| `rootCoordinator.tolerations`             | Toleration labels for Milvus Root Coordinator pods assignment | `[]`                                    |
| `rootCoordinator.heaptrack.enabled`       | Whether to enable heaptrack                             | `false`                                          |
| `rootCoordinator.profiling.enabled`       | Whether to enable live profiling                   | `false`                                          |
| `rootCoordinator.activeStandby.enabled`   | Whether to enable active-standby                   | `false`                                          |
| `rootCoordinator.extraEnv`                | Additional Milvus Root Coordinator container environment variables | `[]`                               |
| `rootCoordinator.service.type`                       | Service type                                  | `ClusterIP`                                  |
| `rootCoordinator.service.port`                       | Port where service is exposed                 | `19530`                                      |
| `rootCoordinator.service.annotations`                | Service annotations                           | `{}`                                         |
| `rootCoordinator.service.labels`                     | Service custom labels                         | `{}`                                         |
| `rootCoordinator.service.clusterIP`                  | Internal cluster service IP                   | `unset`                                      |
| `rootCoordinator.service.loadBalancerIP`             | IP address to assign to load balancer (if supported) | `unset`                               |
| `rootCoordinator.service.loadBalancerSourceRanges`   | List of IP CIDRs allowed access to lb (if supported) | `[]`                                  |
| `rootCoordinator.service.externalIPs`                | Service external IP addresses                 | `[]`                                         |

### Milvus Query Coordinator Deployment Configuration

The following table lists the configurable parameters of the Milvus Query Coordinator component and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `queryCoordinator.enabled`                | Enable or disable Query Coordinator component | `true`                                                  |
| `queryCoordinator.resources`              | Resource requests/limits for the Milvus Query Coordinator pods | `{}`                                   |
| `queryCoordinator.nodeSelector`           | Node labels for Milvus Query Coordinator pods assignment | `{}`                                         |
| `queryCoordinator.affinity`               | Affinity settings for Milvus Query Coordinator pods assignment | `{}`                                   |
| `queryCoordinator.tolerations`            | Toleration labels for Milvus Query Coordinator pods assignment | `[]`                                   |
| `queryCoordinator.heaptrack.enabled`      | Whether to enable heaptrack                             | `false`                                          |
| `queryCoordinator.profiling.enabled`      | Whether to enable live profiling                   | `false`                                          |
| `queryCoordinator.activeStandby.enabled`  | Whether to enable active-standby                   | `false`                                          |
| `queryCoordinator.extraEnv`               | Additional Milvus Query Coordinator container environment variables | `[]`                              |
| `queryCoordinator.service.type`                       | Service type                                  | `ClusterIP`                                 |
| `queryCoordinator.service.port`                       | Port where service is exposed                 | `19530`                                     |
| `queryCoordinator.service.annotations`                | Service annotations                           | `{}`                                        |
| `queryCoordinator.service.labels`                     | Service custom labels                         | `{}`                                        |
| `queryCoordinator.service.clusterIP`                  | Internal cluster service IP                   | `unset`                                     |
| `queryCoordinator.service.loadBalancerIP`             | IP address to assign to load balancer (if supported) | `unset`                              |
| `queryCoordinator.service.loadBalancerSourceRanges`   | List of IP CIDRs allowed access to lb (if supported) | `[]`                                 |
| `queryCoordinator.service.externalIPs`                | Service external IP addresses                 | `[]`                                        |

### Milvus Query Node Deployment Configuration

The following table lists the configurable parameters of the Milvus Query Node component and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `queryNode.enabled`                       | Enable or disable Milvus Query Node component | `true`                                                  |
| `queryNode.replicas`                      | Desired number of Milvus Query Node pods | `1`                                                          |
| `queryNode.resources`                     | Resource requests/limits for the Milvus Query Node pods | `{}`                                          |
| `queryNode.nodeSelector`                  | Node labels for Milvus Query Node pods assignment | `{}`                                                |
| `queryNode.affinity`                      | Affinity settings for Milvus Query Node pods assignment | `{}`                                          |
| `queryNode.tolerations`                   | Toleration labels for Milvus Query Node pods assignment | `[]`                                          |
| `queryNode.heaptrack.enabled`             | Whether to enable heaptrack                             | `false`                                          |
| `queryNode.disk.enabled`                  | Whether to enable disk for query                             | `true`                                          |
| `queryNode.profiling.enabled`             | Whether to enable live profiling                   | `false`                                          |
| `queryNode.extraEnv`                      | Additional Milvus Query Node container environment variables | `[]`                                     |

### Milvus Index Coordinator Deployment Configuration

The following table lists the configurable parameters of the Milvus Index Coordinator component and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `indexCoordinator.enabled`                | Enable or disable Index Coordinator component | `true`                                                  |
| `indexCoordinator.resources`              | Resource requests/limits for the Milvus Index Coordinator pods | `{}`                                   |
| `indexCoordinator.nodeSelector`           | Node labels for Milvus Index Coordinator pods assignment | `{}`                                         |
| `indexCoordinator.affinity`               | Affinity settings for Milvus Index Coordinator pods assignment | `{}`                                   |
| `indexCoordinator.tolerations`            | Toleration labels for Milvus Index Coordinator pods assignment | `[]`                                   |
| `indexCoordinator.heaptrack.enabled`      | Whether to enable heaptrack                             | `false`                                          |
| `indexCoordinator.profiling.enabled`      | Whether to enable live profiling                   | `false`                                          |
| `indexCoordinator.activeStandby.enabled`  | Whether to enable active-standby                   | `false`                                          |
| `indexCoordinator.extraEnv`               | Additional Milvus Index Coordinator container environment variables | `[]`                              |
| `indexCoordinator.service.type`                       | Service type                                  | `ClusterIP`                                 |
| `indexCoordinator.service.port`                       | Port where service is exposed                 | `19530`                                     |
| `indexCoordinator.service.annotations`                | Service annotations                           | `{}`                                        |
| `indexCoordinator.service.labels`                     | Service custom labels                         | `{}`                                        |
| `indexCoordinator.service.clusterIP`                  | Internal cluster service IP                   | `unset`                                     |
| `indexCoordinator.service.loadBalancerIP`             | IP address to assign to load balancer (if supported) | `unset`                              |
| `indexCoordinator.service.loadBalancerSourceRanges`   | List of IP CIDRs allowed access to lb (if supported) | `[]`                                 |
| `indexCoordinator.service.externalIPs`                | Service external IP addresses                 | `[]`                                        |

### Milvus Index Node Deployment Configuration

The following table lists the configurable parameters of the Milvus Index Node component and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `indexNode.enabled`                       | Enable or disable Index Node component        | `true`                                                  |
| `indexNode.replicas`                      | Desired number of Index Node pods             | `1`                                                     |
| `indexNode.resources`                     | Resource requests/limits for the Milvus Index Node pods | `{}`                                          |
| `indexNode.nodeSelector`                  | Node labels for Milvus Index Node pods assignment | `{}`                                                |
| `indexNode.affinity`                      | Affinity settings for Milvus Index Node pods assignment | `{}`                                          |
| `indexNode.tolerations`                   | Toleration labels for Milvus Index Node pods assignment | `[]`                                          |
| `indexNode.heaptrack.enabled`             | Whether to enable heaptrack                             | `false`                                          |
| `indexNode.disk.enabled`                  | Whether to enable disk for index node                             | `true`                                          |
| `indexNode.profiling.enabled`             | Whether to enable live profiling                   | `false`                                          |
| `indexNode.extraEnv`                      | Additional Milvus Index Node container environment variables | `[]`                                     |

### Milvus Data Coordinator Deployment Configuration

The following table lists the configurable parameters of the Milvus Data Coordinator component and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `dataCoordinator.enabled`                 | Enable or disable Data Coordinator component  | `true`                                                  |
| `dataCoordinator.resources`               | Resource requests/limits for the Milvus Data Coordinator pods | `{}`                                    |
| `dataCoordinator.nodeSelector`            | Node labels for Milvus Data Coordinator pods assignment | `{}`                                          |
| `dataCoordinator.affinity`                | Affinity settings for Milvus Data Coordinator pods assignment  | `{}`                                   |
| `dataCoordinator.tolerations`             | Toleration labels for Milvus Data Coordinator pods assignment | `[]`                                    |
| `dataCoordinator.heaptrack.enabled`       | Whether to enable heaptrack                             | `false`                                          |
| `dataCoordinator.profiling.enabled`       | Whether to enable live profiling                   | `false`                                          |
| `dataCoordinator.activeStandby.enabled`   | Whether to enable active-standby                   | `false`                                          |
| `dataCoordinator.extraEnv`                | Additional Milvus Data Coordinator container environment variables | `[]`                               |
| `dataCoordinator.service.type`                        | Service type                                  | `ClusterIP`                                 |
| `dataCoordinator.service.port`                        | Port where service is exposed                 | `19530`                                     |
| `dataCoordinator.service.annotations`                 | Service annotations                           | `{}`                                        |
| `dataCoordinator.service.labels`                      | Service custom labels                         | `{}`                                        |
| `dataCoordinator.service.clusterIP`                   | Internal cluster service IP                   | `unset`                                     |
| `dataCoordinator.service.loadBalancerIP`              | IP address to assign to load balancer (if supported) | `unset`                              |
| `dataCoordinator.service.loadBalancerSourceRanges`    | List of IP CIDRs allowed access to lb (if supported) | `[]`                                 |
| `dataCoordinator.service.externalIPs`                 | Service external IP addresses                 | `[]`                                        |

### Milvus Data Node Deployment Configuration

The following table lists the configurable parameters of the Milvus Data Node component and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `dataNode.enabled`                        | Enable or disable Data Node component         | `true`                                                  |
| `dataNode.replicas`                       | Desired number of Data Node pods               | `1`                                                    |
| `dataNode.resources`                      | Resource requests/limits for the Milvus Data Node pods | `{}`                                           |
| `dataNode.nodeSelector`                   | Node labels for Milvus Data Node pods assignment | `{}`                                                 |
| `dataNode.affinity`                       | Affinity settings for Milvus Data Node pods assignment | `{}`                                           |
| `dataNode.tolerations`                    | Toleration labels for Milvus Data Node pods assignment | `[]`                                           |
| `dataNode.heaptrack.enabled`              | Whether to enable heaptrack                             | `false`                                          |
| `dataNode.profiling.enabled`              | Whether to enable live profiling                   | `false`                                          |
| `dataNode.extraEnv`                       | Additional Milvus Data Node container environment variables | `[]`                                      |

### Milvus Mixture Coordinator Deployment Configuration

The following table lists the configurable parameters of the Milvus Mixture Coordinator component and their default values.

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `mixCoordinator.enabled`                 | Enable or disable Data Coordinator component  | `true`                                                  |
| `mixCoordinator.resources`               | Resource requests/limits for the Milvus Data Coordinator pods | `{}`                                    |
| `mixCoordinator.nodeSelector`            | Node labels for Milvus Data Coordinator pods assignment | `{}`                                          |
| `mixCoordinator.affinity`                | Affinity settings for Milvus Data Coordinator pods assignment  | `{}`                                   |
| `mixCoordinator.tolerations`             | Toleration labels for Milvus Data Coordinator pods assignment | `[]`                                    |
| `mixCoordinator.heaptrack.enabled`       | Whether to enable heaptrack                             | `false`                                          |
| `mixCoordinator.profiling.enabled`       | Whether to enable live profiling                   | `false`                                          |
| `mixCoordinator.activeStandby.enabled`   | Whether to enable active-standby                   | `false`                                          |
| `mixCoordinator.extraEnv`                | Additional Milvus Data Coordinator container environment variables | `[]`                               |
| `mixCoordinator.service.type`                        | Service type                                  | `ClusterIP`                                 |
| `mixCoordinator.service.annotations`                 | Service annotations                           | `{}`                                        |
| `mixCoordinator.service.labels`                      | Service custom labels                         | `{}`                                        |
| `mixCoordinator.service.clusterIP`                   | Internal cluster service IP                   | `unset`                                     |
| `mixCoordinator.service.loadBalancerIP`              | IP address to assign to load balancer (if supported) | `unset`                              |
| `mixCoordinator.service.loadBalancerSourceRanges`    | List of IP CIDRs allowed access to lb (if supported) | `[]`                                 |
| `mixCoordinator.service.externalIPs`                 | Service external IP addresses                 | `[]`                                        |

### Pulsar Configuration

This version of the chart includes the dependent Pulsar chart in the charts/ directory.

You can find more information at:
* [https://pulsar.apache.org/charts](https://pulsar.apache.org/charts)

### Etcd Configuration

This version of the chart includes the dependent Etcd chart in the charts/ directory.

You can find more information at:
* [https://artifacthub.io/packages/helm/bitnami/etcd](https://artifacthub.io/packages/helm/bitnami/etcd)

### Minio Configuration

This version of the chart includes the dependent Minio chart in the charts/ directory.

You can find more information at:
* [https://github.com/minio/charts/blob/master/README.md](https://github.com/minio/charts/blob/master/README.md)

### Kafka Configuration

This version of the chart includes the dependent Kafka chart in the charts/ directory.

You can find more information at:
* [https://artifacthub.io/packages/helm/bitnami/kafka](https://artifacthub.io/packages/helm/bitnami/kafka)

### MySQL Configuration

This version of the chart includes the dependent MySQL chart in the charts/ directory.

You can find more information at:
* [https://artifacthub.io/packages/helm/bitnami/mysql](https://artifacthub.io/packages/helm/bitnami/mysql)

### Milvus Live Profiling
Profiling is an effective way of understanding which parts of your application are consuming the most resources.

Continuous Profiling adds a dimension of time that allows you to understand your systems resource usage (i.e. CPU, Memory, etc.) over time and gives you the ability to locate, debug, and fix issues related to performance.

You can enable profiling with Pyroscope and you can find more information at:
* [https://pyroscope.io/docs/kubernetes-helm-chart/](https://pyroscope.io/docs/kubernetes-helm-chart/)
