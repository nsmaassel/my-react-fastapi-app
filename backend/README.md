# FastAPI Backend

This directory contains the backend of the application built using FastAPI.

## Setup Instructions

1. **Clone the repository**:
   ```
   git clone https://github.com/yourusername/my-react-fastapi-app.git
   cd my-react-fastapi-app/backend
   ```

2. **Install dependencies**:
   You can install the required Python packages using pip:
   ```
   pip install -r requirements.txt
   ```

3. **Run the application**:
   You can run the FastAPI application using Uvicorn:
   ```
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```

   Alternatively, you can use Docker to run the application:
   ```
   docker-compose up backend
   ```

## API Usage

The FastAPI application exposes several endpoints. You can access the interactive API documentation at `http://localhost:8000/docs` once the application is running.

## Docker

To build and run the Docker container for the backend, use the following command:
```
docker build -t my-fastapi-backend .
```
Then run the container:
```
docker run -p 8000:8000 my-fastapi-backend
```

## Notes

- Ensure that you have Docker and Docker Compose installed on your machine.
- The backend is configured to run on port 8000 by default. Adjust the port in the `docker-compose.yml` file if necessary.