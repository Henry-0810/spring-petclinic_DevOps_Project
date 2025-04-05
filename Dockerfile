FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/spring-petclinic-*.jar app.jar

EXPOSE 8888

CMD ["java", "-jar", "app.jar", "--server.port=8888"]
