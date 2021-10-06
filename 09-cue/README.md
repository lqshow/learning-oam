# Overview

CUE 是一种服务于云化配置的强类型配置语言，由 Go team 成员 Marcel van Lohiuzen 结合 BCL 及多种其他语言研发并开源，可以说是 BCL 思路的开源版实现。

CUE 延续了 JSON 超集的思路，额外提供了丰富的类型、表达式、import 语句等常用能力

在 KubeVela 中，Definition 的主要能力由 CUE 格式的 Template 来定义，作为一种基于 JSON 格式的语言，CUE 格式的 Template 与原生 Kubernetes 中的 YAML 格式并不相互兼容。

在将 CUE 格式的 Template 嵌入 Kubernetes 的 YAML 中时，我们需要将 CUE 转换成为字符串格式，这使得 Definition 在原生 Kubernetes 工具 kubectl 中的使用变得较为复杂。

## 安装

```bash
brew install cuelang/tap/cue
```

```bash
go get -u cuelang.org/go/cmd/cue
```

## Command

### 语法检查

```bash
# validate data
cue vet example.cue
```

```bash
# formats CUE configuration files
cue fmt example.cue
```

### 输出

标准输出
```bash
# 标准输出
cue export example.cue
```

<details>
<summary>output</summary>

```json
{
    "output": {
        "apiVersion": "apps/v1",
        "kind": "Deployment",
        "spec": {
            "selector": {
                "matchLabels": {
                    "app.oam.dev/component": "test",
                    "app": "test"
                }
            },
            "template": {
                "metadata": {
                    "labels": {
                        "app.oam.dev/component": "test",
                        "app": "test"
                    }
                },
                "spec": {
                    "containers": [
                        {
                            "name": "test",
                            "image": "test",
                            "command": [
                                "nginx"
                            ],
                            "ports": [
                                {
                                    "containerPort": 80
                                }
                            ]
                        }
                    ]
                }
            }
        }
    },
    "parameter": {
        "image": "test",
        "cmd": [
            "nginx"
        ],
        "port": 80
    },
    "context": {
        "name": "test"
    }
}
```

</details>

指定参数输出

```bash
# 指定参数输出
cue export example.cue -e output
```

<details>
<summary>output</summary>

```json
{
    "apiVersion": "apps/v1",
    "kind": "Deployment",
    "spec": {
        "selector": {
            "matchLabels": {
                "app.oam.dev/component": "test",
                "app": "test"
            }
        },
        "template": {
            "metadata": {
                "labels": {
                    "app.oam.dev/component": "test",
                    "app": "test"
                }
            },
            "spec": {
                "containers": [
                    {
                        "name": "test",
                        "image": "test",
                        "command": [
                            "nginx"
                        ],
                        "ports": [
                            {
                                "containerPort": 80
                            }
                        ]
                    }
                ]
            }
        }
    }
}
```

</details>

指定参数输出 YAML 文件

```bash
# 指定参数输出 YAML 文件
cue export example.cue --out yaml
```

<details>
<summary>output</summary>

```yaml
output:
  apiVersion: apps/v1
  kind: Deployment
  spec:
    selector:
      matchLabels:
        app.oam.dev/component: test
        app: test
    template:
      metadata:
        labels:
          app.oam.dev/component: test
          app: test
      spec:
        containers:
        - name: test
          image: test
          command:
          - nginx
          ports:
          - containerPort: 80
parameter:
  image: test
  cmd:
  - nginx
  port: 80
context:
  name: test
```

</details>


yaml 文件转换为 cue 文件

```bash
# yaml 文件转换为 cue 文件
cue import example-02.yaml
```

## Kubevela CUE

以下是 Kubevela 提供的三种 Component 的定义

1. worker: <https://github.com/oam-dev/kubevela/blob/master/vela-templates/definitions/internal/worker.cue>
2. webservice: <https://github.com/oam-dev/kubevela/blob/master/vela-templates/definitions/internal/webservice.cue>
3. task: <https://github.com/oam-dev/kubevela/blob/master/vela-templates/definitions/internal/task.cue>

## References

- [CUE 工具](https://github.com/oam-dev/kubevela/blob/master/design/vela-cli/def_zh.md)
- [cue语法](https://cloud.tencent.com/developer/article/1793649)
- [CUE 是一种开源数据约束语言，旨在简化涉及定义和使用数据的任务(The CUE Data Constraint Language)](https://cloud.tencent.com/developer/article/1751847?from=article.detail.1793649)
- [CUE 基础入门](https://wonderflow.info/posts/2020-12-15-cuelang-template/)
- [Kubevela CUE](https://github.com/oam-dev/kubevela/tree/master/vela-templates/definitions/internal)
