pipeline {
    agent {
        // Usamos una imagen ligera de Python
        docker { image 'python:3.12-slim' }
    }

    environment {
        // Evita que uv genere archivos en carpetas protegidas
        UV_CACHE_DIR = '.uv_cache'
    }

    stages {
        stage('Checkout') {
            steps {
                // Descarga el código de GitHub
                git branch: 'main', url: 'https://github.com/TU_USUARIO/TU_REPO.git'
            }
        }

        stage('Install uv & Dependencies') {
            steps {
                script {
                    sh '''
                    # Instalar uv mediante el script oficial
                    curl -LsSf https://astral.sh/uv/install.sh | sh
                    source $HOME/.cargo/env
                    
                    # Sincronizar dependencias
                    uv sync --frozen
                    '''
                }
            }
        }

        stage('Lint & Static Analysis') {
            steps {
                script {
                    sh '''
                    source $HOME/.cargo/env
                    # Ejemplo ejecutando ruff (común con uv)
                    uv run ruff check .
                    '''
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    sh '''
                    source $HOME/.cargo/env
                    # Ejecutar pruebas con pytest
                    uv run pytest
                    '''
                }
            }
        }
    }
    
    post {
        always {
            // Limpieza opcional
            echo 'Finalizando el pipeline...'
        }
    }
}