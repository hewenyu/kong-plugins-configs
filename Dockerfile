# Dockerfile for kong-plugins-configs

# ---- Build Stage ----
FROM golang:1.24-alpine AS builder

WORKDIR /app

# Copy go.mod and go.sum first to leverage Docker cache
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the application source code
COPY . .

# Build the Go application
# CGO_ENABLED=0 is important for building a static binary that can run in a minimal container
# -ldflags="-s -w" strips debug information and symbols to reduce binary size
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags="-s -w" -o /app/main .

# ---- Runtime Stage ----
FROM alpine:latest

WORKDIR /app

# Copy the pre-built binary from the builder stage
COPY --from=builder /app/main /app/main

# Expose port 8080 (or the port specified by the PORT environment variable)
EXPOSE 8080

# Set the PORT environment variable, can be overridden at runtime
ENV PORT=8080

# Command to run the executable
CMD ["/app/main"]
