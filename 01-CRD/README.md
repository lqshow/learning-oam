# Overview

尽管 `OAM` 的设计是与平台无关的，但是天生对 `Kubernetes` 平台更友好些，`OAM Spec` 的设计也更贴近于 `Kubernetes` 平台，因此平台开发者非常有必要了解下 `CRD`。

`OAM` 在基于 `Kubernetes` 平台的实现是基于 `CRD` 的一些概念，下面做下简单回顾。

`Kubernetes` 允许用户自定义自己的资源对象， 自定义资源 `CRD（Custom Resource Definition）` 可以扩展 Kubernetes API， 然后为自定义资源写一个对应的控制器，推出自己的声明式 API。

## 什么是 CRD？

`CRD` 本身是一种 `Kubernetes` 内置的资源类型，是 `CustomResourceDefinition` 的缩写，可以通过 `kubectl get crd` 命令查看集群内定义的 `CRD` 资源。

- 在 `Kubernetes` ，所有的东西都叫做资源（Resource），就是 Yaml 里 Kind 那项所描述的
- 但除了常见的 `Deployment` 之类的内置资源之外，`Kubernetes` 允许用户自定义资源（Custom Resource），也就是 `CR`
- `CRD` 其实并不是自定义资源，而是我们自定义资源的定义（来描述我们定义的资源是什么样子）

## CRD 能做什么？

一般情况下，我们利用 CRD 所定义的 CR 就是一个新的控制器，我们可以自定义控制器的逻辑，来做一些 Kubernetes 集群原生不支持的功能。

- 利用 CRD 所定义的 CR 就是一个新的控制器，我们可以自定义控制器的逻辑，来做一些 Kubernetes 集群原生不支持的功能。
- CRD 使得 Kubernetes 已有的资源和能力变成了乐高积木，我们很轻松就可以利用这些积木拓展 Kubernetes 原生不具备的能力。
- 其次是产品上，基于 Kubernetes 做的产品无法避免的需要让我们将产品术语向 Kube 术语靠拢，比如一个服务就是一个 Deployment，一个实例就是一个 Pod 之类。但是 CRD 允许我们自己基于产品创建概念（或者说资源），让 Kube 已有的资源为我们的概念服务，这可以使产品更专注与解决的场景，而不是如何思考如何将场景应用到 Kubernetes。
- CRD 允许我们基于已有的 Kubernetes 资源，拓展集群能力
- CRD 可以使我们自己定义一套成体系的规范，自造概念

## 怎么实现 CRD 扩展？

- 编写 CRD 并将其部署到 Kubernetes 集群里；

   这一步的作用就是让 Kubernetes 知道有这个资源及其结构属性，在用户提交该自定义资源的定义时（通常是 YAML 文件定义），Kubernetes 能够成功校验该资源并创建出对应的 Go struct 进行持久化，同时触发控制器的调谐逻辑。

- 编写 Controller 并将其部署到 Kubernetes 集群里。