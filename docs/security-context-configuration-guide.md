# Milvus Helm Chart SecurityContext Configuration Guide

## Table of Contents

- [Priority Hierarchy](#priority-hierarchy)
- [Global SecurityContext](#global-securitycontext)
- [Component-Specific SecurityContext](#component-specific-securitycontext)
- [Dependencies SecurityContext](#dependencies-securitycontext)
- [Important Notes](#important-notes)

## Priority Hierarchy

When configuring securityContext in Milvus, please note the following priority hierarchy:

1. Individual component configurations (proxy, queryNode, etc.) take precedence over global configurations. Component-specific securityContext will completely override, *not merge with*, global securityContext.
2. If no component-specific securityContext is defined, the global securityContext will be applied.

## Global SecurityContext

At the top level, you can set global securityContext that applies to all Milvus components:

```yaml
securityContext: {}  # Global securityContext applied to all Milvus components
```

### Explanation and Example Configuration

SecurityContext defines privilege and access control settings for a Pod or Container. Here's what you need to know:

- **Pod SecurityContext**: Defines security settings that apply to all containers in a pod
- **Container SecurityContext**: Defines security settings specific to a container
- SecurityContext is crucial for running containers with minimal privileges and proper access controls

Here's an example of a global securityContext configuration:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000
```

This configuration:
1. Ensures the pod runs as a non-root user (1000)
2. Sets the group ID to 1000
3. Sets the filesystem group to 1000

## Component-Specific SecurityContext

Each Milvus component can override the global securityContext with its own specific configuration:

### Core Components

#### Proxy
```yaml
proxy:
  securityContext: {}  # Overrides global securityContext for proxy
```

#### MixCoordinator
```yaml
mixCoordinator:
  securityContext: {}  # Overrides global securityContext for mixCoordinator
```

#### Query Node
```yaml
queryNode:
  securityContext: {}  # Overrides global securityContext for queryNode
```

#### Index Node
```yaml
indexNode:
  securityContext: {}  # Overrides global securityContext for indexNode
```

#### Data Node
```yaml
dataNode:
  securityContext: {}  # Overrides global securityContext for dataNode
```

### Optional Components

#### Standalone (if not using cluster mode)
```yaml
standalone:
  securityContext: {}  # Overrides global securityContext for standalone
```

#### Streaming Node (if enabled)
```yaml
streamingNode:
  securityContext: {}  # Overrides global securityContext for streamingNode
```

## Important Notes

1. Always test securityContext configurations in a non-production environment first
2. Consider the impact on file permissions and access controls
3. Ensure proper user/group IDs are set for your environment
4. Be cautious when modifying security settings as they can affect application functionality
5. Follow the principle of least privilege when configuring securityContext
6. Remember that some components might require specific security settings to function properly 