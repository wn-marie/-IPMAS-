# ✅ Fly.io Deployment Checklist

Use this checklist as you deploy IPMAS to Fly.io.

---

## 📋 Pre-Deployment

- [ ] Fly.io account created at [fly.io](https://fly.io)
- [ ] Fly CLI installed (`flyctl`)
- [ ] Logged in via CLI: `flyctl auth login`
- [ ] JWT secret generated

### Generate JWT Secret

```bash
# Windows PowerShell
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

Save the output - you'll need it for backend secrets.

---

## 🛠️ Step 1: Install and Setup Fly CLI

- [ ] Fly CLI installed
- [ ] Verified: `flyctl version`
- [ ] Logged in: `flyctl auth login`
- [ ] Authentication successful

---

## 🗄️ Step 2: Create PostgreSQL Database

- [ ] Created database:
```bash
flyctl postgres create --name ipmas-db --region ord --vm-size shared-cpu-1x --volume-size 3
```
- [ ] Database created successfully
- [ ] Saved database name and region

### Enable PostGIS Extension

- [ ] Connected to database: `flyctl postgres connect -a ipmas-db`
- [ ] Ran PostGIS commands:
```sql
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
```
- [ ] Verified extensions: `SELECT * FROM pg_extension WHERE extname LIKE 'postgis%';`

---

## ⚙️ Step 3: Deploy Backend

### Initialize Backend App

- [ ] Navigated to `backend/` directory
- [ ] Initialized app: `flyctl launch --name ipmas-backend --region ord --no-deploy`
- [ ] `fly.toml` created in backend directory

### Configure Backend

- [ ] Edited `backend/fly.toml`:
  - [ ] Set app name
  - [ ] Set primary_region
  - [ ] Configured build with Dockerfile
  - [ ] Set PORT=8080
  - [ ] Configured services and health checks

### Attach Database

- [ ] Attached database: `flyctl postgres attach ipmas-db -a ipmas-backend`
- [ ] DATABASE_URL automatically set

### Set Environment Variables

- [ ] Set JWT_SECRET: `flyctl secrets set JWT_SECRET="..." -a ipmas-backend`
- [ ] Set NODE_ENV: `flyctl secrets set NODE_ENV="production" -a ipmas-backend`
- [ ] Set PORT: `flyctl secrets set PORT="8080" -a ipmas-backend`
- [ ] Set CORS_ORIGIN (will update after frontend deployment)

### Verify Backend Code

- [ ] Backend uses `process.env.PORT || 3001` (or 8080)
- [ ] Health check endpoint exists at `/health`

### Deploy Backend

- [ ] Deployed: `flyctl deploy -a ipmas-backend`
- [ ] Deployment successful
- [ ] Got backend URL: `https://ipmas-backend-yourname.fly.dev`
- [ ] Saved backend URL

---

## 🎨 Step 4: Deploy Frontend

### Initialize Frontend App

- [ ] Navigated to `frontend/` directory
- [ ] Initialized app: `flyctl launch --name ipmas-frontend --region ord --no-deploy`
- [ ] `fly.toml` created in frontend directory

### Configure Frontend

- [ ] Edited `frontend/fly.toml`:
  - [ ] Set app name
  - [ ] Set primary_region
  - [ ] Configured build with Dockerfile
  - [ ] Set PORT=8080
  - [ ] Configured services

### Update Frontend Config

- [ ] Updated `frontend/public/scripts/config.js`:
  - [ ] Set BASE_URL to backend URL
  - [ ] Set SOCKET_URL to backend URL
- [ ] Committed and pushed changes:
```bash
git add frontend/public/scripts/config.js
git commit -m "Update API config for Fly.io"
git push
```

### Update Frontend Dockerfile (if needed)

- [ ] Verified Dockerfile uses PORT environment variable
- [ ] Or updated package.json start script

### Deploy Frontend

- [ ] Deployed: `flyctl deploy -a ipmas-frontend`
- [ ] Deployment successful
- [ ] Got frontend URL: `https://ipmas-frontend-yourname.fly.dev`
- [ ] Saved frontend URL

---

## 🔗 Step 5: Update CORS

- [ ] Updated CORS_ORIGIN in backend:
```bash
flyctl secrets set CORS_ORIGIN="https://ipmas-frontend-yourname.fly.dev" -a ipmas-backend
```
- [ ] Backend automatically redeployed

---

## ✅ Step 6: Verify Deployment

### Test Backend

- [ ] Visit: `https://ipmas-backend-yourname.fly.dev`
- [ ] See API info JSON
- [ ] Visit: `https://ipmas-backend-yourname.fly.dev/health`
- [ ] Health check returns 200 OK
- [ ] Check logs: `flyctl logs -a ipmas-backend`
- [ ] See "✅ IPMAS API is ready!" in logs

### Test Frontend

- [ ] Visit: `https://ipmas-frontend-yourname.fly.dev`
- [ ] Open browser console (F12)
- [ ] No errors in console
- [ ] Map loads correctly
- [ ] Test clicking locations
- [ ] Check Network tab - API calls succeed
- [ ] Socket.IO connection working

### Test Database

- [ ] Connected to database: `flyctl postgres connect -a ipmas-db`
- [ ] Verified PostGIS: `SELECT * FROM pg_extension WHERE extname LIKE 'postgis%';`
- [ ] Tested connection from backend

---

## 🗃️ Step 7: Seed Database (Optional)

- [ ] Connected to backend: `flyctl ssh console -a ipmas-backend`
- [ ] Ran seed script: `node src/scripts/seed-locations.js`
- [ ] Verified data inserted

---

## 🔴 Step 8: Add Redis (Optional)

- [ ] Created Redis service (Upstash or Fly.io)
- [ ] Got Redis connection URL
- [ ] Set REDIS_URL in backend secrets:
```bash
flyctl secrets set REDIS_URL="..." -a ipmas-backend
```

---

## 🐛 Troubleshooting

### Backend Issues

**Deployment fails:**
- [ ] Check logs: `flyctl logs -a ipmas-backend`
- [ ] Verify Dockerfile syntax
- [ ] Check environment variables
- [ ] Verify PORT configuration

**Database connection fails:**
- [ ] Verify database attached: `flyctl postgres list`
- [ ] Check DATABASE_URL: `flyctl secrets list -a ipmas-backend`
- [ ] Test connection: `flyctl postgres connect -a ipmas-db`
- [ ] Verify PostGIS extension

**Port issues:**
- [ ] Ensure app uses `process.env.PORT || 8080`
- [ ] Check `fly.toml` internal_port=8080
- [ ] Verify services configuration

### Frontend Issues

**Can't connect to backend:**
- [ ] Verify BASE_URL in config.js matches backend URL
- [ ] Check CORS_ORIGIN in backend secrets
- [ ] Check browser console for errors
- [ ] Verify backend is accessible

**Static files not loading:**
- [ ] Verify public directory in Dockerfile
- [ ] Check build process
- [ ] Review frontend logs

### Database Issues

**PostGIS not working:**
- [ ] Verify extension: `\dx` in psql
- [ ] Re-enable if needed: `CREATE EXTENSION postgis;`
- [ ] Check database logs

**Connection issues:**
- [ ] Use `flyctl postgres attach` to set DATABASE_URL
- [ ] Or manually set DATABASE_URL secret
- [ ] Verify connection string format

---

## 💰 Cost Monitoring

- [ ] Check Fly.io dashboard for usage
- [ ] Free tier: 3 VMs, 3GB storage, 160GB transfer
- [ ] Monitor usage to avoid unexpected charges
- [ ] Set up billing alerts (optional)

---

## 📝 Useful Commands Reference

```bash
# Status and logs
flyctl status -a ipmas-backend
flyctl logs -a ipmas-backend

# Secrets management
flyctl secrets list -a ipmas-backend
flyctl secrets set KEY=value -a ipmas-backend

# Database
flyctl postgres list
flyctl postgres connect -a ipmas-db

# SSH and console
flyctl ssh console -a ipmas-backend

# Restart
flyctl apps restart ipmas-backend
```

---

## 🎉 Success Criteria

Your deployment is successful when:

- [ ] Backend accessible: `https://ipmas-backend-yourname.fly.dev`
- [ ] Health check works: `/health` returns 200
- [ ] Frontend accessible: `https://ipmas-frontend-yourname.fly.dev`
- [ ] Map loads and displays correctly
- [ ] API calls succeed (check Network tab)
- [ ] No errors in browser console
- [ ] Database connection working
- [ ] PostGIS extension enabled

---

## 📚 Additional Resources

- [Fly.io Documentation](https://fly.io/docs)
- [Fly.io PostgreSQL Guide](https://fly.io/docs/postgres/)
- [Fly.io CLI Reference](https://fly.io/docs/flyctl/)
- Full guide: `FLYIO_DEPLOYMENT_GUIDE.md`

---

**Need help?** Check Fly.io logs or refer to the troubleshooting section above.

