# Dockerfile untuk Lavalink v4 dengan Railway compatibility
# Build di Railway: dockerfile builder
# Runtime: Alpine Linux (lightweight & secure)

FROM eclipse-temurin:17-jre-alpine

LABEL maintainer="riboncabe500-ctrl"
LABEL description="Lavalink v4 Audio Streaming Server"

# Set working directory
WORKDIR /lavalink

# Install dependencies
RUN apk add --no-cache \
    curl \
    ca-certificates \
    tzdata \
    wget \
    && rm -rf /var/cache/apk/*

# Download Lavalink v4 JAR dari official release
# Version: 4.0.8 (latest stable)
RUN echo "Downloading Lavalink v4.0.8..." && \
    wget -q "https://github.com/lavalink-devs/Lavalink/releases/download/4.0.8/Lavalink.jar" \
    -O Lavalink.jar && \
    ls -lh Lavalink.jar && \
    echo "Download complete!"

# Create necessary directories dengan proper permissions
RUN mkdir -p ./data ./logs && \
    chmod 755 ./data ./logs && \
    echo "Directories created"

# Copy application configuration
COPY application.yml ./application.yml

# Health check - Railway akan use ini untuk detect if service is healthy
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f -s -H "Authorization: ${LAVALINK_SERVER_PASSWORD:-youshallnotpass}" \
    http://localhost:${SERVER_PORT:-443}/info || exit 1

# Expose port (Railway akan handle port mapping)
EXPOSE ${SERVER_PORT:-443}

# Set Java options untuk optimal performance
# G1GC: Low-latency garbage collection untuk audio streaming
# Memory: 512MB max (Railway free tier limit)
ENV _JAVA_OPTIONS="-Xmx512M -Xms256M -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:G1NewCollectionHeuristicPercent=35 -XX:G1ReservePercent=20 -XX:G1HeapRegionSize=16M"

# Set default port (akan override dengan environment variable)
ENV SERVER_PORT=443

# Set default password (HARUS diganti di Railway environment)
ENV LAVALINK_SERVER_PASSWORD=youshallnotpass

# Entrypoint: start Lavalink
ENTRYPOINT ["java", "-jar", "Lavalink.jar"]

# Metadata labels
LABEL org.opencontainers.image.title="Lavalink v4"
LABEL org.opencontainers.image.version="4.0.8"
LABEL org.opencontainers.image.source="https://github.com/lavalink-devs/Lavalink"
