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
