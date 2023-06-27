# Use a Java 17 base image
FROM openjdk:17-jdk

# Set the working directory inside the container
WORKDIR /app

# Copy the JAR file into the container
COPY target/cloudraft-app-1.0-SNAPSHOT.jar cloudraft-app-1.0-SNAPSHOT.jar

# Expose the port your application is running on
EXPOSE 8080

# Set the command to run your application
CMD ["java", "-jar", "cloudraft-app-1.0-SNAPSHOT.jar"]
