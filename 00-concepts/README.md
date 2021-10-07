# Overview

为了利于 `Kubernetes` 生态内的 `CRD` 接入， 新版 OAM Spec(v0.3.0) `v1alpha2`  中彻底统一调整为引用数据模型，通过在 `XXX`Definition 的定义里，描述了一个引用的关系，使用 Reference 模型定义 Workload、Trait 和 Scope。

- ComponentDefinition
- WorkloadDefinition
- TraitDefinition
- ScopeDefinition

`OAM` 几个核心概念的模型定义都是支持可扩展的，平台方可以根据自己的业务需求按需定义，然后通过应用关系进行扩展

**举个例子**

[以 Scope 为例子](#scope)

**基于 `Kubernetes` 平台实现的 OAM Runtime**

> 需要说明的是以上 `XXX`Definition 在 `Kubernetes` 世界里其实都是 `Custom Resource`（自定义资源），也就是 CR。
> 既然是 CR，在 `Kubernetes`  世界里每个 CR 都会有自己的 CRD（自定义资源的定义）

`spec.definitionRef.name`  可以直接引用一个 `CRD`，是 `Kubernetes` 里面 `CRD` 的名称。

**基于`非 Kubernetes` 平台实现的 OAM Runtime**

`spec.definitionRef.name`  可以理解为是一个索引，通过该索引找到对应的 `schema` 做检验

## Workload

> 统一用 `WorkloadDefinition`  定义  `Workload`

- `Component`  为  `Workload` 的实例，所有语法定义都是在 `WorkloadDefinition`  中引用的实际 CRD 定义的。

- 在 K8s 实现中，`WorkloadDefinition` 就是引用 CRD ，`Component.spec.workload` 里就是写 CRD 对应的实例 CR。
- `ContainerizedWorkload` 是核心的一个 `Workload`

## Trait

> 统一用 `TraitDefinition`  定义  `Trait`

## Scope

> 统一用 `ScopeDefinition`  定义  `Scope`

```yaml
apiVersion: core.oam.dev/v1beta1
kind: ScopeDefinition
metadata:
  name: healthscopes.core.oam.dev
spec:
  allowComponentOverlap: true
  definitionRef:
    # 名称引用的是集群内的一个 CRD.
    name: healthscopes.core.oam.dev
  workloadRefsPath: spec.workloadRefs
```

我们在 `Kubernetes`  集群内能够检索到 `healthscopes.core.oam.dev` 这个 CRD

```bash
kubectl get crd |{head -1; grep health;}
```

<details>
    <summary>Output</summary>

```bash
NAME                                                CREATED AT
healthscopes.core.oam.dev                           2021-07-25T12:36:23Z
```

</details>

同时理所当然也能检索到 `ScopeDefinition`  这个 `CR` 所对应的 `CRD`

```bash
kubectl get crd |{head -1; grep scopedefinition;}
```

<details>
	<summary>Output</summary>

```bash
NAME                                                CREATED AT
scopedefinitions.core.oam.dev                       2021-07-25T12:36:23Z
```

</details>

## Notes

1. `ComponentDefinition` 实体已经被引入以取代以前的 `WorkloadDefinition`。它提供了 `schematic`（示意图）信息，用于描述实际的执行计划，并以底层不可知的格式公开参数。
2. `Application` 实体 `components` 直接引用 `ComponentDefinition`, 且绑定 `traints` 以及 `scopes`
3. 参数传递使用 `jsonPath`

## References

- [CRD](../01-CRD/README.md)