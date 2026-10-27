# Deployment Groups and Resource Group Guide

## Overview

Milvus Helm supports deployment groups for splitting selected Milvus components into multiple Kubernetes Deployments. A deployment group is a Kubernetes deployment unit. It can carry its own replica count, labels, annotations, environment variables, and scheduling rules.

Deployment groups are independent from Milvus resource groups. If a group should join a Milvus resource group, inject the corresponding Milvus environment variable in that group and configure Milvus load settings explicitly.

## Supported Components

The following components support multiple deployment groups:

- `proxy.groups`
- `dataNode.groups`
- `queryNode.groups`
- `streamingNode.groups`

`mixCoordinator` always renders a single Deployment. Use `mixCoordinator.labels`, `mixCoordinator.annotations`, and the normal scheduling fields to customize that Deployment.

When groups are configured, each group renders one Deployment named with the group suffix, for example `my-release-milvus-proxy-az1`. Each group also gets the reserved selector label `milvus.io/deployment-group: <group-name>` so Deployment selectors do not overlap. Component Services keep selecting all pods for the component.

## Group Fields

Each group can use these fields for `proxy`, `dataNode`, `queryNode`, and `streamingNode`:

```yaml
name: az1
replicas: 1
labels: {}
annotations: {}
extraEnv: []
nodeSelector: {}
affinity: {}
tolerations: []
topologySpreadConstraints: []
```

`name` should be unique within the component. Group labels are added to the Deployment and pod template. Scheduling fields in a group override the component-level scheduling fields for that group. If a group does not set a scheduling field, the component-level value is used, then the global value is used.

For `proxy`, `dataNode`, and `queryNode`, enabling HPA renders one HPA per group. Each HPA targets the Deployment for that group.

## Split Components by AZ

This example splits Proxy and DataNode by availability zone. Labels are user-defined and can follow your own naming scheme.

```yaml
proxy:
  groups:
    - name: az1
      replicas: 1
      labels:
        topology.milvus.io/az: az1
      nodeSelector:
        topology.kubernetes.io/zone: us-east-1a
    - name: az2
      replicas: 1
      labels:
        topology.milvus.io/az: az2
      nodeSelector:
        topology.kubernetes.io/zone: us-east-1b

dataNode:
  groups:
    - name: az1
      replicas: 1
      labels:
        topology.milvus.io/az: az1
      nodeSelector:
        topology.kubernetes.io/zone: us-east-1a
    - name: az2
      replicas: 1
      labels:
        topology.milvus.io/az: az2
      nodeSelector:
        topology.kubernetes.io/zone: us-east-1b
```

## Split QueryNode and StreamingNode by Milvus Resource Group

Milvus resource group membership is controlled by the `MILVUS_SERVER_LABEL_RESOURCE_GROUP` environment variable. The Helm group itself does not imply a Milvus resource group, and the group `replicas` value is only the Kubernetes pod count for that Deployment.

```yaml
queryNode:
  groups:
    - name: rg-a-az1
      replicas: 1
      labels:
        topology.milvus.io/az: az1
      nodeSelector:
        topology.kubernetes.io/zone: us-east-1a
      extraEnv:
        - name: MILVUS_SERVER_LABEL_RESOURCE_GROUP
          value: rg-a
    - name: rg-b-az2
      replicas: 1
      labels:
        topology.milvus.io/az: az2
      nodeSelector:
        topology.kubernetes.io/zone: us-east-1b
      extraEnv:
        - name: MILVUS_SERVER_LABEL_RESOURCE_GROUP
          value: rg-b

streamingNode:
  groups:
    - name: rg-a-az1
      replicas: 1
      labels:
        topology.milvus.io/az: az1
      nodeSelector:
        topology.kubernetes.io/zone: us-east-1a
      extraEnv:
        - name: MILVUS_SERVER_LABEL_RESOURCE_GROUP
          value: rg-a
    - name: rg-b-az2
      replicas: 1
      labels:
        topology.milvus.io/az: az2
      nodeSelector:
        topology.kubernetes.io/zone: us-east-1b
      extraEnv:
        - name: MILVUS_SERVER_LABEL_RESOURCE_GROUP
          value: rg-b
```

