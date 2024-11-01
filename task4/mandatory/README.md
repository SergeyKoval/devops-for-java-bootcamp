# Task 4 mandatory part

## Requirements
- Install Jenkins. It must be installed in a docker container.
- Add maven/gradle plugins like: checkstyle, spotbugs, dependency-check.
- Create several branches in your Git repository: one branch should contain good code, other branches should violate one of the plugins above.
- Create a Jenkins pipeline that will build your project. It should fail if there are any violations of above.
- Create a yaml linter for the spring config. Use github actions. If the linter fails you shouldn’t be able to merge the PR(The option can be configured for free but won’t be operational. That is OK).

## Jenkins in docker container on AWS

Jenkins was started on EC2 instance inside docker container, which was done with [terraform script](/task4/mandatory/aws/main.tf) and [user data script](/task4/mandatory/aws/instance1-user-data.yml):

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
  - sudo mkdir /var/jenkins_home
  - sudo chmod ugo+rwx /var/jenkins_home
  - sudo git config --global --add safe.directory '*'
  - sudo docker run -p 80:8080 -p 50000:50000 -v /var/jenkins_home:/var/jenkins_home jenkins/jenkins
```

## Gradle plugins

Next plugins were added to the gradle java application:
- checkstyle
- spotbugs
- dependency-check

```kotlin
plugins {
	id 'org.springframework.boot' version '3.3.0'
	id 'java'
	id 'checkstyle'
	id 'com.github.spotbugs' version '6.0.25'
	id 'org.owasp.dependencycheck' version '8.2.0'
}

apply plugin: 'io.spring.dependency-management'

group = 'com.example'
version = '0.0.1-SNAPSHOT'
sourceCompatibility = '17'

repositories {
	mavenCentral()
}

dependencies {
	implementation 'org.springframework.boot:spring-boot-starter-web'
	testImplementation 'org.springframework.boot:spring-boot-starter-test'
//	implementation 'org.apache.logging.log4j:log4j-core:2.14.1'
}

test {
	useJUnitPlatform()
}

checkstyle {
	toolVersion = "10.17.0"
}

checkstyleMain
	.exclude('com/example/springboot/Application.java')
	.exclude('com/example/springboot/AppController.java')

def classLoader = plugins['com.github.spotbugs'].class.classLoader
def SpotBugsEffort = classLoader.findLoadedClass( 'com.github.spotbugs.snom.Effort' )
def SpotBugsConfidence = classLoader.findLoadedClass( 'com.github.spotbugs.snom.Confidence' )
spotbugs {
	toolVersion = "4.8.6"
	effort = SpotBugsEffort.MAX
	reportLevel = SpotBugsConfidence.LOW
}

tasks.withType(com.github.spotbugs.snom.SpotBugsTask) {
	reports {
		xml.required.set(false)  // For XML reports
		html.required.set(true) // For HTML reports
	}
}

tasks.check.dependsOn dependencyCheckAnalyze
dependencyCheck {
	failBuildOnCVSS = 10
	formats = ['XML', 'HTML']
}
```

## Branches with different code base for checking plugins

### main branch with success build

![](/task4/mandatory/images/jenkins_main_success.png)

### checkstyle branch with failed build

![](/task4/mandatory/images/jenkins_ckeckstyle_fail.png)

### spotbugs branch with failed build

![](/task4/mandatory/images/jenkins_spotbug_fails1.png)
![](/task4/mandatory/images/jenkins_spotbug_fails2.png)

### dependency-check branch with failed build

![](/task4/mandatory/images/jenkins_dependency_fails1.png)
![](/task4/mandatory/images/jenkins_dependency_fails2.png)

## Github action linter

Github action linter script:

```yml
name: Lint Code Base

on:
  pull_request:
    branches: [ "protected" ]
jobs:
  run-lint:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          # Full git history is needed to get a proper list of changed files within `super-linter`
          fetch-depth: 0

      - name: Lint Code Base
        uses: github/super-linter@v4
        env:
          VALIDATE_ALL_CODEBASE: false
          DEFAULT_BRANCH: "main"
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

Protect branch configuration:

![](/task4/mandatory/images/github_pretect_branch_configuration.png)

Pull request with failed check

![](/task4/mandatory/images/github_failed_check.png)
