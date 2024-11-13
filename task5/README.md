# Task 5

## Requirements
- Deploy kubernetes cluster.
- Get a list of nodes, pods, deployments, services, namespaces of your cluster.
- Use your docker compose from Task 3 - docker. (item 3.1.). Develop kubernetes manifests to deploy the same applications and their settings but in kubernetes.
  How can we make sure the application works and responds as expected?
- Use kubernetes secret/config maps for secrets and settings
- Deploy nginx using a third party helm chart. How can we see the "hello world" web page in the browser?
- Develop a helm chart to deploy the set of applications from step 3.

## K8s cluster with applications from task3

Postgres secret [configuration](/task5/k8s/postgres-secret.yml):

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
type: Opaque
data:
  postgres-user: cG9zdGdyZXM=
  postgres-password: cGFzc3dvcmQ=
```

Postgres config [configuration](/task5/k8s/postgres-config.yml):

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-config
data:
  postgres-url: "postgres-service"
  postgres-db: "task3"
```

Postgres deployment and service [configuration](/task5/k8s/postgres.yml):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-deployment
  labels:
    app: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      volumes:
        - name: "postgres-storage"
          hostPath:
            type: DirectoryOrCreate
            path: "/Users/skoval/4work/soft/postgres-data"
      containers:
        - name: postgres-db
          image: postgres:13.13
          ports:
            - containerPort: 5432
          volumeMounts:
            - name: "postgres-storage"
              mountPath: "/var/lib/postgresql/data"
          env:
            - name: POSTGRES_DB
              valueFrom:
                configMapKeyRef:
                  name: postgres-config
                  key: postgres-db
            - name: POSTGRES_USER
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: postgres-user
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: postgres-password
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
spec:
  selector:
    app: postgres
  ports:
    - protocol: TCP
      port: 5432
      targetPort: 5432
```

Task 3 deployment and service [configuration](/task5/k8s/task3.yml):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: task3-deployment
  labels:
    app: task3
spec:
  replicas: 1
  selector:
    matchLabels:
      app: task3
  template:
    metadata:
      labels:
        app: task3
    spec:
      containers:
        - name: task3-app
          image: deplake/devops-for-java-bootcamp-task3-extra:latest
          ports:
            - containerPort: 8080
          env:
            - name: SPRING_DATASOURCE_USERNAME
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: postgres-user
            - name: SPRING_DATASOURCE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgres-secret
                  key: postgres-password
            - name: POSTGRES_URL
              valueFrom:
                configMapKeyRef:
                  name: postgres-config
                  key: postgres-url
            - name: POSTGRES_DB
              valueFrom:
                configMapKeyRef:
                  name: postgres-config
                  key: postgres-db
            - name: SPRING_DATASOURCE_URL
              value: jdbc:postgresql://${POSTGRES_URL}:5432/${POSTGRES_DB}
---
apiVersion: v1
kind: Service
metadata:
  name: task3-service
spec:
  type: NodePort
  selector:
    app: task3
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
      nodePort: 30111
```

5 instances of nginx deployment and service [configuration](/task5/k8s/nginxdemos-hello.yaml):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginxdemos-hello-deployment
  labels:
    app: nginxdemos-hello
spec:
  replicas: 5
  selector:
    matchLabels:
      app: nginxdemos-hello
  template:
    metadata:
      labels:
        app: nginxdemos-hello
    spec:
      containers:
        - name: nginxdemos-hello
          image: nginxdemos/hello:latest
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginxdemos-hello-service
spec:
  selector:
    app: nginxdemos-hello
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

Third party nginx helm chart was started with command:

```bash
helm install my-release oci://registry-1.docker.io/bitnamicharts/nginx
```

Cluster information:

![](/task5/images/terminal_task4_all.png)

Namespaces:

![](/task5/images/termainal_task4_namespace.png)

Nodes:

![](/task5/images/terminal_task4_node.png)

Pods:

![](/task5/images/terminal_task4_pod.png)

Services:

![](/task5/images/terminal_task4_service.png)

Deployments:

![](/task5/images/terminal_tsk4_deployment.png)

In order to provide external access for the kubernates service 2 options were found:

- opening tunnel

![](/task5/images/terminal_node-port_tunnel.png)

![](/task5/images/browser_task3-app.png)

![](/task5/images/terminal_node-port_tunnel2.png)

![](/task5/images/browser_task4.png)

- port forwarding 

![](/task5/images/terminal_node-port_forwarding.png)

![](/task5/images/browser_task3-app2.png)

## Helm chart with helmfile

Everything was started based on helmfile [configuration](/task5/extra/helmfile.yaml) by executing:

```bash
helmfile repos
helmfile sync
```

```yaml
repositories:
  - name: stable
    url: https://charts.bitnami.com/bitnami

releases:
  - name: postgres
    chart: ./charts/postgres
    values:
      - ./values/task5-postgres.yaml

  - name: task3
    chart: ./charts/task3
    values:
      - ./values/task5-task3.yaml

  - name: nginxdemos-hello
    chart: ./charts/task3
    values:
      - ./values/task5-nginxdemos-hello.yaml

  - name: nginx
    chart: bitnami/nginx
    version: 18.2.5
```

Files structure:

![](/task5/images/idea_extra_structure.png)

Postgres chart configmap [template](/task5/extra/charts/postgres/templates/configmap.yaml):

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.task5.name }}-config
data:
  {{- range .Values.task5.config.data }}
    {{ .key }}: "{{ .value }}"
  {{- end }}
