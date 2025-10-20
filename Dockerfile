# Multi-stage Dockerfile for Suit Tracker Backend
# Optimized for production deployment with security best practices
# Uses mise for version management (consistent with mise.toml)

# Build stage - compile the Deno application
FROM debian:bookworm-slim AS builder

WORKDIR /app

# Install mise and dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install mise
RUN curl https://mise.run | sh
ENV PATH="/root/.local/bin:${PATH}"

# Copy mise configuration to install correct Deno version
COPY mise.toml ./

# Trust the mise configuration and install Deno via mise
RUN mise trust && \
    mise install && \
    mise which deno

# Copy dependency files first for better layer caching
# Note: We skip root deno.json (workspace config) and only copy server-specific config
COPY deno.lock ./
COPY server/deno.json ./server/
COPY lib/ ./lib/

# Copy source code
COPY server/ ./server/

# Build the application using mise-managed Deno
# Creates a self-contained x86_64 Linux binary
WORKDIR /app/server
RUN cd /app && mise trust && cd /app/server && mise exec -- deno task build

# Runtime stage - minimal image for production
FROM debian:bookworm-slim

# Install only required runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN useradd -r -u 1001 -g root tracksuit

WORKDIR /app

# Copy the compiled binary from builder
COPY --from=builder /app/server/build/server /app/server

# Create directory for SQLite database with proper permissions
RUN mkdir -p /app/tmp && \
    chown -R tracksuit:root /app && \
    chmod -R 755 /app

# Switch to non-root user
USER tracksuit

# Expose the application port
EXPOSE 8080

# Set environment variables
ENV SERVER_PORT=8080

# Health check - ensures container orchestrator can monitor service health
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/_health || exit 1

# Run the application
CMD ["/app/server"]

