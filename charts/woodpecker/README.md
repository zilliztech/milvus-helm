# Woodpecker Helm Chart

A Helm chart for Woodpecker - A Cloud-Native WAL Storage Implementation for Milvus.

## Prerequisites

- Kubernetes >= 1.20.0
- Helm >= 3.14.0
- MinIO instance for object storage

## Installation

```bash
helm install my-woodpecker ./woodpecker
```

## Configuration

The following table lists the configurable parameters and their default values.

### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of Woodpecker replicas | `4` |
| `clusterName` | Name of the Woodpecker cluster | `woodpecker-cluster` |
| `resourceGroup` | Resource group identifier | `rg-primary` |
| `availabilityZone` | Availability zone | `az-1` |

### Image Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Woodpecker image repository | `milvusdb/woodpecker` |
| `image.tag` | Woodpecker image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Image pull secrets | `[]` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ports.service` | Service port | `18080` |
| `ports.gossip` | Gossip protocol port | `17946` |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `18080` |

### Storage Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.accessModes` | Access modes for PVC | `["ReadWriteOnce"]` |
| `persistence.size` | Size of persistent volume | `30Gi` |
| `persistence.storageClass` | Storage class name | `""` |

### MinIO Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `minio.address` | MinIO server address | `""` |
| `minio.port` | MinIO server port | `9000` |
| `minio.accessKey` | MinIO access key | `minioadmin` |
| `minio.secretKey` | MinIO secret key | `minioadmin` |
| `minio.bucketName` | MinIO bucket name | `milvus-bucket` |

### Health Check Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `readiness.enabled` | Enable readiness probe | `true` |
| `readiness.initialDelaySeconds` | Initial delay for readiness probe | `30` |
| `readiness.periodSeconds` | Period for readiness probe | `15` |

### Resource Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.limits.cpu` | CPU limit | `1` |
| `resources.limits.memory` | Memory limit | `1Gi` |
| `resources.requests.cpu` | CPU request | `500m` |
| `resources.requests.memory` | Memory request | `512Mi` |

### Other Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `logging.level` | Log level | `info` |
| `extraEnv` | Additional environment variables | `[]` |
| `nodeSelector` | Node selector for pod assignment | `{}` |
| `tolerations` | Tolerations for pod assignment | `[]` |
| `affinity` | Affinity rules for pod assignment | `{}` |

## Dependencies

Woodpecker requires a MinIO instance for object storage. Ensure that:

1. MinIO is deployed and accessible
2. The bucket specified in `minio.bucketName` exists
3. Access credentials are properly configured

## Usage

### Installing with custom values

```bash
helm install my-woodpecker ./woodpecker -f custom-values.yaml
```

### Upgrading

```bash
helm upgrade my-woodpecker ./woodpecker
```

### Uninstalling

```bash
helm uninstall my-woodpecker
```

### Scaling

To change the number of replicas:

```bash
helm upgrade my-woodpecker ./woodpecker --set replicaCount=6
```

## Monitoring

After installation, verify the deployment:

```bash
kubectl get pods -l app.kubernetes.io/instance=my-woodpecker
kubectl get services -l app.kubernetes.io/instance=my-woodpecker
```

## Troubleshooting

1. **Pods not starting**: Check MinIO connectivity and credentials
2. **Storage issues**: Verify storage class and PVC creation
3. **Network issues**: Check service and ingress configuration

For detailed logs:

```bash
kubectl logs -l app.kubernetes.io/instance=my-woodpecker -f
```