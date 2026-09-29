# BUILD
FROM eclipse-temurin:21-jdk-noble as build
WORKDIR /opt/app/
COPY .mvn/ .mvn
COPY mvnw pom.xml .
COPY src ./src
RUN chmod +x mvnw && ./mvnw clean package -DskipTests


# RUN
FROM eclipse-temurin:21-jre-noble as run
WORKDIR /opt/app/
COPY --from=build /opt/app/target .
EXPOSE 8080
CMD ["java", "-jar", "./devops-lab-0.0.1-SNAPSHOT.jar"] 