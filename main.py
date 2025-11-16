from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List

from database import engine, get_db
from models import Todo
import models
from schemas import TodoCreate, TodoUpdate, TodoResponse

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Todo App with PostgreSQL")

# Allow CORS for all origins (change `allow_origins` for production)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Todo API. Visit /docs for interactive API docs."}

@app.get("/todos", response_model=List[TodoResponse])
def list_todos(db: Session = Depends(get_db)):
    return db.query(Todo).all()

@app.post("/todos", response_model=TodoResponse, status_code=201)
def create_todo(item: TodoCreate, db: Session = Depends(get_db)):
    todo = Todo(title=item.title, description=item.description)
    db.add(todo)
    db.commit()
    db.refresh(todo)
    return todo

@app.get("/todos/{todo_id}", response_model=TodoResponse)
def get_todo(todo_id: int, db: Session = Depends(get_db)):
    todo = db.query(Todo).filter(Todo.id == todo_id).first()
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    return todo

@app.put("/todos/{todo_id}", response_model=TodoResponse)
def update_todo(todo_id: int, item: TodoUpdate, db: Session = Depends(get_db)):
    todo = db.query(Todo).filter(Todo.id == todo_id).first()
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    
    if item.title is not None:
        todo.title = item.title
    if item.description is not None:
        todo.description = item.description
    if item.completed is not None:
        todo.completed = item.completed
    
    db.commit()
    db.refresh(todo)
    return todo

@app.delete("/todos/{todo_id}", status_code=204)
def delete_todo(todo_id: int, db: Session = Depends(get_db)):
    todo = db.query(Todo).filter(Todo.id == todo_id).first()
    if not todo:
        raise HTTPException(status_code=404, detail="Todo not found")
    db.delete(todo)
    db.commit()

