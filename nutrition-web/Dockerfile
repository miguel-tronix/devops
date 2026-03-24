FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY nutrition-web/pom.xml .
RUN mvn dependency:go-offline -B
COPY nutrition-web/src ./src
RUN mvn package -DskipTests -B

FROM quay.io/wildfly/wildfly:27.0.0.Final-jdk17

USER root

RUN mkdir -p /opt/jboss/wildfly/modules/org/postgresql/main

RUN curl -L -o /opt/jboss/wildfly/modules/org/postgresql/main/postgresql-42.7.3.jar \
    https://jdbc.postgresql.org/download/postgresql-42.7.3.jar

COPY devops/nutrition-web/docker/module.xml /opt/jboss/wildfly/modules/org/postgresql/main/

COPY devops/nutrition-web/docker/docker-entrypoint.sh /opt/jboss/docker-entrypoint.sh
RUN chmod +x /opt/jboss/docker-entrypoint.sh

USER jboss

COPY --from=build /app/target/NutritionWeb.war /opt/jboss/wildfly/standalone/deployments/

EXPOSE 8080

ENTRYPOINT ["/opt/jboss/docker-entrypoint.sh"]
