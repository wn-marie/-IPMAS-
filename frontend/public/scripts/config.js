/**
 * IPMAS Frontend Configuration
 * Configuration for frontend to connect to backend API
 * Automatically detects production vs development environment
 */

// Detect environment
const isProduction = window.location.hostname !== 'localhost' && window.location.hostname !== '127.0.0.1';
const defaultBackendUrl = isProduction 
    ? window.location.origin.replace(/^https?:\/\/([^.]+)/, 'https://$1-backend') // Auto-detect backend URL
    : 'http://localhost:3001';

// Get backend URL from environment variable or use default
const getBackendUrl = () => {
    // Check if API_URL is set in window (can be set by deployment platform)
    if (window.API_URL) {
        return window.API_URL;
    }
    // Check if set via meta tag (for static deployments)
    const metaApiUrl = document.querySelector('meta[name="api-url"]');
    if (metaApiUrl) {
        return metaApiUrl.getAttribute('content');
    }
    return defaultBackendUrl;
};

// Backend API Configuration
const API_CONFIG = {
    // Backend URL - automatically detected or can be overridden
    BASE_URL: getBackendUrl(),
    // Socket.IO server URL (same as backend)
    SOCKET_URL: getBackendUrl(),
    VERSION: 'v1',
    ENDPOINTS: {
        ANALYTICS: '/api/v1/analytics',
        LOCATION: '/api/v1/location',
        REPORTS: '/api/v1/reports',
        QUESTIONNAIRE: '/api/v1/questionnaire',
        FEEDBACK: '/api/v1/feedback',
        UNIFIED_DATA: '/api/v1/unified-data'
    },
    // Helper function to get full API URL
    getApiUrl: function(endpoint) {
        return `${this.BASE_URL}${endpoint}`;
    },
    // Helper function to get Socket.IO URL
    getSocketUrl: function() {
        return this.SOCKET_URL;
    }
};

// Frontend Configuration
const FRONTEND_CONFIG = {
    // Frontend runs on port 3000
    BASE_URL: 'http://localhost:3000',
    PAGES: {
        HOME: '/',
        POVERTY_MODELS: '/poverty-models.html',
        PROJECTS: '/projects.html',
        SETTINGS: '/settings.html',
        TEST_CHARTS: '/test-charts.html'
    }
};

// Make available globally
window.API_CONFIG = API_CONFIG;
window.FRONTEND_CONFIG = FRONTEND_CONFIG;

// Export for use in modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { API_CONFIG, FRONTEND_CONFIG };
}

