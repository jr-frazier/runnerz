# ----- Build stage -----
FROM maven:3.9.9-eclipse-temurin-25 AS build
WORKDIR /app

# Pre-fetch dependencies to leverage Docker layer caching
COPY pom.xml ./
RUN mvn -q -DskipTests dependency:go-offline

# Copy sources and build the app
COPY src ./src
RUN mvn -q -DskipTests package

# ----- Runtime stage -----
FROM eclipse-temurin:25-jre
ENV APP_HOME=/app
WORKDIR ${APP_HOME}

# Copy the fat jar from the build stage
COPY --from=build /app/target/*.jar app.jar

# Render routes traffic to the port exposed by the container.
# Spring Boot defaults to 8080; we also honor Render's PORT env var at runtime.
EXPOSE 8080

# Run as a non-root user for better security
RUN useradd -u 10001 spring
USER 10001

# Use sh -c so we can expand $PORT and $JAVA_OPTS provided by the platform
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar --server.port=${PORT:-8080}"]