## Configure Multi-Replica Serving

Deployment groups and Milvus resource groups solve different parts of the serving plan.

- AZ isolation is a Kubernetes scheduling concern. Use deployment groups, labels, and node selectors to place pods in different availability zones.
- Resource group isolation is a Milvus serving concern. Use `MILVUS_SERVER_LABEL_RESOURCE_GROUP` to let QueryNode and StreamingNode join specific Milvus resource groups.
- Replica management is a Milvus load concern. Use global Milvus load config to decide how many query replicas should exist and which resource groups should serve them.

Do not use the Helm group `replicas` field as the Milvus query replica count. The Helm value only controls Kubernetes pod count for that Deployment.

### Milvus Load Configs

The procedures below use these Milvus configuration keys:

| Key | Meaning |
| --- | --- |
| `queryCoord.clusterLevelLoadReplicaNumber` | Global query replica count. For example, `2` means Milvus should keep two query replicas by default at the cluster level. |
| `queryCoord.clusterLevelLoadResourceGroups` | Comma-separated target Milvus resource groups for cluster-level load placement. The number of resource groups should be at least the configured replica count. |
| `queryCoord.clusterLevelLoadForceOverrideUserReplicaMode` | When `true`, Milvus uses the global replica count and resource-group list as the cluster-level serving policy. Use this when the operator wants the global policy to be enforced consistently. |
| `streaming.primaryResourceGroup` | Target resource group for WAL primary placement. When set, WAL operations use StreamingNodes in that resource group. |
| `streaming.strictResourceGroupIsolation.enabled` | When `true`, StreamingNode assignment follows resource-group isolation strictly. If a replica resource group has no matching StreamingNode resource group, that replica will not receive a streaming query node assignment. |

You can update these configs through the Milvus configuration management API. The management API is served from the MixCoord management port, usually `<mixcoord-host>:9091`. Use direct `etcdctl` writes only when the management endpoint is unavailable or your operation runbook already manages Milvus dynamic config through etcd.

```bash
curl -X POST http://<mixcoord-host>:9091/management/config/alter \
  -H 'Content-Type: application/json' \
  -d '{
    "configs": [
      {"key": "queryCoord.clusterLevelLoadReplicaNumber", "value": "2"},
      {"key": "queryCoord.clusterLevelLoadResourceGroups", "value": "rg-a,rg-b"},
      {"key": "queryCoord.clusterLevelLoadForceOverrideUserReplicaMode", "value": "true"},
      {"key": "streaming.primaryResourceGroup", "value": "rg-a"},
      {"key": "streaming.strictResourceGroupIsolation.enabled", "value": "true"}
    ]
  }'
```

To inspect the current values:

```bash
curl 'http://<mixcoord-host>:9091/management/config/get?keys=queryCoord.clusterLevelLoadReplicaNumber,queryCoord.clusterLevelLoadResourceGroups,streaming.primaryResourceGroup'
```

Equivalent etcd writes:

```bash
ETCDCTL_API=3 etcdctl --endpoints=http://<etcd-endpoint>:2379 put \
  by-dev/config/queryCoord.clusterLevelLoadReplicaNumber 2
ETCDCTL_API=3 etcdctl --endpoints=http://<etcd-endpoint>:2379 put \
  by-dev/config/queryCoord.clusterLevelLoadResourceGroups rg-a,rg-b
ETCDCTL_API=3 etcdctl --endpoints=http://<etcd-endpoint>:2379 put \
  by-dev/config/queryCoord.clusterLevelLoadForceOverrideUserReplicaMode true
ETCDCTL_API=3 etcdctl --endpoints=http://<etcd-endpoint>:2379 put \
  by-dev/config/streaming.primaryResourceGroup rg-a
ETCDCTL_API=3 etcdctl --endpoints=http://<etcd-endpoint>:2379 put \
  by-dev/config/streaming.strictResourceGroupIsolation.enabled true
```