```

Postgres chart secret [template](/task5/extra/charts/postgres/templates/secret.yaml):

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Values.task5.name }}-secret
type: Opaque
data:
  {{- range .Values.task5.secret.data }}
    {{ .key }}: "{{ .value }}"
  {{- end }}
```

Postgres chart service [template](/task5/extra/charts/postgres/templates/service.yaml):

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.task5.name }}-service
spec:
  type: {{ .Values.task5.service.type }}
  selector:
    app: {{ .Values.task5.name }}
  ports:
    - protocol: TCP
      port: {{ .Values.task5.service.port }}
      targetPort: {{ .Values.task5.service.targetPort }}
```

Postgres chart deployment [template](/task5/extra/charts/postgres/templates/deployment.yaml):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.task5.name }}-deployment
  labels:
    app: {{ .Values.task5.name }}
spec:
  replicas: {{ .Values.task5.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Values.task5.name }}
  template:
    metadata:
      labels:
        app: {{ .Values.task5.name }}
    spec:
      {{- with .Values.task5.volumes }}
      volumes:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ .Values.task5.container.name }}
          image: {{ .Values.task5.container.image }}
          ports:
            - containerPort: {{ .Values.task5.container.port }}
          {{- with .Values.task5.container.volumeMounts }}
          volumeMounts:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .Values.task5.container.env }}
          env:
            {{- toYaml . | nindent 12 }}
          {{- end }}
```

Default postgres chart [values](/task5/extra/charts/postgres/values.yaml):

```yaml
task5:
  name: postgres
  replicaCount: 1
  service:
    port: 5432
    targetPort: 5432
    type: ClusterIP
  container:
    name: postgres-db
    image: postgres:13.13
    port: 5432
    volumeMounts:
      - name: "postgres-storage"
        mountPath: "/var/lib/postgresql/data"
  volumes:
    - name: "postgres-storage"
      hostPath:
        type: DirectoryOrCreate
        path: "/Users/skoval/4work/soft/postgres-data"
```

Task3 chart service [template](/task5/extra/charts/task3/templates/service.yaml):

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.task5.name }}-service
spec:
  type: {{ .Values.task5.service.type }}
  selector:
    app: {{ .Values.task5.name }}
  ports:
    - protocol: TCP
      port: {{ .Values.task5.service.port }}
      targetPort: {{ .Values.task5.service.targetPort }}
      nodePort: {{ .Values.task5.service.nodePort }}
```

Task3 chart deployment [template](/task5/extra/charts/task3/templates/deployment.yaml):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.task5.name }}-deployment
  labels:
    app: {{ .Values.task5.name }}
spec:
  replicas: {{ .Values.task5.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Values.task5.name }}
  template:
    metadata:
      labels:
        app: {{ .Values.task5.name }}
    spec:
      containers:
        - name: {{ .Values.task5.container.name }}
          image: {{ .Values.task5.container.image }}
          ports:
            - containerPort: {{ .Values.task5.container.port }}
          {{- with .Values.task5.container.env }}
          env:
            {{- toYaml . | nindent 12 }}
          {{- end }}
```

Default postgres chart [values](/task5/extra/charts/postgres/values.yaml):

```yaml
task5:
  replicaCount: 1
```

Postgres override [values](/task5/extra/values/task5-postgres.yaml):

```yaml
task5:
  container:
    env:
      - name: POSTGRES_DB
        valueFrom:
          configMapKeyRef:
            name: postgres-config
            key: postgres-db
      - name: POSTGRES_USER
        valueFrom:
          secretKeyRef:
            name: postgres-secret
            key: postgres-user
      - name: POSTGRES_PASSWORD
        valueFrom:
          secretKeyRef:
            name: postgres-secret
            key: postgres-password
  config:
    data:
      - key: postgres-url
        value: postgres-service
      - key: postgres-db
        value: task3
  secret:
    data:
      - key: postgres-user
        value: cG9zdGdyZXM=
      - key: postgres-password
        value: cGFzc3dvcmQ=
```

Task3 override [values](/task5/extra/values/task5-task3.yaml):

```yaml
task5:
  replicaCount: 1
  name: task3
  service:
    port: 8080
    targetPort: 8080
    nodePort: 30111
    type: NodePort
  container:
    name: task3-java-app
    image: deplake/devops-for-java-bootcamp-task3-extra:latest
    port: 8080
    env:
      - name: SPRING_DATASOURCE_USERNAME
        valueFrom:
          secretKeyRef:
            name: postgres-secret
            key: postgres-user
      - name: SPRING_DATASOURCE_PASSWORD
        valueFrom:
          secretKeyRef:
            name: postgres-secret
            key: postgres-password
      - name: POSTGRES_URL
        valueFrom:
          configMapKeyRef:
            name: postgres-config
            key: postgres-url
      - name: POSTGRES_DB
        valueFrom:
          configMapKeyRef:
            name: postgres-config
            key: postgres-db
      - name: SPRING_DATASOURCE_URL
        value: jdbc:postgresql://${POSTGRES_URL}:5432/${POSTGRES_DB}
```

Nginx override [values](/task5/extra/values/task5-nginxdemos-hello.yaml):

```yaml
task5:
  replicaCount: 5
  name: nginxdemos-hello
  service:
    port: 80
    targetPort: 80
    type: ClusterIP
  container:
    name: nginxdemos-hello
    image: nginxdemos/hello:latest
    port: 80
```

Cluster information:

![](/task5/images/terminal_task4_1_all.png)
