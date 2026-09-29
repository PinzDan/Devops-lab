FROM eclipse-temurin:21
WORKDIR /opt/app/
COPY target/devops-lab-0.0.1-SNAPSHOT.jar .
EXPOSE 8080
CMD ["java", "-jar", "./devops-lab-0.0.1-SNAPSHOT.jar"] 