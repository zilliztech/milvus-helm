# Milvus Affinity Configuration Guide

## Overview
This guide explains how to configure affinity settings for both Milvus components and its dependencies (MinIO, etcd, Pulsar, Kafka) in your Kubernetes deployment.

## Table of Contents
- [Node Selectors vs Node Affinity](#node-selectors-vs-node-affinity)
- [Priority Hierarchy](#priority-hierarchy)
- [Global Affinity Configuration](#global-affinity-configuration)
- [Milvus Components Affinity](#milvus-components-affinity)
- [Dependencies Affinity Configuration](#dependencies-affinity-configuration)
- [Affinity Types and Examples](#affinity-types-and-examples)
- [Best Practices](#best-practices)

## Node Selectors vs Node Affinity

Please refer to [Node Selectors vs Node Affinity](./node-selectors-vs-node-affinity.md) for more details.

### Priority Hierarchy

When configuring affinity rules in Milvus, please note the following priority hierarchy:

1. Individual component configurations (proxy, queryNode, etc.) take precedence over global configurations. Component-specific affinity rules will completely *override*, *not merge with*, global affinity settings.
2. If no component-specific affinity is defined, the global affinity settings will be applied.

## Global Affinity Configuration

The global affinity configuration applies to all Milvus core components by default (but does not affect dependencies like MinIO, etcd, Pulsar, or Kafka):

```yaml
# Global affinity configuration
affinity:
  nodeAffinity:
    # HARD requirement: Must run in specific regions
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        # Must run on nodes with topology.kubernetes.io/region=us-east-1 or us-west-1 label
        - key: topology.kubernetes.io/region
          operator: In
          values:
          - us-east-1
          - us-west-1
    # SOFT preference: Prefer nodes with SSD if available
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      preference:
        matchExpressions:
        # Prefer nodes with disk-type=ssd label
        - key: disk-type
          operator: In
          values:
          - ssd
```

You can configure both `requiredDuringSchedulingIgnoredDuringExecution` and `preferredDuringSchedulingIgnoredDuringExecution` in the same nodeAffinity specification, or use just one depending on your needs:

1. `requiredDuringSchedulingIgnoredDuringExecution`
   - These are "hard" requirements
   - Must be satisfied for the pod to be scheduled
   - Pod will not be scheduled if no nodes match these rules

2. `preferredDuringSchedulingIgnoredDuringExecution`
   - These are "soft" preferences
   - Used to prioritize nodes that have already passed the required rules
   - Helps the scheduler choose between multiple eligible nodes

> **Note**: Dependencies must have their affinity rules configured separately in their respective sections.

## Milvus Components Affinity

### Core Components

1. **Proxy**
```yaml
proxy:
  affinity:
    podAffinity:
      # ...
    podAntiAffinity:
      # ...
    nodeAffinity:
      # ...
```

2. **Query Node**
```yaml
queryNode:
  affinity:
    podAffinity:
      # ...
    podAntiAffinity:
      # ...
    nodeAffinity:
      # ...
```

### Coordinator Components

1. **Mix Coordinator** (recommended for cluster mode)
```yaml
mixCoordinator:
  affinity:
    podAffinity:
      # ...
    podAntiAffinity:
      # ...
    nodeAffinity:
      # ...
```

2. **Individual Coordinators** (if not using mixCoordinator)
```yaml
rootCoordinator:
  affinity:
    # Root coordinator affinity rules
queryCoordinator:
  affinity:
    # Query coordinator affinity rules
indexCoordinator:
  affinity:
    # Index coordinator affinity rules
dataCoordinator:
  affinity:
    # Data coordinator affinity rules
```

### Worker Components

1. **Data Node**
```yaml
dataNode:
  affinity:
    podAffinity:
      # ...
    podAntiAffinity:
      # ...
    nodeAffinity:
      # ...
```

2. **Index Node**
```yaml
indexNode:
  affinity:
    podAffinity:
      # ...
    podAntiAffinity:
      # ...
    nodeAffinity:
      # ...
```

## Dependencies Affinity Configuration

### 1. MinIO
```yaml
minio:
  affinity:
    podAffinity:
      # ...
    podAntiAffinity:
      # ...
    nodeAffinity:
      # ...
```

### 2. Etcd
```yaml
etcd:
  affinity:
    podAffinity:
      # ...
    podAntiAffinity:
      # ...
    nodeAffinity:
      # ...
```

### 3. Pulsar
```yaml
pulsar:
  broker:
    affinity:
      podAffinity:
        # ...
      podAntiAffinity:
        # ...
      nodeAffinity:
        # ...

  
  bookkeeper:
    affinity:
      podAffinity:
        # ...
      podAntiAffinity:
        # ...
      nodeAffinity:
        # ...
  
  zookeeper:
    affinity:
      podAffinity:
        # ...
      podAntiAffinity:
        # ...
      nodeAffinity:
        # ...

  autorecovery:
    affinity:
      podAffinity:
        # ...
      podAntiAffinity:
        # ...
      nodeAffinity:
        # ...
```

### 4. Kafka (if using Kafka instead of Pulsar)
```yaml
kafka:
  affinity:
      podAffinity:
        # ...
      podAntiAffinity:
        # ...
      nodeAffinity:
        # ...
  
  zookeeper:
    affinity:
      podAffinity:
        # ...
      podAntiAffinity:
        # ...
      nodeAffinity:
        # ...
```

## Affinity Types and Examples

### 1. Node Affinity
```yaml
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      # Must run on nodes with kubernetes.io/instance-type=m5.2xlarge or m5.4xlarge label
      - key: kubernetes.io/instance-type
        operator: In
        values:
        - m5.2xlarge
        - m5.4xlarge
```

### 2. Pod Affinity
```yaml
podAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchExpressions:
        # Must run on pods with app=cache label
        - key: app
          operator: In
          values:
          - cache
      topologyKey: kubernetes.io/hostname
```

### 3. Pod Anti-Affinity
```yaml
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      # Must run on pods with app=milvus label
      - key: app
        operator: In
        values:
        - milvus
    topologyKey: "kubernetes.io/hostname"
```

## Best Practices

### 1. High Availability for Dependencies
```yaml
# Distribute etcd across zones
etcd:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          # Avoid nodes that already have pods with app=etcd label
          - key: app
            operator: In
            values:
            - etcd
        topologyKey: "topology.kubernetes.io/zone"
```

### 2. Storage Performance
```yaml
# Co-locate MinIO with high-performance storage
minio:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          # Must run on nodes with storage-type=ssd label
          - key: storage-type
            operator: In
            values:
            - high-performance-storage
```

### 3. Message Queue Optimization
```yaml
# For Pulsar BookKeeper optimal performance
pulsar:
  bookkeeper:
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            # Must run on nodes with node-type=storage-optimized label
            - key: node-type
              operator: In
              values:
              - storage-optimized
```

### 4. Cross-Zone Distribution
```yaml
# Distribute coordinators across zones
mixCoordinator:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          # Avoid nodes that already have pods with component=coordinator label
          - key: component
            operator: In
            values:
            - coordinator
        topologyKey: "topology.kubernetes.io/zone"
```

### 5. Resource Isolation
```yaml
# Separate compute-intensive components
queryNode:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          # Must run on nodes with node-purpose=compute-optimized label
          - key: node-purpose
            operator: In
            values:
            - compute-optimized
```

Remember to:
- Test affinity rules in a non-production environment first
- Consider the impact on pod scheduling during updates
- Balance between availability and resource constraints
- Monitor the effectiveness of affinity rules
- Adjust based on your specific infrastructure and requirements