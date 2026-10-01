# BUILD
FROM eclipse-temurin:21-jdk-noble AS build
WORKDIR /opt/app/
COPY .mvn/ .mvn
COPY mvnw pom.xml .
RUN chmod +x mvnw && ./mvnw dependency:go-offline
COPY src ./src
RUN ./mvnw package -DskipTests


# RUN
FROM eclipse-temurin:21-jre-noble AS run
EXPOSE 8080
WORKDIR /opt/app/
RUN groupadd -r app && useradd --no-log-init -r -g app app
COPY --from=build --chown=app:app /opt/app/target/*.jar app.jar
USER app
CMD ["java", "-jar", "./app.jar"] 