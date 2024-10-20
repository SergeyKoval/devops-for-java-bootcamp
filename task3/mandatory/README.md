# Task 3 mandatory part

## Requirements
- Install docker. (Hint: please use VMs or Clouds  for this.)
- Find, download and run any docker container "hello world".
- Create your Dockerfile for building a docker image. Your docker image should run a Spring Boot web application with few simple GET endpoints. Web application should be located inside the docker image.
- Add an environment variable "DEVOPS=<username> to your docker image. Print this environment variable’s value in one of your GET endpoints
- Push your docker image to docker hub (https://hub.docker.com/). Create any description for your Docker image.
- Create docker-compose file. Deploy a few docker containers via one docker-compose file.
  - first image - docker image from step 2. 5 nodes of the first image should be run;
  - second image - your Spring Boot application;
  - last image - any database image (mysql, postgresql, mongo or etc.). The database should contain a simple table with some sample data.
  - second container should be run right after a successful run of a database container.


## Docker on EC2 with hello world application

AWS infrastructure was created with terraform [script](/task3/mandatory/main.tf), which is pretty similar to the public instance of task2. Main difference is in the [user data script](/task3/mandatory/instance1-user-data.yml)

```yml
#cloud-config
repo_update: true
repo_upgrade: all
packages:
  - docker
runcmd:
  - sudo systemctl enable docker
  - sudo service docker start
  - sudo chmod 666 /var/run/docker.sock
  - sudo docker run -p 80:80 nginxdemos/hello
```

As a result we have nginx hello world application available in the internet

![](/task3/mandatory/images/aws_instance_hello_world.png)

## Dockerfile and dockerhub

Simple Spring Application was created under [java-app folder](/task3/mandatory/java-app/src/main/java/com/example/springboot/AppController.java).

This application has endpoint, which returns environment variable value from the [Dockerfile](/task3/mandatory/java-app/Dockerfile)

```dockerfile
FROM amazoncorretto:21 AS builder

ENV APP_HOME="/usr/src/application"

RUN mkdir -p ${APP_HOME}

WORKDIR ${APP_HOME}
COPY gradle ${APP_HOME}/gradle/
COPY build.gradle gradlew gradlew.bat mvnw mvnw.cmd settings.gradle ${APP_HOME}/
COPY src ${APP_HOME}/src/
RUN ./gradlew assemble


FROM amazoncorretto:21

ENV APP_HOME="/usr/src/application"
ENV DEVOPS="Sergey Koval"

RUN mkdir -p ${APP_HOME}
WORKDIR ${APP_HOME}
COPY --from=builder ${APP_HOME}/build/libs/*.jar ${APP_HOME}/application.jar

ENTRYPOINT ["java", "-jar", "/usr/src/application/application.jar", "com.example.springboot.Application"]
```

![](/task3/mandatory/images/docker_container_hello.png)

Description was added to the docker image

![](/task3/mandatory/images/docker_image_inspect_description.png)

And it was pushed to the docker hub: https://hub.docker.com/r/deplake/devops-for-java-bootcamp-task3-mandatory/tags

![](/task3/mandatory/images/docker_hub.png)


## Docker compose 

Docker compose [script](/task3/mandatory/java-app/docker-compose.yml) was created

```yml
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
      DEVOPS: "Sergey Koval override value by compose"
    depends_on:
      - postgresql
  postgresql:
    image: postgres:13.13
    volumes:
      - "postgresql-data:/var/lib/postgresql/data/"
      - ./src/main/resources/schema.sql:/docker-entrypoint-initdb.d/init.sql
    environment:
      - POSTGRES_DB=task3
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    ports:
      - "5432:5432"
volumes:
  postgresql-data:
    driver: local
```

![](/task3/mandatory/images/docker_compose_containers.png)

Which contains:
- 5 replicas of nginx hello world application
- my spring boot application with overriden environment variable, which is dependent on DB, so starts after it
- DB with predefined data which is populated from the [script](/task3/mandatory/java-app/src/main/resources/schema.sql)

![](/task3/mandatory/images/docker_compose_hello.png)
