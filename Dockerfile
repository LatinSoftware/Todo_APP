# Use a multi-stage build to keep the final image slim
FROM python:3.12-slim AS builder

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Set working directory
WORKDIR /app

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy only dependency files first to leverage Docker cache
COPY pyproject.toml uv.lock ./

# Install dependencies without installing the project itself
# --no-dev: exclude dev dependencies like pytest/ruff
# --frozen: ensure lockfile consistency
RUN uv sync --frozen --no-install-project --no-dev

# Final stage
FROM python:3.12-slim

WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
# Add the virtualenv bin to PATH
ENV PATH="/app/.venv/bin:$PATH"

# Copy the virtualenv from builder
COPY --from=builder /app/.venv /app/.venv

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Create a non-root user for security
RUN addgroup --system appgroup && adduser --system --group appuser
USER appuser

# Healthcheck using python since curl is not installed in slim image
HEALTHCHECK --interval=30s --timeout=3s \
  CMD python3 -c 'import urllib.request; urllib.request.urlopen("http://localhost:8000/")' || exit 1

# Run the application using the uvicorn from the virtualenv
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
