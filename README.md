# Todo App (FastAPI)

A minimal TODO app using FastAPI with in-memory storage (no database).

## Files added

- `main.py` - FastAPI application with endpoints
- `requirements.txt` - pip dependencies
- `environment.yml` - Conda environment file (optional)

## Create environment & install (Conda)

Open PowerShell and run:

```powershell
conda env create -f environment.yml
conda activate todo-app
pip install -r requirements.txt  # optional if environment.yml already installed pip packages
```

## Create environment & install (venv)

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

## Run the server

```powershell
python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000
```

Then open http://127.0.0.1:8000/docs for the interactive API docs (Swagger UI).

## Endpoints

- `GET /todos` - list all todos
- `POST /todos` - create a todo (JSON body: `title`, optional `description`)
- `GET /todos/{id}` - get todo by id
- `PUT /todos/{id}` - update a todo (body: `title`, optional `description`, optional `completed` query)
- `DELETE /todos/{id}` - delete todo

## Examples (curl)

Create:

```powershell
curl -X POST "http://127.0.0.1:8000/todos" -H "Content-Type: application/json" -d '{"title": "Buy milk", "description": "2 liters"}'
```

List:

```powershell
curl http://127.0.0.1:8000/todos
```

Get:

```powershell
curl http://127.0.0.1:8000/todos/1
```

Update (set completed=true):

```powershell
curl -X PUT "http://127.0.0.1:8000/todos/1?completed=true" -H "Content-Type: application/json" -d '{"title":"Buy milk","description":"2 liters"}'
```

Delete:

```powershell
curl -X DELETE http://127.0.0.1:8000/todos/1
```
