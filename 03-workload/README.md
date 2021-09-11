[[_TOC_]]

# Workload

应用程序可用的 `Workload` 类型是由平台提供商和基础设施运维人员提供的。`Workload` 模型参照 Kubernetes 规范定义，`Workload Type` 不能对终端用户(仅对平台操作人员)进行扩展

`Workload`  是实际工作负载，平台方可以根据 Workload 规范来扩展负载类型，比如 Containers、Functions、VirtualMachine、VirtualService 等。

OAM 目前定义的核心负载类型有 ContainerizedWorkload（与 Kubernetes 中的 Pod 定义类似，同样支持定义多个容器，但是缺少了 Pod 中的一些属性 ）。


## 命名变更

| concept   | v1alpha1           | v1alpha2            |
| --------- | ------------------ | ------------------- |
| Workload | WorkloadType | WorkloadDefinition |

```bash
➜ kubectl get crd |grep oam|grep work
containerizedworkloads.core.oam.dev                 2021-07-25T12:36:21Z
podspecworkloads.standard.oam.dev                   2021-07-25T12:36:23Z
workloaddefinitions.core.oam.dev                    2021-07-25T12:36:23Z
```

## 分类

> `OAM`  将应用的工作负载（Workload）分为三种，这三者的主要区别在于一个 `OAM` 平台对于具体某一类工作负载进行实现的自由度不同。

- core.oam.dev（核心型）
- standard.oam.dev（标准型）
- 自定义扩展型。

## 定义

```yaml
apiVersion: core.oam.dev/v1beta1
# kind 值必须是 WorkloadDefinition（在 CRD 中已确定）
kind: WorkloadDefinition
metadata:
  annotations:
    meta.helm.sh/release-name: kubevela
    meta.helm.sh/release-namespace: vela-system
  labels:
    app.kubernetes.io/managed-by: Helm
  name: containerizedworkloads.core.oam.dev
  namespace: vela-system
spec:
  childResourceKinds:
  - apiVersion: apps/v1
    kind: Deployment
  - apiVersion: v1
    kind: Service
  # definitionRef 引用一个已定义好的 CRD
  definitionRef:
    name: containerizedworkloads.core.oam.dev
```

### 1. 关于 `WorkloadDefinition` (自定义资源 `CR`)

1. 以上 `WorkloadDefinition`(containerizedworkloads.core.oam.dev)  在 `k8s` 中是一个自定义资源（Custom Resource），也就是 CR。
2. 它的 `CRD` (即自定义资源的定义) 如下。

	```bash
	➜ kubectl get crd workloaddefinitions.core.oam.dev
	NAME                               CREATED AT
	workloaddefinitions.core.oam.dev   2021-07-25T12:36:23Z
	```

3. 查看这个自定义资源具体长什么样子

	```bash
	kubectl get crd workloaddefinitions.core.oam.dev -oyaml|kubectl neat
	```

	<details>
	<summary>Output</summary>

	```yaml
	apiVersion: apiextensions.k8s.io/v1
	kind: CustomResourceDefinition
	metadata:
	  annotations:
		controller-gen.kubebuilder.io/version: v0.2.4
	  name: workloaddefinitions.core.oam.dev
	spec:
	  conversion:
		strategy: None
	  group: core.oam.dev
	  names:
		categories:
		- oam
		kind: WorkloadDefinition
		listKind: WorkloadDefinitionList
		plural: workloaddefinitions
		shortNames:
		- workload
		singular: workloaddefinition
	  scope: Namespaced
	  versions:
	  - additionalPrinterColumns:
		- jsonPath: .spec.definitionRef.name
		  name: DEFINITION-NAME
		  type: string
		name: v1alpha2
		schema:
		  openAPIV3Schema:
			description: A WorkloadDefinition registers a kind of Kubernetes custom resource
			  as a valid OAM workload kind by referencing its CustomResourceDefinition.
			  The CRD is used to validate the schema of the workload when it is embedded
			  in an OAM Component.
			properties:
			  apiVersion:
				description: 'APIVersion defines the versioned schema of this representation
				  of an object. Servers should convert recognized schemas to the latest
				  internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.
	md#resources'
				type: string
			  kind:
				description: 'Kind is a string value representing the REST resource this
				  object represents. Servers may infer this from the endpoint the client
				  submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-convention
	s.md#types-kinds'
				type: string
			  metadata:
				type: object
			  spec:
				description: A WorkloadDefinitionSpec defines the desired state of a WorkloadDefinition.
				properties:
				  childResourceKinds:
					description: ChildResourceKinds are the list of GVK of the child resources
					  this workload generates
					items:
					  description:
    ....
	```
	</details>

