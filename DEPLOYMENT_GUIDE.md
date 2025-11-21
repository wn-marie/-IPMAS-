# 🚀 IPMAS Deployment Guide

Complete guide for deploying IPMAS frontend and backend to production.

---

## 📋 Table of Contents

- [Quick Start Options](#quick-start-options)
- [Recommended Platforms](#recommended-platforms)
- [Docker Deployment](#docker-deployment)
- [Environment Configuration](#environment-configuration)
- [Step-by-Step Guides](#step-by-step-guides)
- [Post-Deployment Checklist](#post-deployment-checklist)

---

## 🎯 Quick Start Options

### Option 1: **Fly.io** (Recommended - Generous Free Tier) ⭐
**Best for**: Free hosting with no spin-downs
- **Cost**: Free tier available, then ~$6-10/month
- **Pros**:
  - Generous free tier (3 VMs, 3GB storage)
  - PostgreSQL with PostGIS included
  - No spin-downs on free tier
  - Global edge network
  - Docker-based deployment
- **Cons**: Requires CLI installation

### Option 2: **Render** (Great for Free Tier)
**Best for**: Free hosting with good features
- **Cost**: Free tier available, then ~$7-25/month
- **Pros**:
  - Free PostgreSQL database
  - Free static site hosting
  - Automatic SSL
  - Good documentation
- **Cons**: Free tier spins down after inactivity

### Option 3: **DigitalOcean App Platform**
**Best for**: Production-ready, scalable
- **Cost**: ~$12-25/month
- **Pros**:
  - Managed PostgreSQL with PostGIS
  - Auto-scaling
  - Great performance
  - Professional support
- **Cons**: More expensive than alternatives

### Option 4: **Vercel (Frontend) + Fly.io/Render (Backend)**
**Best for**: Best performance, separate optimization
- **Cost**: Free tier available
- **Pros**:
  - Vercel excellent for static sites
  - Edge network for fast loading
  - Easy CI/CD
- **Cons**: Need to manage two platforms

---

## 🏆 Recommended Platforms by Use Case

### For Quick Demo/Testing:
1. **Fly.io** (Full stack) - Generous free tier, no spin-downs ⭐
2. **Render** (Full stack) - Good free tier

### For Production:
1. **DigitalOcean App Platform** - Best balance
2. **AWS Elastic Beanstalk** - Enterprise scale
3. **Google Cloud Run** - Serverless containers

### For Budget-Conscious:
1. **Render** - Best free tier
2. **Fly.io** - Generous free tier
3. **Heroku** (if using Eco dynos)

---

## 🐳 Docker Deployment

### Prerequisites
- Docker and Docker Compose installed
- Domain name (optional, can use provided subdomain)

### Quick Docker Deploy

```bash
# 1. Clone repository
git clone https://github.com/wn-marie/-IPMAS-.git
cd IPMAS-

# 2. Set up environment variables
cp backend/env backend/.env
# Edit backend/.env with production values

# 3. Build and start
docker-compose up -d

# 4. Check logs
docker-compose logs -f
```

### Production Docker Compose

Create `docker-compose.prod.yml`:

```yaml
version: '3.8'

services:
  postgres:
    image: postgis/postgis:15-3.3
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - ipmas-network
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    networks:
      - ipmas-network
    restart: unless-stopped

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    environment:
      - NODE_ENV=production
      - PORT=3001
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_NAME=${DB_NAME}
      - DB_USER=${DB_USER}
      - DB_PASSWORD=${DB_PASSWORD}
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - JWT_SECRET=${JWT_SECRET}
      - CORS_ORIGIN=${FRONTEND_URL}
    depends_on:
      - postgres
      - redis
    networks:
      - ipmas-network
    restart: unless-stopped

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    environment:
      - API_URL=${BACKEND_URL}
    depends_on:
      - backend
    networks:
      - ipmas-network
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - frontend
      - backend
    networks:
      - ipmas-network
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:

networks:
  ipmas-network:
    driver: bridge
```

---

## ⚙️ Environment Configuration

### Backend Environment Variables

Create `backend/.env`:

```env
# Server
PORT=3001
NODE_ENV=production

# Database (use provided connection string from platform)
DB_HOST=your-db-host
DB_PORT=5432
DB_NAME=ipmas_db
DB_USER=ipmas_user
DB_PASSWORD=your-secure-password
# OR use DATABASE_URL
DATABASE_URL=postgresql://user:password@host:5432/ipmas_db

# Redis (optional but recommended)
REDIS_HOST=your-redis-host
REDIS_PORT=6379
REDIS_PASSWORD=your-redis-password

# Security
JWT_SECRET=your-very-secure-random-secret-key-here
CORS_ORIGIN=https://your-frontend-domain.com

# API
API_VERSION=v1
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Logging
LOG_LEVEL=info
LOG_FILE=logs/app.log

# External Services
MAPBOX_API_KEY=your-mapbox-key
OPENSTREETMAP_API_URL=https://api.openstreetmap.org
```

### Frontend Configuration

Update `frontend/public/scripts/config.js`:

```javascript
const API_CONFIG = {
    BASE_URL: 'https://your-backend-api.com',
    SOCKET_URL: 'https://your-backend-api.com',
    // ... rest of config
};
```

---

## 📝 Step-by-Step Guides

### Guide 1: Deploy to Fly.io (Recommended - Generous Free Tier) ⭐

See **[FLYIO_DEPLOYMENT_GUIDE.md](FLYIO_DEPLOYMENT_GUIDE.md)** for complete step-by-step instructions.

**Quick Summary:**
1. Install Fly CLI: `iwr https://fly.io/install.ps1 -useb | iex` (Windows)
2. Login: `flyctl auth login`
3. Create PostgreSQL: `flyctl postgres create --name ipmas-db --region ord`
4. Enable PostGIS: `flyctl postgres connect -a ipmas-db` then `CREATE EXTENSION postgis;`
5. Deploy backend: `cd backend && flyctl launch --name ipmas-backend`
6. Attach database: `flyctl postgres attach ipmas-db -a ipmas-backend`
7. Set secrets: `flyctl secrets set JWT_SECRET="..." -a ipmas-backend`
8. Deploy: `flyctl deploy -a ipmas-backend`
9. Deploy frontend: `cd frontend && flyctl launch --name ipmas-frontend`
10. Update CORS: `flyctl secrets set CORS_ORIGIN="..." -a ipmas-backend`

**Full Guide**: [FLYIO_DEPLOYMENT_GUIDE.md](FLYIO_DEPLOYMENT_GUIDE.md)

---

### Guide 2: Deploy to Render

#### Backend Deployment:

1. **Sign up** at [render.com](https://render.com)
2. **New** → "Web Service"
3. **Connect GitHub** and select repository
4. **Configure**:
   - Name: `ipmas-backend`
   - Environment: `Node`
   - Root Directory: `backend`
   - Build Command: `npm install`
   - Start Command: `npm start`
5. **Add PostgreSQL Database**:
   - New → "PostgreSQL"
   - Name: `ipmas-db`
   - Note: Render PostgreSQL doesn't include PostGIS by default
   - You'll need to enable it manually or use a custom image
6. **Add Redis** (optional):
   - New → "Redis"
7. **Set Environment Variables** (in Web Service settings)
8. **Deploy**

#### Frontend Deployment:

1. **New** → "Static Site"
2. **Connect GitHub** repository
3. **Configure**:
   - Root Directory: `frontend/public`
   - Build Command: (leave empty or `npm install`)
   - Publish Directory: `frontend/public`
4. **Set Environment Variables**:
   ```
   API_URL=https://your-backend.onrender.com
   ```
5. **Update config.js** with backend URL
6. **Deploy**

---

### Guide 3: Deploy to DigitalOcean App Platform

1. **Sign up** at [digitalocean.com](https://digitalocean.com)
2. **Create App** → "GitHub" → Select repository
3. **Add Database**:
   - PostgreSQL 15
   - Enable PostGIS extension (available in DO)
4. **Add Backend Component**:
   - Source: `backend/`
   - Build Command: `npm install`
   - Run Command: `npm start`
   - HTTP Port: `3001`
5. **Add Frontend Component**:
   - Source: `frontend/`
   - Build Command: `npm install`
   - Run Command: `npm start`
   - HTTP Port: `3000`
6. **Configure Environment Variables**
7. **Deploy**

---

### Guide 4: Deploy Frontend to Vercel + Backend to Fly.io/Render

#### Frontend (Vercel):

1. **Sign up** at [vercel.com](https://vercel.com)
2. **Import Project** from GitHub
3. **Configure**:
   - Root Directory: `frontend`
   - Framework Preset: "Other"
   - Build Command: (leave empty)
   - Output Directory: `public`
4. **Set Environment Variables**:
   ```
   NEXT_PUBLIC_API_URL=https://your-backend.onrender.com
   ```
5. **Update config.js** before deploying
6. **Deploy**

#### Backend (Render):
Follow Render backend deployment steps in Guide 1 above.

---

## ✅ Post-Deployment Checklist

### Backend:
- [ ] Backend is accessible via HTTPS
- [ ] Database connection working
- [ ] PostGIS extension enabled
- [ ] Redis connection working (if used)
- [ ] Environment variables set correctly
- [ ] CORS configured for frontend domain
- [ ] Health check endpoint responding
- [ ] API endpoints accessible
- [ ] Socket.IO connection working

### Frontend:
- [ ] Frontend accessible via HTTPS
- [ ] API configuration updated with backend URL
- [ ] Socket.IO connection working
- [ ] Map tiles loading correctly
- [ ] All API calls working
- [ ] No CORS errors in console

### Database:
- [ ] PostGIS extension installed
- [ ] Database seeded with location data
- [ ] ML models accessible
- [ ] Database backups configured

### Security:
- [ ] HTTPS enabled (automatic on most platforms)
- [ ] JWT_SECRET is strong and unique
- [ ] Database passwords are secure
- [ ] CORS properly configured
- [ ] Rate limiting enabled
- [ ] Environment variables not exposed

### Monitoring:
- [ ] Logs accessible
- [ ] Error tracking set up (optional: Sentry)
- [ ] Uptime monitoring (optional: UptimeRobot)
- [ ] Performance monitoring

---

## 🔧 Troubleshooting

### Common Issues:

1. **PostGIS not available**:
   - Use `postgis/postgis` Docker image
   - Or enable extension manually: `CREATE EXTENSION postgis;`

2. **CORS errors**:
   - Check `CORS_ORIGIN` in backend env
   - Ensure frontend URL matches exactly

3. **Database connection fails**:
   - Verify connection string format
   - Check database is accessible from backend
   - Ensure firewall rules allow connection

4. **Socket.IO not working**:
   - Check WebSocket support on platform
   - Verify Socket.IO URL in frontend config
   - Check CORS settings for WebSocket

5. **Frontend can't reach backend**:
   - Verify backend URL in config.js
   - Check backend is publicly accessible
   - Verify HTTPS/HTTP matches

---

## 📚 Additional Resources

- [Fly.io Documentation](https://fly.io/docs)
- [Fly.io PostgreSQL Guide](https://fly.io/docs/postgres/)
- [Render Documentation](https://render.com/docs)
- [DigitalOcean App Platform Docs](https://docs.digitalocean.com/products/app-platform/)
- [Vercel Documentation](https://vercel.com/docs)
- [PostGIS Documentation](https://postgis.net/documentation/)

---

## 💡 Quick Recommendations

**For free hosting**: Use **Fly.io** - generous free tier, no spin-downs ⭐
**For production**: Use **DigitalOcean** - best balance of features and cost
**For best performance**: Use **Vercel (frontend) + Fly.io (backend)**

---

**Last Updated**: January 2025

