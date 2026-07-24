# Dockerfile untuk Lavalink v4 - Railway Deployment
# Base Image: Debian Jammy (Ubuntu LTS) - Full audio support
# Mendukung JDA-NAS native audio library untuk proper encoding

FROM eclipse-temurin:17-jre-jammy

LABEL maintainer="riboncabe500-ctrl"
LABEL description="Lavalink v4 Audio Streaming Server - Railway Edition"

# Set working directory
WORKDIR /lavalink

# Install runtime dependencies
# ⚠️ CRITICAL: libgcc, libc, dan audio libraries HARUS ada untuk JDA-NAS
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    ca-certificates \
    tzdata \
    libgcc-s1 \
    libc6 \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Download Lavalink v4.0.8 dari official GitHub release
RUN echo "⏳ Downloading Lavalink v4.0.8..." && \
    wget -q "https://github.com/lavalink-devs/Lavalink/releases/download/4.0.8/Lavalink.jar" \
    -O /tmp/Lavalink.jar && \
    mv /tmp/Lavalink.jar ./Lavalink.jar && \
    ls -lh ./Lavalink.jar && \
    echo "✅ Download complete!"

# Create necessary directories dengan proper permissions
RUN mkdir -p ./data ./logs && \
    chmod 755 ./data ./logs && \
    echo "✅ Directories created"

# Copy application configuration dari repository
COPY application.yml ./application.yml

# Set environment defaults - CRITICAL FOR RAILWAY
# Railway automatically uses PORT env var for port mapping
ENV PORT=8080
ENV SERVER_PORT=8080
ENV LAVALINK_SERVER_PASSWORD=youshallnotpass

# Java optimizations untuk low-latency audio streaming
# G1GC: Garbage collector untuk minimal pause time
# Memory: 512MB adalah limit optimal untuk Railway free tier
ENV _JAVA_OPTIONS="-Xmx512M -Xms256M -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+ParallelRefProcEnabled -XX:+UnlockDiagnosticVMOptions -XX:G1SummarizeRSetStatsPeriod=1"

# Expose port 8080 (Railway standard port)
EXPOSE 8080

# Health check untuk Railway
# Railway akan check setiap 30 detik apakah service masih healthy
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f -s -H "Authorization: ${LAVALINK_SERVER_PASSWORD}" \
    http://localhost:8080/info || exit 1

# Entrypoint: start Lavalink dengan JVM
ENTRYPOINT ["java", "-jar", "Lavalink.jar"]

# OCI Image labels untuk container metadata
LABEL org.opencontainers.image.title="Lavalink v4"
LABEL org.opencontainers.image.version="4.0.8"
LABEL org.opencontainers.image.source="https://github.com/lavalink-devs/Lavalink"
LABEL org.opencontainers.image.authors="riboncabe500-ctrl"
