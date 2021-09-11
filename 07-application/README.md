# Application


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
