# ✅ Render Deployment Checklist

Use this checklist as you deploy IPMAS to Render.

---

## 📋 Pre-Deployment

- [ ] Render account created at [render.com](https://render.com)
- [ ] GitHub account connected to Render
- [ ] JWT secret generated

### Generate JWT Secret

```bash
# Windows PowerShell
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

Save the output - you'll need it for backend environment variables.

---

## 🗄️ Step 1: Create PostgreSQL Database

- [ ] Click **"New +"** → **"PostgreSQL"**
- [ ] Name: `ipmas-db`
- [ ] Region: Selected
- [ ] Plan: **Free** (or Starter $7/month)
- [ ] Click **"Create Database"**
- [ ] Wait for database to be ready (1-2 minutes)
- [ ] **Save connection details**:
  - [ ] Internal Database URL
  - [ ] External Database URL
  - [ ] Host, Port, Database, User, Password

### Enable PostGIS Extension

- [ ] Go to PostgreSQL service → **"Connect"** → **"psql"**
- [ ] Run:
```sql
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
```
- [ ] Verify:
```sql
SELECT * FROM pg_extension WHERE extname LIKE 'postgis%';
```

---

## ⚙️ Step 2: Deploy Backend

- [ ] Click **"New +"** → **"Web Service"**
- [ ] Connect GitHub repository: `wn-marie/-IPMAS-`
- [ ] Configure:
  - [ ] Name: `ipmas-backend`
  - [ ] Region: Selected
  - [ ] Branch: `main`
  - [ ] Root Directory: `backend`
  - [ ] Runtime: `Node`
  - [ ] Build Command: `npm install`
  - [ ] Start Command: `npm start`
  - [ ] Plan: **Free** (or Starter)

### Set Environment Variables

- [ ] Go to **"Environment"** tab
- [ ] Add variables:

```env
NODE_ENV=production
PORT=10000
DATABASE_URL=<your-external-database-url>
# OR individual variables:
# DB_HOST=<host>
# DB_PORT=5432
# DB_NAME=<name>
# DB_USER=<user>
# DB_PASSWORD=<password>
JWT_SECRET=<your-generated-secret>
CORS_ORIGIN=https://your-frontend.onrender.com
MAPBOX_API_KEY=<optional>
```

- [ ] **Save** environment variables
- [ ] Render will start deploying

### Get Backend URL

- [ ] Wait for deployment to complete
- [ ] Copy backend URL: `https://ipmas-backend.onrender.com`
- [ ] Save this URL

---

## 🎨 Step 3: Deploy Frontend

### Option A: Web Service (Recommended for http-server)

- [ ] Click **"New +"** → **"Web Service"**
- [ ] Select repository: `wn-marie/-IPMAS-`
- [ ] Configure:
  - [ ] Name: `ipmas-frontend`
  - [ ] Root Directory: `frontend`
  - [ ] Runtime: `Node`
  - [ ] Build Command: `npm install`
  - [ ] Start Command: `npm start`
  - [ ] Port: `3000` (or leave blank for `$PORT`)

### Option B: Static Site (If you build static files)

- [ ] Click **"New +"** → **"Static Site"**
- [ ] Select repository: `wn-marie/-IPMAS-`
- [ ] Configure:
  - [ ] Root Directory: `frontend/public`
  - [ ] Build Command: (empty or `npm install`)
  - [ ] Publish Directory: `frontend/public`

### Update Frontend Config

- [ ] Update `frontend/public/scripts/config.js`:

```javascript
const API_CONFIG = {
    BASE_URL: 'https://ipmas-backend.onrender.com',  // Your backend URL
    SOCKET_URL: 'https://ipmas-backend.onrender.com',
    // ... rest stays the same
};
```

- [ ] Commit and push:
```bash
git add frontend/public/scripts/config.js
git commit -m "Update API config for Render"
git push
```

- [ ] Wait for Render to redeploy

### Get Frontend URL

- [ ] Copy frontend URL: `https://ipmas-frontend.onrender.com`
- [ ] Save this URL

---

## 🔗 Step 4: Update CORS

- [ ] Go to backend service → **"Environment"** tab
- [ ] Update `CORS_ORIGIN`:
```env
CORS_ORIGIN=https://ipmas-frontend.onrender.com
```
- [ ] Render will auto-redeploy

---

## ✅ Step 5: Verify Deployment

### Test Backend

- [ ] Visit: `https://your-backend.onrender.com`
- [ ] Should see API info JSON
- [ ] Visit: `https://your-backend.onrender.com/health`
- [ ] Should see health check (200 OK)
- [ ] Check **Logs** tab - should show "✅ IPMAS API is ready!"

### Test Frontend

- [ ] Visit: `https://your-frontend.onrender.com`
- [ ] Open browser console (F12)
- [ ] Check for errors
- [ ] Verify map loads
- [ ] Test clicking locations
- [ ] Check Network tab - API calls should succeed

### Test Database

- [ ] Go to backend service → **"Shell"** tab
- [ ] Run:
```bash
cd backend
node -e "require('./src/config/postgis').testConnection().then(() => console.log('✅ DB Connected')).catch(e => console.error('❌ Error:', e))"
```

---

## 🗃️ Step 6: Seed Database (Optional)

- [ ] Go to backend service → **"Shell"** tab
- [ ] Run:
```bash
cd backend
node src/scripts/seed-locations.js
```
- [ ] Verify data inserted (check logs)

---

## 🔴 Step 7: Add Redis (Optional)

- [ ] Click **"New +"** → **"Redis"**
- [ ] Name: `ipmas-redis`
- [ ] Plan: **Free** (25MB) or **Starter** ($10/month)
- [ ] Get Redis URL
- [ ] Update backend environment:
```env
REDIS_URL=<your-redis-url>
```

---

## 🐛 Troubleshooting

### Backend Issues

**Service won't start:**
- [ ] Check **Logs** tab for errors
- [ ] Verify PORT uses `process.env.PORT || 3001` in code
- [ ] Check all environment variables are set
- [ ] Verify database connection string

**Database connection fails:**
- [ ] Use **External Database URL** (not internal)
- [ ] Verify PostGIS extension installed
- [ ] Check database is running (free tier might spin down)
- [ ] Test connection via Render's psql console

**Port errors:**
- [ ] Ensure code uses `process.env.PORT` (Render sets this automatically)
- [ ] Check `backend/src/app.js` uses `process.env.PORT || 3001`

### Frontend Issues

**Can't connect to backend:**
- [ ] Verify `BASE_URL` in `config.js` matches backend URL exactly
- [ ] Check CORS_ORIGIN in backend env vars
- [ ] Check browser console for CORS errors
- [ ] Verify backend is accessible

**Static site not working:**
- [ ] Ensure files are in `frontend/public`
- [ ] Check build/publish directory settings
- [ ] Consider using Web Service instead

### PostGIS Issues

**PostGIS not working:**
- [ ] Verify extension installed (Step 1)
- [ ] Check connection has proper permissions
- [ ] Consider using external PostGIS database (Neon, Supabase)

### Free Tier Issues

**Service spins down:**
- [ ] This is normal for free tier (15 min inactivity)
- [ ] First request after spin-down takes 30-60 seconds
- [ ] Consider upgrading to Starter plan ($7/month) to avoid spin-downs

---

## 💰 Cost Monitoring

- [ ] Check Render dashboard for usage
- [ ] Free tier: 750 hours/month
- [ ] PostgreSQL: Free for 90 days, then $7/month
- [ ] Monitor to avoid unexpected charges

---

## 📝 Important Notes

### Free Tier Limitations:
- ⚠️ Services spin down after 15 minutes of inactivity
- ⚠️ Cold starts take 30-60 seconds
- ⚠️ PostgreSQL free for 90 days only
- ⚠️ Limited build minutes

### For Production:
- Consider upgrading to Starter plans
- Set up custom domain
- Configure database backups
- Add monitoring

---

## 🎉 Success Criteria

Your deployment is successful when:

- [ ] Backend accessible: `https://your-backend.onrender.com`
- [ ] Health check works: `/health` returns 200
- [ ] Frontend accessible: `https://your-frontend.onrender.com`
- [ ] Map loads and displays correctly
- [ ] API calls succeed (check Network tab)
- [ ] No errors in browser console
- [ ] Database connection working

---

## 📚 Additional Resources

- [Render Documentation](https://render.com/docs)
- [Render Community](https://community.render.com)
- Full guide: `RENDER_DEPLOYMENT_GUIDE.md`

---

**Need help?** Check Render's logs tab or refer to the troubleshooting section above.

