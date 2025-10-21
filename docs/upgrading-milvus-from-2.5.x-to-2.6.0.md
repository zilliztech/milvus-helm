# Upgrading Milvus from 2.5.x to 2.6.0


This guide explains how to upgrade an **open-source Milvus cluster** deployed with Helm from version 2.5.x to 2.6.0.  

**Important Note**: This upgrade process requires downtime. Your Milvus cluster will be unavailable during the upgrade.

---

## 1. Scope & Assumptions

* Your current cluster is **2.5.x** and was installed with the official Milvus Helm chart.
* You are upgrading **directly** to **2.6.0**; intermediate versions are not required.
* All Milvus components are managed by **Kubernetes Deployments** (the default chart behaviour).

---

## 2. Pre-upgrade Checklist

1. **Confirm cluster health**

   ```bash
   kubectl get pods -n <NAMESPACE>
   ```

   All pods should be in `Running` state.

2. **Back up critical data**

   • Before proceeding with the upgrade, ensure you have a complete backup of your Milvus data.

3. **Export current Helm values**

   ```bash
   helm get values <RELEASE> -n <NAMESPACE> -o yaml > milvus-2.5.values.yaml
   ```

4. **Verify resource quotas**

   New components may need additional CPU/Memory. Make sure your cluster has spare capacity.

---

## 3. Topology Changes

| 2.5.x Component | 2.6.0 Component | Change |
|-----------------|-----------------|--------|
| RootCoord       | **MixCoord**    | Merged into MixCoord |
| QueryCoord      |                 | Merged into MixCoord |
| DataCoord       |                 | Merged into MixCoord |
| IndexNode       | **DataNode**    | Merged into DataNode |
| QueryNode       | QueryNode       | Rolling restart |
| DataNode        | DataNode        | Rolling restart (now also does indexing) |
| Proxy           | Proxy           | Rolling restart |
| –               | **StreamingNode** | New |

As a result the following Deployments are **removed**:

* `rootcoord`, `querycoord`, `datacoord`, `indexnode`

The following Deployments are **created**:

* `mixcoord`, `streamingnode`

---

## 4. Upgrade Procedure

```bash
# 1. Add/Update Milvus repo (if not already)
helm repo add zilliztech https://zilliztech.github.io/milvus-helm/
helm repo update

# 2. Perform the upgrade
helm upgrade <RELEASE> zilliztech/milvus \
  --namespace <NAMESPACE> \
  --reset-then-reuse-values
```

Explanation of the key flag:

* `--reset-then-reuse-values`  
  • Drops the 2.5.x defaults that no longer exist (e.g., individual *Coord* and *IndexNode* configs).  
  • Keeps any **explicit** user-defined settings (resources, persistence, etc.).

---

## 5. Monitor the Rollout

```bash
# Watch pod status
kubectl get pods -n <NAMESPACE> -w
```

Expected sequence:

1. Pods for `rootcoord`, `querycoord`, `datacoord`, `indexnode` terminate.
2. New pods for `mixcoord` and `streamingnode` start.
3. Existing `proxy`, `datanode`, `querynode` pods are recreated one at a time.

Wait until **all** pods report `Running` and all containers are `READY 1/1`.

---

## 6. Post-upgrade Tasks

**Functional smoke test**

   ```python
   from pymilvus import Milvus, connections
   connections.connect(uri="tcp://<load-balancer>:19530")
   print(connections.get_connection_addr())
   ```

---

## 9. Further Reading

* Release notes: https://milvus.io/docs/release_notes/v2.6.0.md
* Helm chart docs: https://github.com/milvus-io/milvus-helm
* Backup & Restore guide: https://milvus.io/docs/backup.md

---

Happy vector searching!