# Overview

> 运维特征

```mermaid
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