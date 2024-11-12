# Milvus Helm Chart Tolerations Configuration Guide

## Table of Contents

- [Priority Hierarchy](#priority-hierarchy)
- [Global Tolerations](#global-tolerations)
- [Component-Specific Tolerations](#component-specific-tolerations)
- [Dependencies Tolerations](#dependencies-tolerations)
- [Important Notes](#important-notes)


## Priority Hierarchy

When configuring tolerations in Milvus, please note the following priority hierarchy:

1. Individual component configurations (proxy, queryNode, etc.) take precedence over global configurations. Component-specific tolerations will completely override, *not merge with*, global tolerations.
2. If no component-specific tolerations are defined, the global tolerations will be applied.

## Global Tolerations

At the top level, you can set global tolerations that apply to all Milvus components:

```yaml
tolerations: []  # Global tolerations applied to all Milvus components
```

### Explanation and Example Configuration

Tolerations allow pods to be scheduled on nodes with matching taints. Here's what you need to know:

- **Taints** are labels on nodes that repel certain pods
- **Tolerations** allow pods to ignore these taints and schedule on the nodes anyway
- Tolerations are useful for dedicating specific nodes to certain workloads

Here's an example of a global toleration configuration:

```yaml
tolerations:
  # Allow scheduling on nodes dedicated to Milvus
  - key: "dedicated"
    operator: "Equal"
    value: "milvus"
    effect: "NoSchedule"
    
  # Allow scheduling on nodes with high memory usage
  - key: "memory-intensive"
    operator: "Exists"
    effect: "PreferNoSchedule"
```

This configuration:
1. Allows pods to run on nodes tainted with `dedicated=milvus:NoSchedule`


##  Component-Specific Tolerations

Each Milvus component can override the global tolerations with its own specific configuration:

### Core Components

#### Proxy
```yaml
proxy:
  tolerations: []  # Overrides global tolerations for proxy
```

#### MixCoordinator
```yaml
mixCoordinator:
  tolerations: []  # Overrides global tolerations for mixCoordinator
```

#### Query Node
```yaml
queryNode:
  tolerations: []  # Overrides global tolerations for queryNode
```

#### Index Node
```yaml
indexNode:
  tolerations: []  # Overrides global tolerations for indexNode
```

#### Data Node
```yaml
dataNode:
  tolerations: []  # Overrides global tolerations for dataNode
```

### Optional Components

#### Standalone (if not using cluster mode)
```yaml
standalone:
  tolerations: []  # Overrides global tolerations for standalone
```

#### Streaming Node (if enabled)
```yaml
streamingNode:
  tolerations: []  # Overrides global tolerations for streamingNode
```

## Dependencies Tolerations

### MinIO
```yaml
minio:
  tolerations: []  # Specific tolerations for MinIO pods
```

### Etcd
```yaml
etcd:
  tolerations: []  # Specific tolerations for etcd pods
```

### Pulsar (if enabled)
```yaml
pulsar:
  tolerations: {}  # Specific tolerations for Pulsar
  
  # Component-specific tolerations
  zookeeper:
    tolerations: []
  
  bookkeeper:
    tolerations: []
    
  broker:
    tolerations: []
    
  proxy:
    tolerations: []
```

### Kafka (if enabled instead of Pulsar)
```yaml
kafka:
  tolerations: []  # Specific tolerations for Kafka brokers
  
  zookeeper:
    tolerations: []  # Specific tolerations for Kafka's ZooKeeper
```



## Important Notes

1. Always test toleration configurations in a non-production environment first
2. Consider the impact on pod scheduling and node resources
3. Ensure sufficient node capacity for components with specific tolerations
4. Remember that tolerations alone don't guarantee pod placement - consider using node affinity rules in conjunction with tolerations