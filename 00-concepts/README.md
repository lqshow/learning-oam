# Overview

为了利于 `Kubernetes` 生态内的 `CRD` 接入， 新版 OAM Spec(v0.3.0) `v1alpha2`  中彻底统一调整为引用数据模型，通过在 `XXX`Definition 的定义里，描述了一个引用的关系，使用 Reference 模型定义 Workload、Trait 和 Scope。

- ComponentDefinition
- WorkloadDefinition
- TraitDefinition
- ScopeDefinition

`OAM` 几个核心概念的模型定义都是支持可扩展的，平台方可以根据自己的业务需求按需定义，然后通过应用关系进行扩展

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

## 应用部署流程

### 1. 先定义 `ComponentDefinition`

> 在 k8s 平台的实现中，首先需要事先定义一个叫 `componentdefinitions.core.oam.dev` 的 CRD。

平台先定义一批 `ComponentDefinition`，每个  `ComponentDefinition` 的 `schematic` 会有具体的 Spec，  `schematic` 目前用于比较多的是基于`CUE`的组件定义。

<details>
	<summary>下面是一个完整的基于CUE的组件定义示例:</summary>

`spec.workload.definition`  和  `spec.workload.type` 互斥，只能二选一作为一个定义

```yaml
apiVersion: core.oam.dev/v1beta1
kind: ComponentDefinition
metadata:
  name: webserver
  annotations:
    definition.oam.dev/description: "webserver is a combo of Deployment + Service"
spec:
  workload:
    definition:
      apiVersion: apps/v1
      kind: Deployment
  schematic:
    cue:
      template: |
        output: {
            apiVersion: "apps/v1"
            kind:       "Deployment"
            spec: {
                selector: matchLabels: {
                    "app.oam.dev/component": context.name
                }
                template: {
                    metadata: labels: {
                        "app.oam.dev/component": context.name
                    }
                    spec: {
                        containers: [{
                            name:  context.name
                            image: parameter.image

                            if parameter["cmd"] != _|_ {
                                command: parameter.cmd
                            }

                            if parameter["env"] != _|_ {
                                env: parameter.env
                            }

                            if context["config"] != _|_ {
                                env: context.config
                            }

                            ports: [{
                                containerPort: parameter.port
                            }]

                            if parameter["cpu"] != _|_ {
                                resources: {
                                    limits:
                                        cpu: parameter.cpu
                                    requests:
                                        cpu: parameter.cpu
                                }
                            }
                        }]
                }
                }
            }
        }
        // an extra template
        outputs: service: {
            apiVersion: "v1"
            kind:       "Service"
            spec: {
                selector: {
                    "app.oam.dev/component": context.name
                }
                ports: [
                    {
                        port:       parameter.port
                        targetPort: parameter.port
                    },
                ]
            }
        }
        parameter: {
            image: string
            cmd?: [...string]
            port: *80 | int
            env?: [...{
                name:   string
                value?: string
                valueFrom?: {
                    secretKeyRef: {
                        name: string
                        key:  string
                    }
                }
            }]
            cpu?: string
        }
```
</details>

然后将以上的 `ComponentDefinition` CR 安装到平台集群内。

### 2. 再定义 `Application`

应用开发者选择适合自己应用的一个 `Component`，填充具体的参数(`properties` 对象针对 `component parameters`)，即可以将应用拉起来

<details>
	<summary>应用程序中部署该组件</summary>

.spec.components[0].type 的值为 `webserver` 为第一步 `ComponentDefinition` 的定义名称

```yaml
apiVersion: core.oam.dev/v1beta1
kind: Application
metadata:
  name: webserver-demo
spec:
  components:
    - name: hello-world             # instance name
      type: webserver               # reference to the component definition
      properties:                   # parameter values
        image: crccheck/hello-world
        port: 8000
        env:
        - name: "foo"
          value: "bar"
        cpu: "100m"
```
</details>

然后将以上 `Application` CR 安装到平台集群内，一个应用就生成了。

## Notes

1. `ComponentDefinition` 实体已经被引入以取代以前的 `WorkloadDefinition`。它提供了 `schematic`（示意图）信息，用于描述实际的执行计划，并以底层不可知的格式公开参数。
2. `Application` 实体 `components` 直接引用 `ComponentDefinition`, 且绑定 `traints` 以及 `scopes`
3. 参数传递使用 `jsonPath`

## References

- [CRD](../01-CRD/README.md)