from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import Dict, List, Optional, Union
from datetime import datetime
from pydantic import BaseModel
import os

app = FastAPI(
    title="React + FastAPI Docker Demo",
    description="""
    A demo showcasing containerized React + FastAPI integration.
    
    ## Features Demonstrated
    * Container-to-container communication
    * Hot-reload development environment
    * End-to-end testing with Playwright
    * Health monitoring and metrics
    * Production-ready configurations
    * CI/CD with GitHub Actions
    * Azure Container Apps deployment
    """,
    version="1.0.0",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    openapi_url="/api/openapi.json"
)

class DemoMetrics(BaseModel):
    """Response model for demo metrics."""
    total_requests: int = 0
    last_request: Optional[str] = None
    uptime_seconds: float = 0
    environment: str

class HealthCheck(BaseModel):
    """Response model for health check endpoint."""
    status: str
    version: str
    features: List[str]
    timestamp: str
    metrics: DemoMetrics

class Item(BaseModel):
    """Model for demo items."""
    item_id: int
    name: str
    message: str
    url: str
    category: str

class Welcome(BaseModel):
    """Response model for root endpoint."""
    message: str
    docs_url: str
    timestamp: str
    available_endpoints: List[Dict[str, str]]

# In-memory metrics for demo
request_count = 0
start_time = datetime.now()
last_request_time = None

def parse_cors_origins(origins_str: Optional[str] = None) -> List[str]:
    """Parse CORS origins from environment variable or use defaults."""
    default_origins = ["http://localhost:3000", "http://frontend:3000", "http://localhost", "http://frontend"]
    if not origins_str:
        return default_origins
    try:
        return eval(origins_str)  # type: ignore
    except (SyntaxError, ValueError):
        return default_origins

# Get CORS origins from environment variable or use defaults
origins: List[str] = parse_cors_origins(os.getenv("BACKEND_CORS_ORIGINS"))

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"]
)

DEMO_ITEMS = [
    {
        "item_id": 1, 
        "name": "Docker", 
        "message": "Containerization made simple - package once, run anywhere", 
        "url": "https://www.docker.com/",
        "category": "Infrastructure"
    },
    {
        "item_id": 2, 
        "name": "FastAPI", 
        "message": "Modern Python web framework with automatic API documentation", 
        "url": "https://fastapi.tiangolo.com/",
        "category": "Backend"
    },
    {
        "item_id": 3, 
        "name": "React", 
        "message": "A JavaScript library for building user interfaces", 
        "url": "https://react.dev/",
        "category": "Frontend"
    },
    {
        "item_id": 4, 
        "name": "TypeScript", 
        "message": "JavaScript with syntax for types - catch errors early", 
        "url": "https://www.typescriptlang.org/",
        "category": "Frontend"
    },
    {
        "item_id": 5, 
        "name": "Playwright", 
        "message": "Reliable end-to-end testing for modern web apps", 
        "url": "https://playwright.dev/",
        "category": "Testing"
    },
    {
        "item_id": 6,
        "name": "Azure Container Apps",
        "message": "Fully managed container service with serverless capabilities",
        "url": "https://azure.microsoft.com/en-us/services/container-apps/",
        "category": "Cloud"
    },
    {
        "item_id": 7,
        "name": "GitHub Actions",
        "message": "Automate your software development workflows",
        "url": "https://github.com/features/actions",
        "category": "CI/CD"
    }
]

def get_demo_metrics() -> DemoMetrics:
    """Get current demo metrics."""
    global request_count, last_request_time
    request_count += 1
    last_request_time = datetime.now()
    
    return DemoMetrics(
        total_requests=request_count,
        last_request=last_request_time.isoformat() if last_request_time else None,
        uptime_seconds=(datetime.now() - start_time).total_seconds(),
        environment=os.getenv("ENVIRONMENT", "development")
    )

@app.get("/api/", response_model=Welcome)
def read_root() -> Dict[str, Union[str, List[Dict[str, str]]]]:
    """
    Get welcome message and API information.
    
    Returns:
        Welcome message, documentation URL, and list of available endpoints
    """
    return {
        "message": "Welcome to the FastAPI backend!",
        "docs_url": "/api/docs",
        "timestamp": datetime.now().isoformat(),
        "available_endpoints": [
            {
                "path": "/api/health",
                "description": "Health check with demo metrics"
            },
            {
                "path": "/api/items",
                "description": "List all technologies used in this demo"
            },
            {
                "path": "/api/items/{item_id}",
                "description": "Get details about a specific technology"
            },
            {
                "path": "/api/categories",
                "description": "List technology categories"
            },
            {
                "path": "/api/items/category/{category}",
                "description": "List technologies by category"
            }
        ]
    }

@app.get("/api/items/{item_id}", response_model=Item)
def read_item(item_id: int) -> Dict[str, Union[str, int]]:
    """
    Get a specific item by ID.
    
    Args:
        item_id: The ID of the item to retrieve
        
    Returns:
        Item details including name, description, and category
        
    Raises:
        HTTPException: If item is not found
    """
    item = next((item for item in DEMO_ITEMS if item["item_id"] == item_id), None)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item

@app.get("/api/items", response_model=List[Item])
def list_items() -> List[Dict[str, Union[str, int]]]:
    """
    Get all available demo items.
    
    Returns:
        List of items with their details
    """
    return DEMO_ITEMS

@app.get("/api/categories")
def list_categories() -> List[str]:
    """
    Get all available technology categories.
    
    Returns:
        List of unique categories
    """
    return sorted(list(set(item["category"] for item in DEMO_ITEMS)))

@app.get("/api/items/category/{category}", response_model=List[Item])
def list_items_by_category(category: str) -> List[Dict[str, Union[str, int]]]:
    """
    Get items filtered by category.
    
    Args:
        category: The category to filter by
        
    Returns:
        List of items in the specified category
        
    Raises:
        HTTPException: If category is not found
    """
    items = [item for item in DEMO_ITEMS if item["category"].lower() == category.lower()]
    if not items:
        raise HTTPException(status_code=404, detail="Category not found")
    return items

@app.get("/api/health", response_model=HealthCheck)
async def health_check() -> Dict[str, Union[str, List[str], DemoMetrics]]:
    """
    Check the health status of the API.
    
    Returns:
        Health status, version, features, and current metrics
    """
    return {
        "status": "ok",
        "version": "1.0.0",
        "features": [
            "Docker Integration",
            "FastAPI Backend",
            "React Frontend",
            "TypeScript Support",
            "E2E Testing",
            "Azure Deployment",
            "GitHub Actions CI/CD"
        ],
        "timestamp": datetime.now().isoformat(),
        "metrics": get_demo_metrics()
    }