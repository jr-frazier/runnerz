# Multi-stage build: build the Spring Boot app, then run it on a slim JRE image

# ---- Build stage ----
FROM maven:3.9-eclipse-temurin-25 AS build
WORKDIR /app

# Copy only pom first to leverage Docker layer caching for dependencies
COPY pom.xml ./
RUN mvn -B -q -e -DskipTests dependency:go-offline

# Copy sources and build
COPY src ./src
RUN mvn -B -q -DskipTests package

# ---- Runtime stage ----
FROM eclipse-temurin:25-jre
WORKDIR /app

# Optional: runtime JVM options can be provided via JAVA_OPTS env var
ENV JAVA_OPTS=""

# Copy the built jar from the build stage
COPY --from=build /app/target/*.jar app.jar

# Spring Boot defaults to 8080
EXPOSE 8080

# Allow passing extra JVM flags with JAVA_OPTS
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
