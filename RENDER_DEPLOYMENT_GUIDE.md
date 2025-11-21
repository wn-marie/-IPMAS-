# 🚀 Render Deployment Guide - IPMAS

Complete step-by-step guide for deploying IPMAS to Render (free tier friendly).

---

## 📋 Prerequisites

- GitHub account (repository: https://github.com/wn-marie/-IPMAS-.git)
- Render account (free at [render.com](https://render.com))
- ~20 minutes for setup

---

## 🎯 Why Render?

- ✅ **Free PostgreSQL** database (90 days, then $7/month)
- ✅ **Free static site hosting** for frontend
- ✅ **Free tier** for backend (spins down after 15 min inactivity)
- ✅ **Automatic HTTPS** and SSL
- ✅ **Easy GitHub integration**

---

## 📝 Step 1: Sign Up for Render

1. Go to [render.com](https://render.com)
2. Click **"Get Started for Free"**
3. Sign up with GitHub (recommended)
4. Authorize Render to access your repositories

---

## 🗄️ Step 2: Create PostgreSQL Database

**Important**: Create the database FIRST so you can reference it when setting up the backend.

1. In Render dashboard, click **"New +"**
2. Select **"PostgreSQL"**
3. Configure:
   - **Name**: `ipmas-db` (or any name you prefer)
   - **Database**: `ipmas_db` (or leave default)
   - **User**: `ipmas_user` (or leave default)
   - **Region**: Choose closest to you
   - **PostgreSQL Version**: `15` (recommended)
   - **Plan**: **Free** (for demo) or **Starter** ($7/month)
4. Click **"Create Database"**
5. **Wait for database to be ready** (takes 1-2 minutes)
6. **Save the connection details** - you'll need:
   - Internal Database URL
   - External Database URL
   - Host, Port, Database, User, Password

### Enable PostGIS Extension

**Note**: Render's PostgreSQL doesn't include PostGIS by default. You have two options:

#### Option A: Use PostGIS Docker Image (Recommended)

1. Go to your PostgreSQL service
2. Click **"Settings"** tab
3. Scroll to **"Change Plan"**
4. Unfortunately, Render doesn't allow custom images on managed PostgreSQL

#### Option B: Enable PostGIS via Connection (Recommended)

1. Go to your PostgreSQL service
2. Click **"Connect"** → **"psql"** (opens web-based psql)
3. Or use external connection string
4. Run:

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
```

5. Verify:
```sql
SELECT * FROM pg_extension WHERE extname LIKE 'postgis%';
```

**Alternative**: Use a PostGIS-enabled database service like [Neon](https://neon.tech) or [Supabase](https://supabase.com) which have PostGIS built-in, then connect from Render backend.

---

## ⚙️ Step 3: Deploy Backend

1. In Render dashboard, click **"New +"**
2. Select **"Web Service"**
3. Connect your GitHub account if not already connected
4. Select repository: **`wn-marie/-IPMAS-`**
5. Click **"Connect"**

### Configure Backend Service

Fill in the configuration:

- **Name**: `ipmas-backend` (or any name)
- **Region**: Choose closest to you
- **Branch**: `main` (or your default branch)
- **Root Directory**: `backend`
- **Runtime**: `Node`
- **Build Command**: `npm install`
- **Start Command**: `npm start`
- **Plan**: **Free** (spins down after inactivity) or **Starter** ($7/month)

### Set Environment Variables

Click **"Advanced"** → **"Add Environment Variable"** and add:

```env
NODE_ENV=production
PORT=10000
DB_HOST=<your-db-host>
DB_PORT=5432
DB_NAME=<your-db-name>
DB_USER=<your-db-user>
DB_PASSWORD=<your-db-password>
# OR use DATABASE_URL (easier):
DATABASE_URL=<your-external-database-url>
REDIS_URL=<optional-redis-url-if-you-add-redis>
JWT_SECRET=<generate-a-secure-secret>
CORS_ORIGIN=https://your-frontend.onrender.com
MAPBOX_API_KEY=<your-mapbox-key-if-available>
```

**Important Notes:**
- Use the **External Database URL** from your PostgreSQL service
- Or set individual DB_* variables using the connection details
- `PORT` should be `10000` (Render's default) or use `$PORT` environment variable
- Generate JWT secret: `node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"`

### Get Backend URL

1. After deployment starts, Render will provide a URL
2. It will be: `https://ipmas-backend.onrender.com` (or your custom name)
3. **Save this URL** - you'll need it for the frontend

---

## 🎨 Step 4: Deploy Frontend

1. In Render dashboard, click **"New +"**
2. Select **"Static Site"**
3. Connect GitHub if needed
4. Select repository: **`wn-marie/-IPMAS-`**

### Configure Frontend Service

- **Name**: `ipmas-frontend`
- **Branch**: `main`
- **Root Directory**: `frontend/public`
- **Build Command**: (leave empty or `npm install` if you need to build)
- **Publish Directory**: `frontend/public`

**Note**: Since your frontend uses `http-server`, we need a different approach. See below.

### Alternative: Deploy Frontend as Web Service

Since your frontend uses `http-server` (not a static site), deploy it as a Web Service:

1. Click **"New +"** → **"Web Service"**
2. Select repository: **`wn-marie/-IPMAS-`**
3. Configure:
   - **Name**: `ipmas-frontend`
   - **Root Directory**: `frontend`
   - **Runtime**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Port**: `3000` (or leave blank, Render will set `$PORT`)

### Update Frontend Configuration

Before deploying, update `frontend/public/scripts/config.js`:

```javascript
const API_CONFIG = {
    BASE_URL: 'https://ipmas-backend.onrender.com',  // Your backend URL
    SOCKET_URL: 'https://ipmas-backend.onrender.com', // Same as above
    // ... rest stays the same
};
```

Commit and push:
```bash
git add frontend/public/scripts/config.js
git commit -m "Update API config for Render production"
git push
```

### Set Environment Variables (if needed)

For frontend Web Service, you might want:
```env
API_URL=https://ipmas-backend.onrender.com
PORT=3000
```

### Get Frontend URL

- Render will provide: `https://ipmas-frontend.onrender.com`
- **Save this URL**

---

## 🔗 Step 5: Update CORS in Backend

1. Go to backend service → **Environment** tab
2. Update `CORS_ORIGIN`:
```env
CORS_ORIGIN=https://ipmas-frontend.onrender.com
```
3. Render will automatically redeploy

---

## ✅ Step 6: Verify Deployment

### Test Backend

1. Visit: `https://your-backend.onrender.com`
2. Should see API info JSON
3. Visit: `https://your-backend.onrender.com/health`
4. Should see health check response

### Test Frontend

1. Visit: `https://your-frontend.onrender.com`
2. Open browser console (F12)
3. Check for errors
4. Test map functionality
5. Check Network tab for API calls

---

## 🗃️ Step 7: Seed Database (Optional)

1. Go to backend service → **Shell** tab
2. Run:
```bash
cd backend
node src/scripts/seed-locations.js
```

---

## 🔴 Step 8: Add Redis (Optional)

If you want Redis caching:

1. Click **"New +"** → **"Redis"**
2. Configure:
   - **Name**: `ipmas-redis`
   - **Plan**: **Free** (25MB) or **Starter** ($10/month)
3. Get connection URL
4. Update backend environment variable:
```env
REDIS_URL=<your-redis-url>
```

---

## 🐛 Troubleshooting

### Backend Issues

**Backend not starting:**
- Check **Logs** tab in Render
- Verify PORT is set correctly (Render uses `$PORT` or `10000`)
- Check all environment variables are set
- Verify database connection string

**Database connection fails:**
- Use **External Database URL** (not internal) for Render services
- Verify PostGIS extension is installed
- Check database credentials
- Ensure database is running (free tier might spin down)

**Port issues:**
- Render sets `$PORT` automatically
- Your app should use `process.env.PORT || 3001`
- Check your `backend/src/app.js` uses `process.env.PORT`

### Frontend Issues

**Frontend can't connect to backend:**
- Verify `BASE_URL` in `config.js` matches backend URL
- Check CORS_ORIGIN in backend env vars
- Check browser console for CORS errors

**Static site not working:**
- If using Static Site, ensure files are in `frontend/public`
- If using Web Service, ensure `npm start` works locally

### PostGIS Issues

**PostGIS not available:**
- Render's managed PostgreSQL doesn't include PostGIS by default
- Options:
  1. Enable manually via psql (see Step 2)
  2. Use external PostGIS database (Neon, Supabase)
  3. Use Docker with custom PostGIS image (requires paid plan)

---

## 💰 Cost Estimate

### Free Tier:
- **Backend**: Free (spins down after 15 min inactivity)
- **Frontend**: Free (static site) or Free (web service, spins down)
- **PostgreSQL**: Free for 90 days, then $7/month
- **Redis**: Free (25MB) or $10/month

### After Free Tier:
- Backend: $7/month (Starter plan)
- Frontend: $7/month (if web service) or Free (static)
- PostgreSQL: $7/month
- **Total: ~$14-21/month**

---

## ⚡ Free Tier Limitations

- **Spinning down**: Services spin down after 15 minutes of inactivity
- **Cold starts**: First request after spin-down takes 30-60 seconds
- **Database**: Free for 90 days, then requires paid plan
- **Build time**: Limited build minutes on free tier

**For demos**: This is usually fine. For production, consider upgrading.

---

## 📝 Next Steps

1. Set up custom domain (optional, requires paid plan)
2. Configure auto-deploy from GitHub
3. Set up monitoring
4. Configure database backups
5. Add error tracking (Sentry, etc.)

---

## 🎉 Success!

Your IPMAS should now be live on Render! 

- Backend: `https://your-backend.onrender.com`
- Frontend: `https://your-frontend.onrender.com`

---

**Need help?** Check Render's logs or refer to [Render Documentation](https://render.com/docs)

