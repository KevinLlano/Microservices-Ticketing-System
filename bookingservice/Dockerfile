FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy the JAR file
COPY target/bookingservice-*.jar app.jar

# Expose the port your application runs on
EXPOSE 8081

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
