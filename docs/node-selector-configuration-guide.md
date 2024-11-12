# Node Selector Configuration Guide for Milvus Helm Chart

## Overview
Node selectors in Kubernetes allow you to constrain which nodes your pods can be scheduled on. Milvus Helm chart supports node selector configuration at both global and component-specific levels.

## Table of Contents

- [Node Selectors vs Node Affinity](#node-selectors-vs-node-affinity)
- [Priority Hierarchy](#priority-hierarchy)
- [Global Node Selector](#global-node-selector)
- [Component-Specific Node Selectors](#component-specific-node-selectors)
- [Dependencies Node Selectors](#dependencies-node-selectors)

## Node Selectors vs Node Affinity

Please refer to [Node Selectors vs Node Affinity](./node-selectors-vs-node-affinity.md) for more details.

## Priority Hierarchy

When configuring node selectors in Milvus, please note the following priority hierarchy:

1. Individual component configurations (proxy, queryNode, etc.) take precedence over global configurations. Component-specific node selectors will completely *override*, *not merge with*, global node selectors.
2. If no component-specific node selector is defined, the global node selector settings will be applied.

## Global Node Selector

The global node selector configuration applies to all Milvus components by default. Component-specific settings can override these global settings. Note that the global node selector does not affect the dependencies (MinIO, etcd, Pulsar, or Kafka). Configure it under the top-level `nodeSelector` field:



```yaml
# Global node selector

# Milvus components will be scheduled on nodes with ssd disk and compute-optimized instance type
nodeSelector:
  disk: ssd
  instance-type: compute-optimized
```

## Component-Specific Node Selectors

Each Milvus component can have its own node selector configuration that overrides the global settings.

### Available Components:

1. **Proxy**:
```yaml
proxy:
  # Milvus proxy will be scheduled on nodes with component=proxy label
  nodeSelector:
    component: proxy
```

2. **Query Node**:
```yaml
queryNode:
  # Milvus query node will be scheduled on nodes with component=query and gpu=true label
  nodeSelector:
    component: query
    gpu: "true"
```

3. **Index Node**:
```yaml
indexNode:
  # Milvus index node will be scheduled on nodes with component=index label
  nodeSelector:
    component: index
```

4. **Data Node**:
```yaml
dataNode:
  # Milvus data node will be scheduled on nodes with component=data label
  nodeSelector:
    component: data
```

5. **Mix Coordinator**:
```yaml
mixCoordinator:
  # Milvus mix coordinator will be scheduled on nodes with component=coordinator label
  nodeSelector:
    component: coordinator
```

6. **Standalone** (for standalone mode):
```yaml
standalone:
  # Milvus standalone will be scheduled on nodes with deployment=standalone label
  nodeSelector:
    deployment: standalone
```

## Dependencies Node Selectors

### MinIO
Configure node selector for MinIO:
```yaml
minio:
  # MinIO will be scheduled on nodes with storage=high-performance label
  nodeSelector:
    storage: high-performance
    component: storage
```

### Etcd
Configure node selector for etcd cluster:
```yaml
etcd:
  # Etcd will be scheduled on nodes with component=etcd and storage=fast label
  nodeSelector:
    component: etcd
    storage: fast
```

### Pulsar (if enabled)
Configure node selector for Pulsar components:
```yaml
pulsar:
  zookeeper:
    # Pulsar zookeeper will be scheduled on nodes with component=zookeeper label
    nodeSelector:
      component: zookeeper
  
  bookkeeper:
    # Pulsar bookkeeper will be scheduled on nodes with component=bookkeeper and storage=fast label
    nodeSelector:
      component: bookkeeper
      storage: fast
  
  broker:
    # Pulsar broker will be scheduled on nodes with component=broker label
    nodeSelector:
      component: broker
  
  proxy:
    # Pulsar proxy will be scheduled on nodes with component=pulsar-proxy label
    nodeSelector:
      component: pulsar-proxy

  autorecovery:
    # Pulsar autorecovery will be scheduled on nodes with component=autorecovery label
    nodeSelector:
      component: autorecovery
```

### Kafka (if enabled)
Configure node selector for Kafka:
```yaml
kafka:
  # Kafka will be scheduled on nodes with component=kafka and storage=fast label
  nodeSelector:
    component: kafka
    storage: fast
  
  zookeeper:
    # Kafka zookeeper will be scheduled on nodes with component=zookeeper label
    nodeSelector:
      component: zookeeper
```

## Important Notes

1. Component-specific node selectors take precedence over global node selectors.
2. Ensure that nodes with matching labels exist in your Kubernetes cluster.
3. Use consistent labeling strategies across your cluster.
4. Consider using node selectors in conjunction with node affinity for more complex scheduling requirements.
5. Test your node selector configuration in a non-production environment first.