### Step 1: Create AZ-Isolated Capacity

Add deployment groups for the AZs that should host serving capacity.

What happens: Helm renders separate Kubernetes Deployments. Each Deployment has its own scheduling rules, so Kubernetes can place the pods in the intended AZ. The global Milvus replica placement does not change yet.

```yaml
queryNode:
  groups:
    - name: rg-a-az1
      replicas: 1
      nodeSelector:
        topology.kubernetes.io/zone: us-east-1a
      extraEnv:
        - name: MILVUS_SERVER_LABEL_RESOURCE_GROUP
          value: rg-a
    - name: rg-b-az2
      replicas: 1
      nodeSelector:
        topology.kubernetes.io/zone: us-east-1b
      extraEnv:
        - name: MILVUS_SERVER_LABEL_RESOURCE_GROUP
          value: rg-b
```

Configure `streamingNode.groups` with the same resource-group and AZ plan when StreamingNode also needs RG isolation.

### Step 2: Apply the Helm Upgrade

Apply the chart change that creates the deployment groups.

What happens: Kubernetes creates or updates the component Deployments. QueryNode and StreamingNode pods start and register into the Milvus resource group declared by `MILVUS_SERVER_LABEL_RESOURCE_GROUP`. The current global Milvus load config remains unchanged until you update it.

```bash
helm upgrade <release> <chart> -n <namespace> -f user.yaml
```

### Step 3: Set the Default Multi-Replica Policy

Set the desired global query replica count and the resource groups that should host those replicas.

What happens: QueryCoord starts converging the global serving plan to the configured replica count and target resource groups. Streaming uses the configured primary resource group when strict RG isolation is enabled.

```bash
curl -X POST http://<mixcoord-host>:9091/management/config/alter \
  -H 'Content-Type: application/json' \
  -d '{
    "configs": [
      {"key": "queryCoord.clusterLevelLoadReplicaNumber", "value": "2"},
      {"key": "queryCoord.clusterLevelLoadResourceGroups", "value": "rg-a,rg-b"},
      {"key": "queryCoord.clusterLevelLoadForceOverrideUserReplicaMode", "value": "true"},
      {"key": "streaming.primaryResourceGroup", "value": "rg-a"},
      {"key": "streaming.strictResourceGroupIsolation.enabled", "value": "true"}
    ]
  }'
```

### Step 4: Wait for Load-Config Compliance

Check the compliance endpoint before treating the new serving plan as ready.

What happens: Milvus reports whether the expected replica count, target resource groups, query visibility, shard serviceability, old-resource cleanup, and primary RG placement have converged.

```bash
curl http://<mixcoord-host>:9091/management/replica/loadconfig/compliance
```

### Step 5: Keep Replica Placement in Milvus

Manage replica count and resource-group placement through Milvus load config instead of adding or removing Helm deployment groups.

What happens: Helm continues to describe available Kubernetes capacity. Milvus remains responsible for the global replica count and target resource-group placement.

## Per-Replica Upgrading

Use this procedure when global multi-replica serving should move from old resource groups to new resource groups one replica at a time. The example starts with two serving replicas on `old_rg_a` and `old_rg_b`, then moves them to `new_rg_a` and `new_rg_b`.

The rule is:

- Expansion phase for one replica: prepare the new node resource with Helm, then increase the Milvus replica config by one, then wait for compliance.
- Shrink phase for the same replica: decrease the Milvus replica config by one, then wait for compliance, then remove the old node resource with Helm.

Repeat the expansion and shrink sequence for each replica pair.

### Step 1: Confirm the Current State

```bash
curl 'http://<mixcoord-host>:9091/management/config/get?keys=queryCoord.clusterLevelLoadReplicaNumber,queryCoord.clusterLevelLoadResourceGroups,streaming.primaryResourceGroup'
```

Expected state:

- `queryCoord.clusterLevelLoadReplicaNumber` is `2`.
- `queryCoord.clusterLevelLoadResourceGroups` is `old_rg_a,old_rg_b`.
- `streaming.primaryResourceGroup` points to the old primary group, for example `old_rg_a`.

