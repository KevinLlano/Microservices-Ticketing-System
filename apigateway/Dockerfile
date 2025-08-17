FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy the JAR file
COPY target/apigateway-*.jar app.jar

# Expose the port your application runs on
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
