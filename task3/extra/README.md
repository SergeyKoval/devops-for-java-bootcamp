# Task 3 mandatory part

## Requirements
- Write bash script for installing Docker.
- Use image with html page, edit html page and paste text: <Username> 2024
- For creating the docker image use clear basic images (ubuntu, centos, alpine, etc.)
- Integrate your docker image and your github repository. Create an automatic deployment for each push. (The Deployment can be in the “Pending” status for 10-20 minutes. This is normal).
- One of the endpoints of the second container should retrieve data from the DB table.
- Use env files to configure each service.

## EC2 user data with script for installing Docker

Updated EC2 user data with script for installing Docker:

```yml
#cloud-config
repo_update: true
repo_upgrade: all
runcmd:
  - sudo apt-get install ca-certificates curl
  - sudo install -m 0755 -d /etc/apt/keyrings
  - sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  - sudo chmod a+r /etc/apt/keyrings/docker.asc
  - echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  - sudo apt-get update
  - sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
  - sudo systemctl enable docker
  - sudo service docker start
  - sudo chmod 666 /var/run/docker.sock
  - sudo docker run -p 80:80 nginxdemos/hello
```

Updated nginxdemos/hello static page

![](/task3/extra/images/aws_insatance_updated_hello_page.png)

## Clear basic docker image

```dockerfile
FROM amazonlinux:2 AS builder

ARG version=21.0.5.11-1
RUN set -eux \
    && export GNUPGHOME="$(mktemp -d)" \
    && curl -fL -o corretto.key https://yum.corretto.aws/corretto.key \
    && gpg --batch --import corretto.key \
    && gpg --batch --export --armor '6DC3636DAE534049C8B94623A122542AB04F24E3' > corretto.key \
    && rpm --import corretto.key \
    && rm -r "$GNUPGHOME" corretto.key \
    && curl -fL -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo \
    && grep -q '^gpgcheck=1' /etc/yum.repos.d/corretto.repo \
    && echo "priority=9" >> /etc/yum.repos.d/corretto.repo \
    && yum install -y java-21-amazon-corretto-devel-$version \
    && (find /usr/lib/jvm/java-21-amazon-corretto -name src.zip -delete || true) \
    && yum install -y fontconfig \
    && yum clean all

ENV LANG=C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto
ENV APP_HOME="/usr/src/application"

RUN mkdir -p ${APP_HOME}

WORKDIR ${APP_HOME}
COPY gradle ${APP_HOME}/gradle/
COPY build.gradle gradlew gradlew.bat mvnw mvnw.cmd settings.gradle ${APP_HOME}/
COPY src ${APP_HOME}/src/
RUN ./gradlew assemble


FROM amazonlinux:2

ARG version=21.0.5.11-1
RUN set -eux \
    && export GNUPGHOME="$(mktemp -d)" \
    && curl -fL -o corretto.key https://yum.corretto.aws/corretto.key \
    && gpg --batch --import corretto.key \
    && gpg --batch --export --armor '6DC3636DAE534049C8B94623A122542AB04F24E3' > corretto.key \
    && rpm --import corretto.key \
    && rm -r "$GNUPGHOME" corretto.key \
    && curl -fL -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo \
    && grep -q '^gpgcheck=1' /etc/yum.repos.d/corretto.repo \
    && echo "priority=9" >> /etc/yum.repos.d/corretto.repo \
    && yum install -y java-21-amazon-corretto-devel-$version \
    && (find /usr/lib/jvm/java-21-amazon-corretto -name src.zip -delete || true) \
    && yum install -y fontconfig \
    && yum clean all

ENV LANG=C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto
ENV APP_HOME="/usr/src/application"
ENV DEVOPS="Sergey Koval"

RUN mkdir -p ${APP_HOME}
WORKDIR ${APP_HOME}
COPY --from=builder ${APP_HOME}/build/libs/*.jar ${APP_HOME}/application.jar

ENTRYPOINT ["java", "-jar", "/usr/src/application/application.jar", "com.example.springboot.Application"]
```

## Github actions integration

Github action script:

```yml
name: Build image and push it to DockerHub

on:
  push:
    branches: [ "main" ]

jobs:
  build-and-publish:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
      - name: Build the Docker image
        run: docker build ./task3/extra/java-app-extra/ --tag deplake/devops-for-java-bootcamp-task3-extra:latest
      - name: Push image to docker hub
        run: |
          docker login -u deplake -p ${{secrets.DEPLAKE_DOCKER_HUB_TOKEN}}
          docker push deplake/devops-for-java-bootcamp-task3-extra:latest
```

![](/task3/extra/images/github_actions.png)

![](/task3/extra/images/github_actions_steps.png)

## Docker compose

Environment file:

```properties
DB_NAME=task3
DB_USER=postgres
DB_PASSWORD=password
DEVOPS: "Sergey Koval override value by environment file"
```

Updated docker compose script:

```yaml
---
services:
  hello-world:
    image: nginxdemos/hello
    deploy:
      mode: replicated
      replicas: 5
  java-app:
    build:
      context: .
    ports:
      - "8080:8080"
    environment:
      DEVOPS: ${DEVOPS}
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgresql:5432/${DB_NAME}
      SPRING_DATASOURCE_USERNAME: ${DB_USER}
      SPRING_DATASOURCE_PASSWORD: ${DB_PASSWORD}
    depends_on:
      - postgresql
  postgresql:
    image: postgres:13.13
    volumes:
      - "postgresql-data:/var/lib/postgresql/data/"
      - ./src/main/resources/schema.sql:/docker-entrypoint-initdb.d/init.sql
    environment:
      - POSTGRES_DB=${DB_NAME}
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    ports:
      - "5432:5432"
volumes:
  postgresql-data:
    driver: local
```

Spring boot endpoint, which retrieve DB table value:

![](/task3/extra/images/db_accounts.png)

![](/task3/extra/images/spring-boot_accounts.png)
