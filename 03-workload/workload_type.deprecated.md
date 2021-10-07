# Overview

> WorkloadType (v1alpha1) 已弃用

旧版本 `v1alpha1` 原先的方式 `WorkloadType` 的定义，使用 `Properties` 作为 `workloadSettings` 类型，以使扩展工作负载类型更加灵活

1. 先定义 WorkloadType

    ```yaml
    apiVersion: core.oam.dev/v1alpha1
    kind: WorkloadType
    metadata:
      name: OpenFaaS
      annotations:
        version: v1.0.0
        description: "OpenFaaS a Workload which can serve workload running as functions"
    spec:
      group: openfaas.com
      version: v1alpha2
      names:
        kind: Function
        singular: function
        plural: functions
      workloadSettings: |
        {
          "$schema": "http://json-schema.org/draft-07/schema#",
          "type": "object",
          "required": [
            "name", "image"
          ],
          "properties": {
            "name": {
              "type": "string",
              "description": "the name to the function"
            },
            "image": {
              "type": "string",
              "description": "the docker image of the function"
            }
          }
        }
    ```

2. 再定义 ComponentSchematic

    ```yaml
    apiVersion: core.oam.dev/v1alpha1
    kind: ComponentSchematic
    metadata:
      name: go-echo
      annotations:
        version: v1.0.0
        description: "an echo server shows node info"
    spec:
      workloadType: openfaas.com/v1alpha2.Function
      osType: linux
      workloadSettings:
        name: go-echo
        image: alexellisuk/go-echo:0.2.2
    ```

3. 最后通过 `ApplicationConfiguration` 绑定

    ```yaml
    apiVersion: core.oam.dev/v1alpha1
    kind: ApplicationConfiguration
    metadata:
      name: extend-workload-app
      annotations:
        version: v1.0.0
        description: "Customized version of extend-workload-app"
    spec:
      components:
        - componentName: go-echo
          instanceName: go-echo-instance
    ```
