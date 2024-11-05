# Task 4 extra part

## Requirements
- Configure integration between Jenkins and your Git repo. Jenkins project must be started automatically if you push or merge to master, you also must see Jenkins last build status(success/unsuccess) in your Git repo.
- Configure several (2-3) build agents. Agents must be run in docker.
- Create Pipeline which will execute docker ps -a in docker agent, running on Jenkins master’s Host.

![](/task4/extra/images/requirement.png)

## Jenkins integration with github

Github token was created for jenkins in order to have permissions for updating status. This token was added to the jenkins configuration (github server)

![](/task4/extra/images/jenkins_github-server.png)

Then webhook ig github was created in order to trigger jenkins builds

![](/task4/extra/images/github_webhook-configuration.png)

Jenkins job configuration

![](/task4/extra/images/jenkins_build-configuration_git.png)
![](/task4/extra/images/jenkins_build-configuration_triggers.png)
![](/task4/extra/images/jenkins_build-configuration_post-build-actions.png)

### Success build scenario

![](/task4/extra/images/jenkins_success-job.png)
![](/task4/extra/images/github_success-jenkins-job.png)

### Failed build scenario

![](/task4/extra/images/jenkins_failed-job.png)
![](/task4/extra/images/github_failed-jenkins-job.png)

## Jenkins with local and remote agents

AWS infrastructure was created using [terraform script](/task4/extra/aws/main.tf), user data for [instance1](/task4/extra/aws/instance1-user-data.yml) and [instance2](/task4/extra/aws/instance2-user-data.yml)

As jenkins agent I have decided to use [jenkins/inbound-agent](https://hub.docker.com/r/jenkins/inbound-agent/) which I have used as base image for my own as this one doesn't have preinstalled docker which is required for the task. My dockerfile:

```dockerfile
FROM jenkins/inbound-agent:latest

# Install Docker
USER root
RUN apt-get update && \
    apt-get install -y docker.io && \
    rm -rf /var/lib/apt/lists/*

RUN usermod -aG docker jenkins

# Set up Docker daemon for Docker-in-Docker (DinD)
RUN dockerd &

# Switch back to jenkins user
USER jenkins
```

Next command was used for starting agent on both machines using websocket connection:

```shell
docker run -d --init --name agent3 --privileged -e JENKINS_WEB_SOCKET=true -v /var/run/docker.sock:/var/run/docker.sock deplake/devops-for-java-bootcamp-task4-extra -url http://ec2-50-16-56-37.compute-1.amazonaws.com/ -workDir=/home/jenkins/agent secret agent3
```

![](/task4/extra/images/jenkins_agents.png)

![](/task4/extra/images/instance1_containers.png)

![](/task4/extra/images/agent1_job-log.png)

![](/task4/extra/images/insatnce2_containers.png)

![](/task4/extra/images/agent3_job-log.png)
