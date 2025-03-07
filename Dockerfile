FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/spring-petclinic-*.jar app.jar

EXPOSE 9090

CMD ["java", "-jar", "app.jar"]
