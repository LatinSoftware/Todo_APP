from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional, List

app = FastAPI(title="Todo App")

class TodoItem(BaseModel):
    id: int
    title: str
    description: Optional[str] = None
    completed: bool = False

# in-memory store
todos: List[TodoItem] = []
next_id = 1

@app.get("/")
def read_root():
    return {"message": "Todo API. Visit /docs for interactive API docs."}

@app.get("/todos", response_model=List[TodoItem])
def list_todos():
    return todos

class TodoCreate(BaseModel):
    title: str
    description: Optional[str] = None

@app.post("/todos", response_model=TodoItem, status_code=201)
def create_todo(item: TodoCreate):
    global next_id
    todo = TodoItem(id=next_id, title=item.title, description=item.description)
    next_id += 1
    todos.append(todo)
    return todo

@app.get("/todos/{todo_id}", response_model=TodoItem)
def get_todo(todo_id: int):
    for t in todos:
        if t.id == todo_id:
            return t
    raise HTTPException(status_code=404, detail="Todo not found")

@app.put("/todos/{todo_id}", response_model=TodoItem)
def update_todo(todo_id: int, item: TodoCreate, completed: Optional[bool] = None):
    for idx, t in enumerate(todos):
        if t.id == todo_id:
            updated = t.copy(update={"title": item.title, "description": item.description})
            if completed is not None:
                updated.completed = completed
            todos[idx] = updated
            return updated
    raise HTTPException(status_code=404, detail="Todo not found")

@app.delete("/todos/{todo_id}", status_code=204)
def delete_todo(todo_id: int):
    for idx, t in enumerate(todos):
        if t.id == todo_id:
            todos.pop(idx)
            return
    raise HTTPException(status_code=404, detail="Todo not found")
