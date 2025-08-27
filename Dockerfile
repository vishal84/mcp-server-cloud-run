
# Stage 1: Get uv binary
FROM ghcr.io/astral-sh/uv:latest as uv-builder

# Stage 2: Main image
FROM python:3.13-slim

# Copy uv binary from builder
COPY --from=uv-builder /uv /usr/local/bin/uv

# Install the project into /app
WORKDIR /app
COPY . /app

# Allow statements and log messages to immediately appear in the logs
ENV PYTHONUNBUFFERED=1

# Install dependencies
RUN uv sync

EXPOSE 8080

# Run the FastMCP server using uv (uses pyproject.toml [tool.uv] run)
CMD ["uv", "run", "server.py"]