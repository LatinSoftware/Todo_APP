#!/bin/bash

# Update system and install dependencies
sudo yum update -y
sudo amazon-linux-extras enable python3.11
sudo yum install -y python3.11 python3.11-venv python3.11-devel gcc postgresql postgresql-server postgresql-devel git

# Initialize and start PostgreSQL
sudo postgresql-setup --initdb
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Create PostgreSQL user and database
sudo -u postgres psql <<EOF
CREATE USER todo_user WITH PASSWORD 'todo_password';
CREATE DATABASE todo_db OWNER todo_user;
EOF

# Clone your app (if not already present)
# git clone <your-repo-url> ~/Todo_APP
cd ~/Todo_APP

# Set up Python virtual environment
python3.11 -m venv todo-app-env
source todo-app-env/bin/activate

# Upgrade pip and install requirements
pip install --upgrade pip
pip install -r requirements.txt

# Set environment variables (adjust as needed)
export DATABASE_URL="postgresql+psycopg2://todo_user:todo_password@localhost/todo_db"

# Run the FastAPI app (adjust host/port as needed)
uvicorn main:app --host 0.0.0.0 --port 8000