### 2. 关于  `CR(containerizedworkloads.core.oam.dev)`

1. spec.definitionRef.name 的值与 metadata.name 的值需相同，因为 definitionRef 是对相应的 Workload schema 的引用，对于 Kubernetes 平台来说，即对 CRD 的引用
2. 查看 `containerizedworkloads.core.oam.dev` 这个 `CRD(自定义资源的定义)`

	```bash
	➜ kubectl get crd containerizedworkloads.core.oam.dev -oyaml|kubectl neat
	NAME                                  CREATED AT
	containerizedworkloads.core.oam.dev   2021-07-25T12:36:21Z
	```

	<details>
	<summary>Output</summary>

	```yaml
	apiVersion: apiextensions.k8s.io/v1
	kind: CustomResourceDefinition
	metadata:
	  annotations:
		controller-gen.kubebuilder.io/version: v0.2.4
	  name: containerizedworkloads.core.oam.dev
	spec:
	  conversion:
		strategy: None
	  group: core.oam.dev
	  names:
		categories:
		- oam
		kind: ContainerizedWorkload
		listKind: ContainerizedWorkloadList
		plural: containerizedworkloads
		singular: containerizedworkload
	  scope: Namespaced
	  versions:
	  - name: v1alpha2
		schema:
		  openAPIV3Schema:
			description: A ContainerizedWorkload is a workload that runs OCI containers.
			properties:
			  apiVersion:
				description: 'APIVersion defines the versioned schema of this representation
				  of an object. Servers should convert recognized schemas to the latest
				  internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.
	md#resources'
				type: string
			  kind:
				description: 'Kind is a string value representing the REST resource this
				  object represents. Servers may infer this from the endpoint the client
				  submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-convention
	s.md#types-kinds'
				type: string
			  metadata:
				type: object
			  spec:
				description: A ContainerizedWorkloadSpec defines the desired state of
				  a ContainerizedWorkload.
				properties:
				  arch:
					description: CPUArchitecture required by this workload.
					enum:
					- i386
					- amd64
					- arm
					- arm64
					type: string
				  containers:
					description: Containers of which this workload consists.
					items:
					  description: A Container represents an Open Containers Initiative
						(OCI) container.
					  properties:
						args:
						  description: Arguments to be passed to the command run by this
							container.
						  items:
							type: string
						  type: array
						command:
						  description: Command to be run by this container.
						  items:
							type: string
						  type: array
						config:
						  description: ConfigFiles that should be written within this
							container.
						  items:
							description: A ContainerConfigFile specifies a configuration
							  file that should be written within a container.
							properties:
							  fromSecret:
								description: FromSecret is a secret key reference which
	....
	```
	</details>

### 3. 查看平台提供的 workload

```bash
kubectl get workload
```

<details>
<summary>Output</summary>

以下除了  `containerizedworkloads.core.oam.dev` 是 `OAM` 中支持的核心 Workload，其他两个都是自定义的

```bash
NAME                                  DEFINITION-NAME                       DESCRIPTION
bb-server-test                        containerizedworkloads.core.oam.dev
containerizedworkloads.core.oam.dev   containerizedworkloads.core.oam.dev
schema.example.basebit.ai             schema.example.basebit.ai
```
</details>

### 4. 创建一个新的 Workload

```bash
cat <<EOF | kubectl apply -f -
apiVersion: core.oam.dev/v1beta1
kind: WorkloadDefinition
metadata:
  name: server
spec:
  definitionRef:
    name: containerizedworkloads.core.oam.dev
EOF
```
