# Overview

`Components` 实际上是帮助我们定义 `Deployment`、`StatefulSet` 这样的 `Workload`，暴露给用户，让用户去定义自己应用的语义。

从 `Kubernetes` 的 `CRD` 来看，存在两个模块。

1. ComponentDefinition
2. Component

```bash
➜ kubectl get crd |grep component
```

<details>

  <summary>Output</summary>

  ```bash
  componentdefinitions.core.oam.dev                   2021-07-25T12:36:21Z
  components.core.oam.dev                             2021-07-25T12:36:21Z
  ```

</details>

## ComponentDefinition

存在 `v1beta1` 和 `v1alpha2`(新版本) 两个版本，正常情况下 `ComponentDefinition` 只能被同 `namespace` 下 `application` 引用，但是 `vela-system namespace` 下可以被所有 `application` 引用。


### 检索 ComponentDefinition

检索出当前 `KubeVela` 中支持的 `ComponentDefinition` 列表

```bash
➜ kubectl get componentdefinition
```

<details>

  <summary>Output</summary>

```bash
NAME         WORKLOAD-KIND   DESCRIPTION
task         Job             Describes jobs that run code or a script to completion.
webservice   Deployment      Describes long-running, scalable, containerized services that have a stable network endpoint to receive external network traffic from customers.
worker       Deployment      Describes long-running, scalable, containerized services that running at backend. They do NOT have network endpoint to receive external network traffic.                         2021-07-25T12:36:21Z
```

</details>

## Component

当前 `v1alpha2`  版本，`Component` 是 `OAM` 中最基础的对象，该配置与基础设施无关，定义负载实例的运维特性。例如一个微服务 workload 的定义。

`Component`  用于定义应用程序的基本组件，其中包含了对  `Workload`  的引用，`Component` 是工作负载的版本化定义，`Component`  中的 `Workload` 部分完全是自定义的，或者是可插拔的(可以自由定义自己的上层抽象)。

`Component`  的抽象程度完全取决于用户自己决定的，在 `Component` 的 `Workload`  部分你可以自由的去定义自己的抽象。可以直接引用 `Kubernetes` 中的 `CRD`，只要你提前安装了对应 CRD 即可，这是一个非常高级的玩法。

1. 一个应用是由多个 `Component` 构成的，而一个 `Component` 里的核心字段，就是 `Workload`。
2. 一个 `Component`  中只能定义一个 `Workload`，这个 `Workload` 是与平台无关的。

## 示例

查看集群中存在的 `Component`

```bash
➜ kubectl get component
NAME             WORKLOAD-KIND   AGE
express-server   Deployment      16d
```

查看下 `express-server` 的 Spec 

```bash
kubectl get component express-server -oyaml|kubectl neat
```

<details>
<summary>Output</summary>

以下是一个集成 `k8s` 内部  `Deployment` 资源的  `Workload` 

```yaml
apiVersion: core.oam.dev/v1alpha2
kind: Component
metadata:
  labels:
    app.oam.dev/name: first-vela-app
  name: express-server
  namespace: vela-system
spec:
  workload:
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels:
        app.oam.dev/appRevision: first-vela-app-v1
        app.oam.dev/component: express-server
        app.oam.dev/name: first-vela-app
        workload.oam.dev/type: webservice
    spec:
      selector:
        matchLabels:
          app.oam.dev/component: express-server
      template:
        metadata:
          labels:
            app.oam.dev/component: express-server
        spec:
          containers:
          - image: crccheck/hello-world
            name: express-server
            ports:
            - containerPort: 8000
```
</details>

新建一个基于 `Pod` 的 `Component`

```bash
cat <<EOF | kubectl apply -f -
apiVersion: core.oam.dev/v1alpha2
kind: Component
metadata:
  labels:
    app.oam.dev/name: nginx-demo-app
  name: nginx-demo
  namespace: vela-system
spec:
  workload:
    apiVersion: apps/v1
    kind: Pod
    metadata:
      labels:
        app.oam.dev/component: nginx-demo
        app.oam.dev/name: nginx-demo-app
    spec:
      containers:
      - image: nginx:1.15.2
        name: nginx-demo
        ports:
        - containerPort: 80
EOF
```

新建一个基于自定义 `CRD（ContainerizedWorkload）`   的 `Component`，该  `Component` 提供可更改 `image` 的参数

```bash
cat <<EOF | kubectl apply -f -
apiVersion: core.oam.dev/v1alpha2
kind: Component
metadata:
  name: my-component
spec:
  workload:
    apiVersion: core.oam.dev/v1alpha2
    kind: ContainerizedWorkload
    spec:
      os: linux
      containers:
        - name: server
          image: my-image:latest
  parameters:
  - name: myServerImage
    required: true
    fieldPaths:
    - ".spec.containers[0].image"
EOF
```

| 参数       | 作用                                                         |
| ---------- | ------------------------------------------------------------ |
| metadata   | 关于 Component 的信息                                        |
| workload   | 该 Component 的实际工作负载                                  |
| parameters | 该 Component 公开的参数，在应用程序运行时可以调整的参数。<br>`ApplicationConfigurations` 引用该组件可以指定这些参数的值，然后将其注入到嵌入式工作负载中。<br> `parameters` 使用 `JSONPath` 的方式引用 `spec` 中的字段 |