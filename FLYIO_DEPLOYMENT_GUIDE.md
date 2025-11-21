# 🚀 Fly.io Deployment Guide - IPMAS

Complete step-by-step guide for deploying IPMAS to Fly.io (generous free tier).

---

## 📋 Prerequisites

- GitHub account (repository: https://github.com/wn-marie/-IPMAS-.git)
- Fly.io account (free at [fly.io](https://fly.io))
- Fly CLI installed (`flyctl`)
- ~25 minutes for setup

---

## 🎯 Why Fly.io?

- ✅ **Generous free tier** - 3 shared-cpu VMs, 3GB persistent volumes
- ✅ **PostgreSQL with PostGIS** - Managed database with PostGIS extension
- ✅ **Global edge network** - Fast performance worldwide
- ✅ **Docker-based** - Works with your existing Dockerfiles
- ✅ **Automatic HTTPS** - SSL certificates included
- ✅ **No spin-downs** - Services stay running on free tier
- ✅ **CLI-based** - Easy deployment and management

---

## 📝 Step 1: Install Fly CLI

### Windows (PowerShell):

```powershell
# Using PowerShell
iwr https://fly.io/install.ps1 -useb | iex
```

### macOS/Linux:

```bash
curl -L https://fly.io/install.sh | sh
```

### Verify Installation:

```bash
flyctl version
```

---

## 📝 Step 2: Sign Up and Login

1. Go to [fly.io](https://fly.io)
2. Click **"Sign Up"** (free account)
3. Sign up with GitHub (recommended)
4. Login via CLI:

```bash
flyctl auth login
```

This will open your browser to authenticate.

---

## 🗄️ Step 3: Create PostgreSQL Database

**Important**: Create the database FIRST so you can reference it when setting up the backend.

1. Create a PostgreSQL database:

```bash
flyctl postgres create --name ipmas-db --region ord --vm-size shared-cpu-1x --volume-size 3
```

**Options:**
- `--name`: Database name (must be unique)
- `--region`: Choose closest region (e.g., `ord` for Chicago, `iad` for Virginia, `lhr` for London)
- `--vm-size`: `shared-cpu-1x` (free tier) or `shared-cpu-2x` for better performance
- `--volume-size`: 3GB (free tier) or larger for production

2. **Wait for database to be created** (takes 2-3 minutes)

3. **Get connection details:**

```bash
flyctl postgres connect -a ipmas-db
```

Or get the connection string:

```bash
flyctl postgres connect -a ipmas-db --command "echo \$DATABASE_URL"
```

### Enable PostGIS Extension

Fly.io PostgreSQL includes PostGIS! Just enable it:

```bash
flyctl postgres connect -a ipmas-db
```

Then in the psql console:

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
```

Verify:

```sql
SELECT * FROM pg_extension WHERE extname LIKE 'postgis%';
```

---

## ⚙️ Step 4: Deploy Backend

### Initialize Backend App

1. Navigate to backend directory:

```bash
cd backend
```

2. Initialize Fly.io app:

```bash
flyctl launch --name ipmas-backend --region ord --no-deploy
```

**Options:**
- `--name`: App name (must be unique, e.g., `ipmas-backend-yourname`)
- `--region`: Same region as your database
- `--no-deploy`: Don't deploy yet, just create config

3. This creates `fly.toml` in the backend directory.

### Configure Backend (fly.toml)

Edit `backend/fly.toml`:

```toml
app = "ipmas-backend-yourname"
primary_region = "ord"

[build]
  dockerfile = "Dockerfile"

[env]
  NODE_ENV = "production"
  PORT = "8080"

[[services]]
  internal_port = 8080
  protocol = "tcp"
  processes = ["app"]

  [[services.ports]]
    port = 80
    handlers = ["http"]
    force_https = true

  [[services.ports]]
    port = 443
    handlers = ["tls", "http"]

  [services.concurrency]
    type = "connections"
    hard_limit = 25
    soft_limit = 20

  [[services.http_checks]]
    interval = "10s"
    timeout = "2s"
    grace_period = "5s"
    method = "GET"
    path = "/health"

[processes]
  app = "npm start"
```

**Note**: Fly.io uses port 8080 by default. Update your backend to use `process.env.PORT || 8080`.

### Attach Database to Backend

```bash
flyctl postgres attach ipmas-db -a ipmas-backend
```

This automatically sets `DATABASE_URL` environment variable.

### Set Environment Variables

```bash
# Set JWT secret
flyctl secrets set JWT_SECRET="your-generated-secret-here" -a ipmas-backend

# Set CORS origin (update after deploying frontend)
flyctl secrets set CORS_ORIGIN="https://ipmas-frontend-yourname.fly.dev" -a ipmas-backend

# Set other variables
flyctl secrets set NODE_ENV="production" -a ipmas-backend
flyctl secrets set PORT="8080" -a ipmas-backend
```

Or set multiple at once:

```bash
flyctl secrets set \
  JWT_SECRET="your-secret" \
  CORS_ORIGIN="https://ipmas-frontend-yourname.fly.dev" \
  NODE_ENV="production" \
  -a ipmas-backend
```

### Update Backend to Use PORT Environment Variable

Ensure your `backend/src/app.js` uses:

```javascript
const PORT = process.env.PORT || 3001;
```

Fly.io will set `PORT=8080`, so this should work.

### Deploy Backend

```bash
flyctl deploy -a ipmas-backend
```

Wait for deployment to complete (2-3 minutes).

### Get Backend URL

```bash
flyctl status -a ipmas-backend
```

Your backend will be at: `https://ipmas-backend-yourname.fly.dev`

---

## 🎨 Step 5: Deploy Frontend

### Initialize Frontend App

1. Navigate to frontend directory:

```bash
cd ../frontend
```

2. Initialize Fly.io app:

```bash
flyctl launch --name ipmas-frontend --region ord --no-deploy
```

### Configure Frontend (fly.toml)

Edit `frontend/fly.toml`:

```toml
app = "ipmas-frontend-yourname"
primary_region = "ord"

[build]
  dockerfile = "Dockerfile"

[env]
  PORT = "8080"
  API_URL = "https://ipmas-backend-yourname.fly.dev"

[[services]]
  internal_port = 8080
  protocol = "tcp"
  processes = ["app"]

  [[services.ports]]
    port = 80
    handlers = ["http"]
    force_https = true

  [[services.ports]]
    port = 443
    handlers = ["tls", "http"]

  [[services.http_checks]]
    interval = "10s"
    timeout = "2s"
    grace_period = "5s"
    method = "GET"
    path = "/"
```

### Update Frontend Config

Before deploying, update `frontend/public/scripts/config.js`:

```javascript
const API_CONFIG = {
    BASE_URL: 'https://ipmas-backend-yourname.fly.dev',  // Your backend URL
    SOCKET_URL: 'https://ipmas-backend-yourname.fly.dev', // Same as above
    // ... rest stays the same
};
```

Commit and push:

```bash
git add frontend/public/scripts/config.js
git commit -m "Update API config for Fly.io production"
git push
```

### Update Frontend Dockerfile (if needed)

Ensure `frontend/Dockerfile` uses `PORT`:

```dockerfile
# Frontend Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY public/ ./public/

EXPOSE 8080

# Use PORT from environment
CMD ["sh", "-c", "PORT=${PORT:-8080} npm start"]
```

Or update `frontend/package.json` start script to use PORT.

### Deploy Frontend

```bash
flyctl deploy -a ipmas-frontend
```

### Get Frontend URL

```bash
flyctl status -a ipmas-frontend
```

Your frontend will be at: `https://ipmas-frontend-yourname.fly.dev`

---

## 🔗 Step 6: Update CORS in Backend

After you have the frontend URL:

```bash
flyctl secrets set CORS_ORIGIN="https://ipmas-frontend-yourname.fly.dev" -a ipmas-backend
```

Fly.io will automatically redeploy the backend.

---

## ✅ Step 7: Verify Deployment

### Test Backend

1. Visit: `https://ipmas-backend-yourname.fly.dev`
2. Should see API info JSON
3. Visit: `https://ipmas-backend-yourname.fly.dev/health`
4. Should see health check response

### Test Frontend

1. Visit: `https://ipmas-frontend-yourname.fly.dev`
2. Open browser console (F12)
3. Check for errors
4. Test map functionality
5. Check Network tab for API calls

### View Logs

```bash
# Backend logs
flyctl logs -a ipmas-backend

# Frontend logs
flyctl logs -a ipmas-frontend
```

---

## 🗃️ Step 8: Seed Database (Optional)

```bash
flyctl ssh console -a ipmas-backend
```

Then:

```bash
cd /app
node src/scripts/seed-locations.js
```

---

## 🔴 Step 9: Add Redis (Optional)

Fly.io doesn't have managed Redis, but you can:

1. **Use Fly.io Redis** (community-maintained):

```bash
flyctl apps create ipmas-redis
flyctl image import redis:7-alpine -a ipmas-redis
```

2. **Or use Upstash Redis** (free tier available):
   - Sign up at [upstash.com](https://upstash.com)
   - Create Redis database
   - Get connection URL
   - Set in backend secrets:

```bash
flyctl secrets set REDIS_URL="your-upstash-redis-url" -a ipmas-backend
```

---

## 🐛 Troubleshooting

### Backend Issues

**Deployment fails:**
- Check logs: `flyctl logs -a ipmas-backend`
- Verify Dockerfile is correct
- Check environment variables are set
- Ensure PORT is configured correctly

**Database connection fails:**
- Verify database is attached: `flyctl postgres list`
- Check DATABASE_URL is set: `flyctl secrets list -a ipmas-backend`
- Verify PostGIS extension is installed
- Test connection: `flyctl postgres connect -a ipmas-db`

**Port issues:**
- Fly.io uses port 8080 by default
- Ensure your app uses `process.env.PORT || 8080`
- Check `fly.toml` internal_port matches

### Frontend Issues

**Can't connect to backend:**
- Verify `BASE_URL` in `config.js` matches backend URL
- Check CORS_ORIGIN in backend secrets
- Check browser console for CORS errors

**Static files not loading:**
- Verify `public` directory is copied in Dockerfile
- Check build process
- Review frontend logs

### Database Issues

**PostGIS not working:**
- Verify extension installed: `flyctl postgres connect -a ipmas-db` then `\dx`
- Re-enable if needed: `CREATE EXTENSION postgis;`

**Connection string issues:**
- Use `flyctl postgres attach` to automatically set DATABASE_URL
- Or manually set: `flyctl secrets set DATABASE_URL="..." -a ipmas-backend`

---

## 💰 Cost Estimate

### Free Tier:
- **3 shared-cpu VMs** (backend + frontend + database)
- **3GB persistent volumes** (database storage)
- **160GB outbound data transfer**
- **No spin-downs** - services stay running

### After Free Tier:
- **Backend**: ~$1.94/month (shared-cpu-1x)
- **Frontend**: ~$1.94/month (shared-cpu-1x)
- **PostgreSQL**: ~$1.94/month (shared-cpu-1x) + storage
- **Total: ~$6-10/month**

---

## 📝 Useful Fly.io Commands

```bash
# View app status
flyctl status -a ipmas-backend

# View logs
flyctl logs -a ipmas-backend

# SSH into app
flyctl ssh console -a ipmas-backend

# Scale app
flyctl scale count 1 -a ipmas-backend

# View secrets
flyctl secrets list -a ipmas-backend

# Set secret
flyctl secrets set KEY=value -a ipmas-backend

# Remove secret
flyctl secrets unset KEY -a ipmas-backend

# View database info
flyctl postgres list
flyctl postgres connect -a ipmas-db

# Restart app
flyctl apps restart ipmas-backend
```

---

## 🎉 Success!

Your IPMAS should now be live on Fly.io!

- Backend: `https://ipmas-backend-yourname.fly.dev`
- Frontend: `https://ipmas-frontend-yourname.fly.dev`
- Database: Managed PostgreSQL with PostGIS

---

## 📚 Additional Resources

- [Fly.io Documentation](https://fly.io/docs)
- [Fly.io PostgreSQL Guide](https://fly.io/docs/postgres/)
- [Fly.io CLI Reference](https://fly.io/docs/flyctl/)

---

**Last Updated**: January 2025

