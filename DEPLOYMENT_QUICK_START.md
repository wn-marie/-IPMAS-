# 🚀 Quick Deployment Guide - Railway (Recommended)

This is the fastest way to get IPMAS live for a demo.

---

## Prerequisites

- GitHub account (repository already at: https://github.com/wn-marie/-IPMAS-.git)
- Railway account (free at [railway.app](https://railway.app))

---

## Step 1: Deploy Backend (5 minutes)

1. Go to [railway.app](https://railway.app) and sign up/login
2. Click **"New Project"**
3. Select **"Deploy from GitHub repo"**
4. Authorize Railway to access your GitHub
5. Select repository: **`wn-marie/-IPMAS-`**
6. Railway will detect it's a Node.js project

### Configure Backend Service:

1. Click on the service that was created
2. Go to **Settings** tab
3. Set:
   - **Root Directory**: `backend`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`

### Add PostgreSQL Database:

1. In your project, click **"+ New"**
2. Select **"Database"** → **"Add PostgreSQL"**
3. Railway will create a PostgreSQL database
4. Note the connection details (you'll need them)

### Add Redis (Optional but Recommended):

1. Click **"+ New"**
2. Select **"Database"** → **"Add Redis"**

### Set Environment Variables:

1. Go to backend service → **Variables** tab
2. Add these variables:

```env
NODE_ENV=production
PORT=3001
DB_HOST=${{Postgres.PGHOST}}
DB_PORT=${{Postgres.PGPORT}}
DB_NAME=${{Postgres.PGDATABASE}}
DB_USER=${{Postgres.PGUSER}}
DB_PASSWORD=${{Postgres.PGPASSWORD}}
REDIS_HOST=${{Redis.REDIS_HOST}}
REDIS_PORT=${{Redis.REDIS_PORT}}
JWT_SECRET=generate-a-random-secret-here-min-32-chars
CORS_ORIGIN=https://your-frontend-url.railway.app
MAPBOX_API_KEY=your-mapbox-key-if-you-have-one
```

**Note**: Replace `${{Postgres.*}}` with actual values from your PostgreSQL service, or use Railway's variable references.

### Enable PostGIS:

1. Go to PostgreSQL service
2. Click **"Connect"** → **"PostgreSQL"**
3. Run this SQL:

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
```

### Get Backend URL:

1. Go to backend service → **Settings** → **Networking**
2. Click **"Generate Domain"**
3. Copy the URL (e.g., `https://ipmas-backend-production.up.railway.app`)

---

## Step 2: Deploy Frontend (5 minutes)

1. In same Railway project, click **"+ New"**
2. Select **"GitHub Repo"** → Select same repository
3. Railway will create a new service

### Configure Frontend Service:

1. Click on the new service
2. Go to **Settings** tab
3. Set:
   - **Root Directory**: `frontend`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Port**: `3000`

### Update Frontend Configuration:

1. Before deploying, update `frontend/public/scripts/config.js`:

```javascript
const API_CONFIG = {
    BASE_URL: 'https://your-backend-url.railway.app',  // Your backend URL from Step 1
    SOCKET_URL: 'https://your-backend-url.railway.app', // Same as above
    // ... rest stays the same
};
```

2. Commit and push this change:
```bash
git add frontend/public/scripts/config.js
git commit -m "Update API config for production"
git push
```

### Set Environment Variables:

1. Go to frontend service → **Variables** tab
2. Add:
```env
API_URL=https://your-backend-url.railway.app
```

### Get Frontend URL:

1. Go to frontend service → **Settings** → **Networking**
2. Click **"Generate Domain"**
3. Copy the URL (e.g., `https://ipmas-frontend-production.up.railway.app`)

---

## Step 3: Update CORS in Backend

1. Go to backend service → **Variables**
2. Update `CORS_ORIGIN` with your frontend URL:
```env
CORS_ORIGIN=https://ipmas-frontend-production.up.railway.app
```
3. Railway will automatically redeploy

---

## Step 4: Seed Database (Optional)

If you have location data to seed:

1. Go to backend service → **Connect** → **Shell**
2. Run:
```bash
cd backend
node src/scripts/seed-locations.js
```

---

## Step 5: Test Your Deployment

1. Visit your frontend URL
2. Open browser console (F12)
3. Check for any errors
4. Test the map functionality
5. Test API calls

---

## Troubleshooting

### Backend not starting:
- Check **Logs** tab in Railway
- Verify all environment variables are set
- Ensure database connection string is correct

### Frontend can't connect to backend:
- Verify `BASE_URL` in `config.js` matches backend URL
- Check CORS_ORIGIN in backend env vars
- Check browser console for errors

### Database connection fails:
- Verify PostGIS extension is installed
- Check database credentials in env vars
- Ensure database is running

### Socket.IO not working:
- Verify Socket.IO URL in frontend config
- Check Railway supports WebSockets (it does)
- Check backend logs for Socket.IO errors

---

## Cost Estimate

**Railway Free Tier:**
- $5 free credit monthly
- Usually enough for small demos

**If you exceed free tier:**
- ~$5-10/month for backend
- ~$5-10/month for frontend
- ~$5/month for PostgreSQL
- ~$2/month for Redis

**Total: ~$17-27/month** (after free tier)

---

## Next Steps

1. Set up custom domain (optional)
2. Configure database backups
3. Set up monitoring
4. Enable error tracking (Sentry, etc.)

---

**That's it! Your IPMAS demo should now be live! 🎉**

