# Overview

- 一个云原生应用由一组相互关联但又离散独立的组件构成，这些组件实例化在合适的运行时上，由配置来控制行为并共同协作提供统一的功能。
- 一个 `Application` 由一组 `Components` 构成，每个 `Component` 的运行时由 `Workload` 描述，每个 `Component` 可以施加 `Traits` 来获取额外的运维能力，同时我们可以使用 `Application scopes` 将 `Components` 划分到 1 或者多个应用边界中，便于统一做配置、限制、管理。
- 通过 OAM 的实现层翻译为真实的资源

检索  `k8s` 的 CRD

```bash
➜ kubectl get crd |grep oam|grep applications
applications.core.oam.dev                           2021-07-25T12:36:21Z
```

存在 `v1beta1` 和 `v1alpha2`(新版本) 两个版本

## Application

`OAM Runtime` 基于 `kubevela`， 不带挂载数据集的例子

```bash
cat <<EOF | kubectl apply -f -
apiVersion: core.oam.dev/v1beta1
kind: Application
metadata:
  name: jupyter
spec:
  components:
    - name: jupyter-comp
      type: webservice
      properties:
        image: docker-reg.basebit.me:5000/base/enigma2-vnc-jupyter:1.6.1
        port: 6901
        env:
          - name: JUPYTER_WORK_DIR
            value: /enigma
          - name: JUPYTER_PIP_URL
            value: https://mirrors.xdp.com/pypi/simple/
      traits:
        - type: ingress
          properties:
            domain: jupyter.oam.test.yifang.dev.curisinsight.com
            http:
              "/": 6901
EOF
```

访问地址： http://jupyter.oam.test.yifang.dev.curisinsight.com

---

集群内信息检索

```bash
➜ kubectl get app|{head -1; grep jupyter;}
```

<details>
 <summary>Output</summary>

```bash
NAME               COMPONENT                             TYPE            PHASE       HEALTHY   STATUS   AGE
jupyter            jupyter-comp                          webservice      running     true               63m
```

</details>


```bash
kubectl get component| {head -1; grep jupyter;}
```

<details>
 <summary>Output</summary>

```bash
NAME                                  WORKLOAD-KIND           AGE
jupyter-comp                          Deployment              65m
```

</details>
