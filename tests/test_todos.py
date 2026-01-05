
def test_create_todo(client):
    response = client.post(
        "/api/v1/todos/",
        json={"title": "Test Todo", "description": "Test Description"}
    )
    assert response.status_code == 201
    data = response.json()
    assert data["title"] == "Test Todo"
    assert data["description"] == "Test Description"
    assert "id" in data
    assert data["completed"] is False

def test_read_todos(client):
    # Create a todo first
    client.post(
        "/api/v1/todos/",
        json={"title": "Todo 1", "description": "Desc 1"}
    )
    client.post(
        "/api/v1/todos/",
        json={"title": "Todo 2", "description": "Desc 2"}
    )
    
    response = client.get("/api/v1/todos/")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 2

def test_read_todo(client):
    create_response = client.post(
        "/api/v1/todos/",
        json={"title": "Test Todo", "description": "Test Description"}
    )
    todo_id = create_response.json()["id"]
    
    response = client.get(f"/api/v1/todos/{todo_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == "Test Todo"
    assert data["id"] == todo_id

def test_read_todo_not_found(client):
    response = client.get("/api/v1/todos/999")
    assert response.status_code == 404

def test_update_todo(client):
    create_response = client.post(
        "/api/v1/todos/",
        json={"title": "Test Todo", "description": "Test Description"}
    )
    todo_id = create_response.json()["id"]
    
    response = client.put(
        f"/api/v1/todos/{todo_id}",
        json={"title": "Updated Title", "completed": True}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == "Updated Title"
    assert data["description"] == "Test Description" # Should be unchanged
    assert data["completed"] is True

def test_update_todo_not_found(client):
    response = client.put(
        "/api/v1/todos/999",
        json={"title": "Updated Title"}
    )
    assert response.status_code == 404

def test_delete_todo(client):
    create_response = client.post(
        "/api/v1/todos/",
        json={"title": "Test Todo", "description": "Test Description"}
    )
    todo_id = create_response.json()["id"]
    
    response = client.delete(f"/api/v1/todos/{todo_id}")
    assert response.status_code == 204
    
    # Verify it's gone
    get_response = client.get(f"/api/v1/todos/{todo_id}")
    assert get_response.status_code == 404

def test_delete_todo_not_found(client):
    response = client.delete("/api/v1/todos/999")
    assert response.status_code == 404
