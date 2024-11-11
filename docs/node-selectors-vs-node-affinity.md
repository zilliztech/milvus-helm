## Node Selectors vs Node Affinity

### Node Selectors are best used for:
1. Simple, hard constraints that are always required
2. Single label-based selection
3. Basic scenarios where you just need pods to run on specific nodes
4. When you want a straightforward, easy-to-understand configuration

Example node selector:
```yaml
nodeSelector:
  disktype: ssd
```

### Node Affinity is better for:
1. Complex scheduling requirements with multiple conditions
2. Soft preferences (preferredDuringSchedulingIgnoredDuringExecution)
3. More expressive matching rules using operators like In, NotIn, Exists
4. When you need flexibility in node selection
5. When you want to specify weight/priority to different preferences

Example node affinity:
```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/os
          operator: In
          values:
          - linux
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 1
      preference:
        matchExpressions:
        - key: disktype
          operator: In
          values:
          - ssd
```

General rule of thumb:
- Use node selectors for simple, permanent requirements
- Use node affinity for complex requirements or when you need flexibility in scheduling decisions