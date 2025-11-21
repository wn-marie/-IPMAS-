# ✅ Railway Deployment Checklist

Use this checklist as you deploy IPMAS to Railway.

---

## 📋 Pre-Deployment

- [ ] Railway account created at [railway.app](https://railway.app)
- [ ] GitHub repository connected (already done: https://github.com/wn-marie/-IPMAS-.git)
- [ ] JWT secret generated (see below)

### Generate JWT Secret

Run this command to generate a secure JWT secret:

```bash
# Windows PowerShell
[Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32))

# Or use Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

Save this secret - you'll need it for the backend environment variables.

---

## 🚀 Step 1: Create Railway Project

- [ ] Go to [railway.app](https://railway.app)
- [ ] Click **"New Project"**
- [ ] Select **"Deploy from GitHub repo"**
- [ ] Authorize Railway to access GitHub
- [ ] Select repository: **`wn-marie/-IPMAS-`**
- [ ] Project created successfully

---

## 🗄️ Step 2: Add PostgreSQL Database

- [ ] In Railway project, click **"+ New"**
- [ ] Select **"Database"** → **"Add PostgreSQL"**
- [ ] Database service created
- [ ] Note: Railway will automatically provide connection variables

### Enable PostGIS Extension

- [ ] Go to PostgreSQL service
- [ ] Click **"Connect"** → **"PostgreSQL"** (opens Railway's database console)
- [ ] Run this SQL:

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
```

- [ ] Verify extensions are installed:
```sql
SELECT * FROM pg_extension WHERE extname LIKE 'postgis%';
```

---

## 🔴 Step 3: Add Redis (Optional but Recommended)

- [ ] Click **"+ New"**
- [ ] Select **"Database"** → **"Add Redis"**
- [ ] Redis service created

---

## ⚙️ Step 4: Configure Backend Service

- [ ] Click on the main service (your backend)
- [ ] Go to **Settings** tab
- [ ] Set **Root Directory**: `backend`
- [ ] Set **Build Command**: `npm install`
- [ ] Set **Start Command**: `npm start`
- [ ] Verify **Port** is set to: `3001` (or leave blank, Railway will auto-detect)

### Set Backend Environment Variables

- [ ] Go to backend service → **Variables** tab
- [ ] Add these variables (use Railway's variable references where possible):

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
JWT_SECRET=<your-generated-secret-here>
CORS_ORIGIN=https://your-frontend-url.railway.app
MAPBOX_API_KEY=<your-mapbox-key-if-available>
```

**Important Notes:**
- Replace `<your-generated-secret-here>` with the JWT secret you generated
- For `CORS_ORIGIN`, you'll update this after deploying the frontend
- Railway's `${{Service.Variable}}` syntax automatically references other services

### Generate Backend Domain

- [ ] Go to backend service → **Settings** → **Networking**
- [ ] Click **"Generate Domain"**
- [ ] Copy the backend URL (e.g., `https://ipmas-backend-production.up.railway.app`)
- [ ] Save this URL - you'll need it for the frontend

---

## 🎨 Step 5: Deploy Frontend

- [ ] In same Railway project, click **"+ New"**
- [ ] Select **"GitHub Repo"** → Select same repository (`wn-marie/-IPMAS-`)
- [ ] New service created

### Configure Frontend Service

- [ ] Click on the new frontend service
- [ ] Go to **Settings** tab
- [ ] Set **Root Directory**: `frontend`
- [ ] Set **Build Command**: `npm install`
- [ ] Set **Start Command**: `npm start`
- [ ] Set **Port**: `3000`

### Update Frontend Config

- [ ] Update `frontend/public/scripts/config.js` with your backend URL:

```javascript
// Replace 'https://your-backend-url.railway.app' with your actual backend URL
const API_CONFIG = {
    BASE_URL: 'https://ipmas-backend-production.up.railway.app',  // Your backend URL
    SOCKET_URL: 'https://ipmas-backend-production.up.railway.app', // Same as above
    // ... rest stays the same
};
```

- [ ] Commit and push the change:

```bash
git add frontend/public/scripts/config.js
git commit -m "Update API config for Railway production"
git push
```

- [ ] Wait for Railway to redeploy frontend automatically

### Generate Frontend Domain

- [ ] Go to frontend service → **Settings** → **Networking**
- [ ] Click **"Generate Domain"**
- [ ] Copy the frontend URL (e.g., `https://ipmas-frontend-production.up.railway.app`)
- [ ] Save this URL

---

## 🔗 Step 6: Update CORS in Backend

- [ ] Go back to backend service → **Variables** tab
- [ ] Update `CORS_ORIGIN` with your frontend URL:

```env
CORS_ORIGIN=https://ipmas-frontend-production.up.railway.app
```

- [ ] Railway will automatically redeploy the backend

---

## ✅ Step 7: Verify Deployment

### Test Backend

- [ ] Visit backend URL: `https://your-backend.railway.app`
- [ ] Should see API info JSON
- [ ] Visit: `https://your-backend.railway.app/health`
- [ ] Should see health check response
- [ ] Check backend logs in Railway (should show "✅ IPMAS API is ready!")

### Test Frontend

- [ ] Visit frontend URL: `https://your-frontend.railway.app`
- [ ] Open browser console (F12)
- [ ] Check for errors
- [ ] Verify map loads
- [ ] Test clicking on map locations
- [ ] Check Network tab - API calls should succeed

### Test Database Connection

- [ ] Go to backend service → **Connect** → **Shell**
- [ ] Run:

```bash
cd backend
node -e "require('./src/config/postgis').testConnection().then(() => console.log('✅ DB Connected')).catch(e => console.error('❌ DB Error:', e))"
```

---

## 🗃️ Step 8: Seed Database (Optional)

If you want to seed location data:

- [ ] Go to backend service → **Connect** → **Shell**
- [ ] Run:

```bash
cd backend
node src/scripts/seed-locations.js
```

- [ ] Verify data was inserted (check logs)

---

## 🐛 Troubleshooting

### Backend Issues

**Backend not starting:**
- [ ] Check **Logs** tab in Railway backend service
- [ ] Verify all environment variables are set correctly
- [ ] Check database connection variables match PostgreSQL service
- [ ] Ensure JWT_SECRET is set

**Database connection fails:**
- [ ] Verify PostGIS extension is installed (Step 2)
- [ ] Check database credentials in env vars
- [ ] Ensure PostgreSQL service is running
- [ ] Test connection via Railway's PostgreSQL console

**Port issues:**
- [ ] Ensure PORT=3001 is set in backend env vars
- [ ] Railway should auto-detect, but explicit is better

### Frontend Issues

**Frontend can't connect to backend:**
- [ ] Verify `BASE_URL` in `config.js` matches backend URL exactly
- [ ] Check CORS_ORIGIN in backend env vars matches frontend URL
- [ ] Check browser console for CORS errors
- [ ] Verify backend is accessible (visit backend URL directly)

**Socket.IO not working:**
- [ ] Verify Socket.IO URL in frontend config matches backend URL
- [ ] Check backend logs for Socket.IO connection errors
- [ ] Railway supports WebSockets, so this should work

**Map not loading:**
- [ ] Check browser console for Leaflet errors
- [ ] Verify internet connection (map tiles load from external CDN)
- [ ] Check if Mapbox API key is needed (if using Mapbox tiles)

---

## 📊 Monitoring

- [ ] Check Railway dashboard for service health
- [ ] Monitor usage in Railway dashboard
- [ ] Set up alerts (optional, in Railway settings)

---

## 🎉 Success Criteria

Your deployment is successful when:

- [ ] Backend accessible at `https://your-backend.railway.app`
- [ ] Health check returns 200: `https://your-backend.railway.app/health`
- [ ] Frontend accessible at `https://your-frontend.railway.app`
- [ ] Map loads and displays correctly
- [ ] Clicking locations shows data
- [ ] No errors in browser console
- [ ] API calls succeed (check Network tab)

---

## 💰 Cost Monitoring

- [ ] Check Railway usage dashboard
- [ ] Free tier: $5 credit/month
- [ ] Monitor usage to avoid unexpected charges
- [ ] Set up usage alerts (optional)

---

## 📝 Next Steps (Optional)

- [ ] Set up custom domain
- [ ] Configure database backups
- [ ] Add error tracking (Sentry, etc.)
- [ ] Set up monitoring (UptimeRobot, etc.)
- [ ] Configure CI/CD for auto-deployment

---

**Need help?** Check the logs in Railway dashboard or refer to `DEPLOYMENT_QUICK_START.md` for detailed instructions.

