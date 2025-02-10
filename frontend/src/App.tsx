import { useState, useEffect } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'

// Get the API URL from environment variables with absolute URL validation
const getApiBaseUrl = (): string => {
  // Try runtime env first (from env.js)
  const runtimeUrl = window.env?.VITE_API_URL;
  // Fallback to build-time env
  const buildUrl = import.meta.env.VITE_API_URL;
  
  const finalUrl = runtimeUrl || buildUrl;
  
  if (!finalUrl) {
    console.warn('No API URL found in environment variables!');
    return '';
  }

  // Ensure URL is absolute and properly formatted
  try {
    new URL(finalUrl); // This will throw if URL is invalid
    console.log('Using API URL:', finalUrl);
    return finalUrl.endsWith('/') ? finalUrl.slice(0, -1) : finalUrl;
  } catch (e) {
    console.error('Invalid API URL:', finalUrl);
    return '';
  }
};

const apiBaseUrl = getApiBaseUrl();

interface Item {
  item_id: number;
  name: string;
  message: string;
  url: string;
  category: string;
}

interface DemoMetrics {
  total_requests: number;
  last_request: string | null;
  uptime_seconds: number;
  environment: string;
}

interface HealthStatus {
  status: string;
  version: string;
  features: string[];
  timestamp: string;
  metrics: DemoMetrics;
}

function App() {
  const [health, setHealth] = useState<HealthStatus | null>(null)
  const [items, setItems] = useState<Item[]>([])
  const [categories, setCategories] = useState<string[]>([])
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!apiBaseUrl) {
      setError('No valid API URL configured. Please check your environment variables.');
      setLoading(false);
      return;
    }

    // Helper function to handle API calls
    const fetchApi = async (endpoint: string) => {
      // Ensure we're using absolute URLs correctly
      const url = endpoint.startsWith('http') ? endpoint : `${apiBaseUrl}${endpoint}`;
      console.log('Fetching from:', url);
      
      try {
        const response = await fetch(url);
        if (!response.ok) {
          throw new Error(`API call failed: ${endpoint} (Status: ${response.status})`);
        }
        return response.json();
      } catch (error) {
        console.error('API call error:', error);
        throw error;
      }
    };

    // Use absolute URLs for API calls
    Promise.all([
      fetchApi(`${apiBaseUrl}/api/health`),
      fetchApi(`${apiBaseUrl}/api/items`),
      fetchApi(`${apiBaseUrl}/api/categories`)
    ])
      .then(([healthData, itemsData, categoriesData]) => {
        setHealth(healthData)
        setItems(itemsData)
        setCategories(categoriesData)
        setLoading(false)
      })
      .catch((error) => {
        console.error('API Error:', error)
        setError(`Failed to connect to backend: ${error.message}`)
        setLoading(false)
      })
  }, [])

  const filteredItems = selectedCategory
    ? items.filter(item => item.category === selectedCategory)
    : items

  const formatUptime = (seconds: number): string => {
    const hours = Math.floor(seconds / 3600)
    const minutes = Math.floor((seconds % 3600) / 60)
    const remainingSeconds = Math.floor(seconds % 60)
    return `${hours}h ${minutes}m ${remainingSeconds}s`
  }

  return (
    <>
      <header>
        <div className="logos">
          <a href="https://vitejs.dev" target="_blank" rel="noopener">
            <img src={viteLogo} className="logo" alt="Vite logo" />
          </a>
          <a href="https://react.dev" target="_blank" rel="noopener">
            <img src={reactLogo} className="logo react" alt="React logo" />
          </a>
        </div>
        <h1>React + FastAPI Demo</h1>
        <p className="subtitle">A demonstration of containerized frontend-backend integration</p>
      </header>

      <main>
        {loading ? (
          <div className="loading">
            <div className="loading-spinner"></div>
            <p>Connecting to backend...</p>
          </div>
        ) : error ? (
          <div className="error">
            <h2>Connection Error</h2>
            <p>{error}</p>
            <p className="error-help">Make sure both frontend and backend containers are running.</p>
          </div>
        ) : (
          <>
            <section className="health-status">
              <h2>Backend Status</h2>
              <div className="status-details">
                <p><strong>Status:</strong> <span className="badge">{health?.status}</span></p>
                <p><strong>Version:</strong> {health?.version}</p>
                <p><strong>Environment:</strong> <span className="env-badge">{health?.metrics.environment}</span></p>
                <div className="metrics">
                  <strong>Demo Metrics:</strong>
                  <ul>
                    <li>Total Requests: {health?.metrics.total_requests}</li>
                    <li>Uptime: {health?.metrics.uptime_seconds ? formatUptime(health.metrics.uptime_seconds) : 'N/A'}</li>
                    <li>Last Request: {health?.metrics.last_request ? new Date(health.metrics.last_request).toLocaleString() : 'N/A'}</li>
                  </ul>
                </div>
                <div className="features">
                  <strong>Features:</strong>
                  <div className="feature-tags">
                    {health?.features.map(feature => (
                      <span key={feature} className="feature-tag">{feature}</span>
                    ))}
                  </div>
                </div>
              </div>
            </section>

            <section className="demo-items">
              <h2>Technologies Used</h2>
              <div className="category-filter">
                <button 
                  className={`category-btn ${selectedCategory === null ? 'active' : ''}`}
                  onClick={() => setSelectedCategory(null)}
                >
                  All
                </button>
                {categories.map(category => (
                  <button
                    key={category}
                    className={`category-btn ${selectedCategory === category ? 'active' : ''}`}
                    onClick={() => setSelectedCategory(category)}
                  >
                    {category}
                  </button>
                ))}
              </div>
              <div className="items-grid">
                {filteredItems.map(item => (
                  <a 
                    key={item.item_id} 
                    href={item.url}
                    target="_blank"
                    rel="noopener"
                    className="item-card"
                  >
                    <div className="item-category">{item.category}</div>
                    <h3>{item.name}</h3>
                    <p>{item.message}</p>
                  </a>
                ))}
              </div>
            </section>
          </>
        )}
      </main>

      <footer>
        <p>
          This demo shows a containerized React frontend communicating with a FastAPI backend.
          Check out the <a href="/api/docs" target="_blank" rel="noopener">API Documentation</a> for more details.
        </p>
      </footer>
    </>
  )
}

export default App