What happens: no serving state changes. This step only confirms the starting point before the upgrade.

### Step 2: Add Capacity for `new_rg_a`

Add the new QueryNode and StreamingNode deployment groups for `new_rg_a` in `user.yaml`, then apply the Helm upgrade.

What happens: Kubernetes creates the new pods. The new pods register into `new_rg_a`, but Milvus does not place a serving replica there until the global load config includes `new_rg_a`.

```bash
helm upgrade <release> <chart> -n <namespace> -f user.yaml
```

### Step 3: Expand Milvus Replicas for `new_rg_a`

Increase the global replica count from `2` to `3` and add `new_rg_a` to the target resource-group list.

```bash
curl -X POST http://<mixcoord-host>:9091/management/config/alter \
  -H 'Content-Type: application/json' \
  -d '{
    "configs": [
      {"key": "queryCoord.clusterLevelLoadReplicaNumber", "value": "3"},
      {"key": "queryCoord.clusterLevelLoadResourceGroups", "value": "old_rg_a,old_rg_b,new_rg_a"}
    ]
  }'
```

What happens: QueryCoord starts creating one additional serving replica on `new_rg_a`. The existing replicas on `old_rg_a` and `old_rg_b` remain available while the new replica is being prepared.

### Step 4: Wait Until the Expanded State Is Ready

```bash
curl http://<mixcoord-host>:9091/management/replica/loadconfig/compliance
```

What happens: Milvus may report `NotReady` while the new replica is still loading or becoming serviceable. Continue polling this endpoint until it reports `Ready`. At this point `old_rg_a`, `old_rg_b`, and `new_rg_a` are serving according to the expanded config.

### Step 5: Shrink Milvus Replicas Away from `old_rg_a`

Reduce the global replica count back to `2` and remove `old_rg_a` from the target resource-group list.

If `old_rg_a` is the current primary streaming group, update `streaming.primaryResourceGroup` in the same operation window.

```bash
curl -X POST http://<mixcoord-host>:9091/management/config/alter \
  -H 'Content-Type: application/json' \
  -d '{
    "configs": [
      {"key": "streaming.primaryResourceGroup", "value": "new_rg_a"},
      {"key": "queryCoord.clusterLevelLoadReplicaNumber", "value": "2"},
      {"key": "queryCoord.clusterLevelLoadResourceGroups", "value": "old_rg_b,new_rg_a"}
    ]
  }'
```

What happens: Milvus starts releasing the serving replica on `old_rg_a` and converging to the `old_rg_b,new_rg_a` target. Kubernetes resources for `old_rg_a` are still present during this step.

### Step 6: Wait Until the Shrunk State Is Ready

```bash
curl http://<mixcoord-host>:9091/management/replica/loadconfig/compliance
```

What happens: Milvus reports `Ready` after the target replica count is back to `2`, replicas are placed on `old_rg_b,new_rg_a`, query visibility is ready, shard leaders are serviceable, `old_rg_a` resources are drained, and the primary RG placement is ready when configured.

### Step 7: Remove `old_rg_a` Capacity

Remove the old QueryNode and StreamingNode deployment groups for `old_rg_a` from `user.yaml`, then apply the Helm upgrade.

```bash
helm upgrade <release> <chart> -n <namespace> -f user.yaml
```

What happens: Kubernetes removes the old pods for `old_rg_a`. The serving plan already excludes `old_rg_a`, so removing the old Deployments should not change Milvus replica placement.

### Step 8: Repeat for `old_rg_b` and `new_rg_b`

Use the same sequence to move the remaining replica from `old_rg_b` to `new_rg_b`: add `new_rg_b` capacity with Helm, expand the Milvus replica config by one and wait for compliance, shrink the config away from `old_rg_b` and wait for compliance, then remove `old_rg_b` capacity with Helm.

What happens: only one replica pair is changed in each round. Existing serving replicas stay in place while the new replica becomes ready, and old node resources are removed only after Milvus no longer targets that old resource group.
