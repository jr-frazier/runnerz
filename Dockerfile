# ----- Build stage -----
FROM eclipse-temurin:25-jdk AS build
WORKDIR /app

# Install Maven (since an official Maven image for Temurin 25 may not exist yet)
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl tar gzip \
    && rm -rf /var/lib/apt/lists/*

ARG MAVEN_VERSION=3.9.9
ARG MAVEN_BASE_URL=https://dlcdn.apache.org/maven/maven-3
RUN curl -fsSL ${MAVEN_BASE_URL}/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -o /tmp/maven.tar.gz \
    && tar -xzf /tmp/maven.tar.gz -C /opt \
    && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
    && rm -f /tmp/maven.tar.gz
ENV MAVEN_HOME=/opt/maven
ENV PATH=${MAVEN_HOME}/bin:${PATH}

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
RUN useradd -u 10001 spring || adduser --uid 10001 --disabled-password --gecos "" spring
USER 10001

# Use sh -c so we can expand $PORT and $JAVA_OPTS provided by the platform
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar --server.port=${PORT:-8080}"]
