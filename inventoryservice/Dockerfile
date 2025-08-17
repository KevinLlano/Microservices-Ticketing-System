FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy the JAR file
COPY target/inventoryservice-*.jar app.jar

# Expose the port your application runs on
EXPOSE 8082

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
