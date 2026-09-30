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
WORKDIR /opt/app/
COPY --from=build /opt/app/target/*.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "./app.jar"] 