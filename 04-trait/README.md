# Overview

> 应用特征

运维侧的概念，比如扩容策略，发布策略，这些策略通过一个叫做 `Traits` 的 API 暴露给用户。

我们需要将 `Traits` 应用特征关联到应用组件 `Components` 上。

任何管理和运维 Workload 的组件和能力，都可以定义为一个 `Trait`。

<details>
<summary>mermaid code</summary>

```
flowchart LR
	classDef runtime fill:#fff,color:#fff,stroke-dasharray: 2 2;
	
	subgraph app
		direction LR
		subgraph trait[Traits]
			direction RL
			Scaling[[Scaling]]
			Rollout[[Rollout]]
			sidecar[[Sidecar]]
			Traffic[[Traffic]]
			Ingress[[Ingress]]
		end

		subgraph component[Components]
			Deployment
			Function
			Task
		end
	end
	
	subgraph platform[OAM Platform]
	end
	
	class app runtime
	trait -- ApplicationConfiguration --> component
	app -- Deploy --> platform
```
</details>

## 统一用 TraitDefinition 定义 Trait

```yaml
apiVersion: core.oam.dev/v1alpha2
kind: TraitDefinition
metadata:
  name: manualscalertrait.core.oam.dev
spec:
  appliesToWorkloads:
    - containerizedworkload.core.oam.dev
  definitionRef:
    name: manualscalertrait.core.oam.dev
```