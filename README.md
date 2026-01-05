# Todo App (FastAPI + PostgreSQL)

A TODO app using FastAPI with PostgreSQL database and SQLAlchemy ORM, organized with best practices.

## Project Structure

```text
app/
  api/          # API Routers
    v1/         # API Version 1
  core/         # Configuration and Database setup
  models/       # SQLAlchemy Models
  schemas/      # Pydantic Schemas
  main.py       # App Entry point
Dockerfile      # Docker configuration
docker-compose.yaml # Docker Orchestration
```

## Prerequisites

- Python 3.11+ or Docker & Docker Compose

## Quick Start (Docker)

The easiest way to run the project is using Docker Compose:

```powershell
docker-compose up --build
```

The API will be available at `http://localhost:8000`.

## Local Development (Manual)

### 1. Environment Setup

Create a `.env` file in the project root:

```text
DATABASE_URL=postgresql://user:password@localhost/todoapp
```

### 2. Install Dependencies (using uv)

```powershell
uv sync
```

### 3. Run the server

```powershell
uv run fastapi dev app/main.py
```

Then open [http://localhost:8000/docs](http://localhost:8000/docs) for the interactive API docs.

## API Endpoints (v1)

All API endpoints are prefixed with `/api/v1`.

- `GET /api/v1/todos` - List all todos
- `POST /api/v1/todos` - Create a todo
- `GET /api/v1/todos/{id}` - Get todo by id
- `PUT /api/v1/todos/{id}` - Update a todo
- `DELETE /api/v1/todos/{id}` - Delete todo
