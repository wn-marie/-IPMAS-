# 🚀 Vercel + Fly.io Deployment Guide

Step-by-step guide for deploying IPMAS with **Vercel (Frontend)** + **Fly.io (Backend)** for best performance.

---

## 📋 Overview

- **Frontend**: Deployed to Vercel (edge network, fast CDN)
- **Backend**: Deployed to Fly.io (generous free tier, PostgreSQL with PostGIS)
- **Result**: Best performance with free tier available

---

## 🎯 Prerequisites

- GitHub account (repository: https://github.com/wn-marie/-IPMAS-.git)
- Vercel account (free at [vercel.com](https://vercel.com))
- Fly.io account (free at [fly.io](https://fly.io))
- Fly CLI installed (see `FLYIO_WINDOWS_INSTALL.md`)

---

## 📝 Part 1: Deploy Backend to Fly.io

### Step 1.1: Install Fly CLI (if not done)

**In PowerShell**, run:

```powershell
Invoke-WebRequest https://fly.io/install.ps1 -UseBasicParsing | Invoke-Expression
```

Verify:
```powershell
flyctl version
```

### Step 1.2: Sign Up and Login to Fly.io

1. Go to [fly.io](https://fly.io) and sign up (free)
2. Login via CLI:

```powershell
flyctl auth login
```

This opens your browser to authenticate.

### Step 1.3: Create PostgreSQL Database

**In PowerShell**, run:

```powershell
flyctl postgres create --name ipmas-db --region ord --vm-size shared-cpu-1x --volume-size 3
```

**Note**: 
- `--region ord` = Chicago (change to `iad` for Virginia, `lhr` for London, etc.)
- This takes 2-3 minutes

### Step 1.4: Enable PostGIS Extension

Connect to your database:

```powershell
flyctl postgres connect -a ipmas-db
```

In the psql console, run:

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
```

Verify:

```sql
SELECT * FROM pg_extension WHERE extname LIKE 'postgis%';
```

Exit psql: Type `\q` and press Enter

### Step 1.5: Navigate to Backend Directory

```powershell
cd C:\Users\Admin\Desktop\IPMAS-\backend
```

### Step 1.6: Initialize Fly.io App for Backend

```powershell
flyctl launch --name ipmas-backend --region ord --no-deploy
```

**Note**: 
- Choose a unique name (e.g., `ipmas-backend-yourname`)
- Use the same region as your database
- This creates `fly.toml` in the backend directory

### Step 1.7: Configure Backend (fly.toml)

Edit `backend/fly.toml` - it should look like this:

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

### Step 1.8: Verify Backend Uses PORT Environment Variable

Check `backend/src/app.js` - it should have:

```javascript
const PORT = process.env.PORT || 3001;
```

This is already correct in your code! ✅

### Step 1.9: Attach Database to Backend

```powershell
flyctl postgres attach ipmas-db -a ipmas-backend
```

This automatically sets `DATABASE_URL` environment variable.

### Step 1.10: Set Backend Secrets

Generate a JWT secret first:

```powershell
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

Copy the output, then set secrets:

```powershell
# Set JWT secret (use the output from above)
flyctl secrets set JWT_SECRET="your-generated-secret-here" -a ipmas-backend

# Set other environment variables
flyctl secrets set NODE_ENV="production" -a ipmas-backend
flyctl secrets set PORT="8080" -a ipmas-backend

# CORS will be set after we get frontend URL
```

### Step 1.11: Deploy Backend

```powershell
flyctl deploy -a ipmas-backend
```

Wait for deployment (2-3 minutes).

### Step 1.12: Get Backend URL

```powershell
flyctl status -a ipmas-backend
```

Your backend URL will be: `https://ipmas-backend-yourname.fly.dev`

**Save this URL** - you'll need it for the frontend!

### Step 1.13: Test Backend

Visit in browser:
- `https://ipmas-backend-yourname.fly.dev` - Should show API info
- `https://ipmas-backend-yourname.fly.dev/health` - Should return 200 OK

---

## 📝 Part 2: Deploy Frontend to Vercel

### Step 2.1: Sign Up for Vercel

1. Go to [vercel.com](https://vercel.com)
2. Click **"Sign Up"**
3. Sign up with GitHub (recommended)
4. Authorize Vercel to access your repositories

### Step 2.2: Update Frontend Configuration

**Before deploying**, we need to set the backend URL. Your `config.js` already has auto-detection, but we'll use a meta tag for Vercel.

**Option 1: Add Meta Tag to HTML (Recommended)**

Edit `frontend/public/index.html` and add this in the `<head>` section:

```html
<head>
    <!-- ... existing head content ... -->
    <meta name="api-url" content="https://ipmas-backend-yourname.fly.dev">
</head>
```

**Important**: Replace `ipmas-backend-yourname.fly.dev` with your actual backend URL from Step 1.12!

**Option 2: Update config.js directly**

If you prefer, edit `frontend/public/scripts/config.js` and modify the `getBackendUrl()` function:

```javascript
const getBackendUrl = () => {
    // Production backend URL (Vercel + Fly.io)
    if (window.location.hostname.includes('vercel.app')) {
        return 'https://ipmas-backend-yourname.fly.dev'; // Your Fly.io backend URL
    }
    // Check if API_URL is set in window
    if (window.API_URL) {
        return window.API_URL;
    }
    // Check if set via meta tag
    const metaApiUrl = document.querySelector('meta[name="api-url"]');
    if (metaApiUrl) {
        return metaApiUrl.getAttribute('content');
    }
    // Development fallback
    return 'http://localhost:3001';
};
```

**I recommend Option 1 (meta tag)** as it's easier to update without changing code.

### Step 2.3: Commit and Push Changes

```powershell
cd C:\Users\Admin\Desktop\IPMAS-
git add frontend/public/scripts/config.js
git commit -m "Update API config for Vercel + Fly.io deployment"
git push
```

### Step 2.4: Import Project to Vercel

1. In Vercel dashboard, click **"Add New..."** → **"Project"**
2. Select your GitHub repository: `wn-marie/-IPMAS-`
3. Click **"Import"**

### Step 2.5: Configure Frontend Project

Vercel will auto-detect settings. Configure:

- **Project Name**: `ipmas-frontend` (or any name)
- **Framework Preset**: **"Other"** (since you're using vanilla JS)
- **Root Directory**: `frontend`
- **Build Command**: Leave empty (or `npm install` if needed)
- **Output Directory**: `public`
- **Install Command**: Leave empty

### Step 2.6: Set Environment Variables (Optional)

In Vercel project settings → Environment Variables:

```
NEXT_PUBLIC_API_URL=https://ipmas-backend-yourname.fly.dev
```

**Note**: Since you're using vanilla JS (not Next.js), this might not be needed, but it's good practice.

### Step 2.7: Deploy Frontend

Click **"Deploy"**

Vercel will:
1. Build your project
2. Deploy to their edge network
3. Provide you with a URL

Wait 1-2 minutes for deployment.

### Step 2.8: Get Frontend URL

After deployment, Vercel will show:
- **Production URL**: `https://ipmas-frontend.vercel.app` (or your custom name)

**Save this URL** - you'll need it for CORS!

---

## 📝 Part 3: Connect Frontend and Backend

### Step 3.1: Update CORS in Backend

Now that you have the frontend URL, update CORS:

```powershell
flyctl secrets set CORS_ORIGIN="https://ipmas-frontend.vercel.app" -a ipmas-backend
```

Replace with your actual Vercel frontend URL!

Fly.io will automatically redeploy the backend.

### Step 3.2: Verify Deployment

1. **Test Frontend**: Visit `https://ipmas-frontend.vercel.app`
2. **Open Browser Console** (F12)
3. **Check for errors**
4. **Test the map** - should load and work
5. **Check Network tab** - API calls should succeed

### Step 3.3: Test Backend Connection

In browser console, you should see successful API calls to:
`https://ipmas-backend-yourname.fly.dev`

---

## ✅ Verification Checklist

- [ ] Backend accessible: `https://ipmas-backend-yourname.fly.dev`
- [ ] Health check works: `/health` returns 200
- [ ] Frontend accessible: `https://ipmas-frontend.vercel.app`
- [ ] Map loads correctly
- [ ] No CORS errors in console
- [ ] API calls succeed (check Network tab)
- [ ] Socket.IO working (if applicable)

---

## 🐛 Troubleshooting

### Frontend can't connect to backend

1. **Check CORS_ORIGIN** in Fly.io:
   ```powershell
   flyctl secrets list -a ipmas-backend
   ```
   Should match your Vercel URL exactly.

2. **Verify backend URL** in `config.js` matches your Fly.io backend URL

3. **Check browser console** for CORS errors

### Backend not accessible

1. **Check backend status**:
   ```powershell
   flyctl status -a ipmas-backend
   ```

2. **Check logs**:
   ```powershell
   flyctl logs -a ipmas-backend
   ```

### Database connection issues

1. **Verify database attached**:
   ```powershell
   flyctl postgres list
   ```

2. **Check DATABASE_URL**:
   ```powershell
   flyctl secrets list -a ipmas-backend
   ```

### Vercel deployment fails

1. Check Vercel build logs
2. Verify Root Directory is `frontend`
3. Verify Output Directory is `public`
4. Check for build errors

---

## 📚 Next Steps

1. **Set up custom domain** (optional):
   - Vercel: Add domain in project settings
   - Fly.io: `flyctl domains add yourdomain.com -a ipmas-backend`

2. **Configure database backups**:
   ```powershell
   flyctl postgres backup list -a ipmas-db
   ```

3. **Set up monitoring**:
   - Vercel: Built-in analytics
   - Fly.io: `flyctl monitor -a ipmas-backend`

---

## 💰 Cost Estimate

### Free Tier:
- **Vercel**: Free (unlimited deployments)
- **Fly.io**: Free (3 VMs, 3GB storage)
- **Total**: $0/month

### After Free Tier:
- **Vercel**: Free (generous limits)
- **Fly.io**: ~$6-10/month
- **Total**: ~$6-10/month

---

## 🎉 Success!

Your IPMAS is now deployed with:
- **Frontend**: Fast edge network (Vercel)
- **Backend**: Reliable hosting (Fly.io)
- **Database**: PostgreSQL with PostGIS (Fly.io)

**Frontend**: `https://ipmas-frontend.vercel.app`  
**Backend**: `https://ipmas-backend-yourname.fly.dev`

---

**Need help?** Check the troubleshooting section or refer to:
- [Vercel Documentation](https://vercel.com/docs)
- [Fly.io Documentation](https://fly.io/docs)

