# 🚀 Deploy Frontend to Vercel - Step by Step

Quick guide to deploy IPMAS frontend to Vercel (no payment required).

---

## 📋 Prerequisites

- GitHub account (repository: https://github.com/wn-marie/-IPMAS-.git)
- Vercel account (free at [vercel.com](https://vercel.com))

---

## 📝 Step 1: Sign Up for Vercel

1. Go to [vercel.com](https://vercel.com)
2. Click **"Sign Up"**
3. **Sign up with GitHub** (recommended - easiest)
4. Authorize Vercel to access your repositories

---

## 📝 Step 2: Prepare Frontend for Deployment

Since we don't have a backend URL yet, we'll set up the frontend to work with a placeholder. The frontend will still deploy and show the UI, but API calls will fail until we connect a backend.

### Option A: Use Meta Tag (Recommended)

Edit `frontend/public/index.html` and add this in the `<head>` section (around line 6, after the viewport meta tag):

```html
<meta name="api-url" content="http://localhost:3001">
```

This is a placeholder - we'll update it later when we have the backend URL.

### Option B: Leave as is

Your `config.js` already has fallback logic, so it will default to `localhost:3001` in production. This is fine for now.

---

## 📝 Step 3: Commit Changes (if you made any)

If you added the meta tag:

```powershell
cd C:\Users\Admin\Desktop\IPMAS-
git add frontend/public/index.html
git commit -m "Add placeholder API URL for Vercel deployment"
git push
```

---

## 📝 Step 4: Import Project to Vercel

1. In Vercel dashboard, click **"Add New..."** → **"Project"**
2. You'll see a list of your GitHub repositories
3. Find and select: **`wn-marie/-IPMAS-`**
4. Click **"Import"**

---

## 📝 Step 5: Configure Project Settings

Vercel will try to auto-detect settings. Configure as follows:

### Project Settings:

- **Project Name**: `ipmas-frontend` (or any name you like)
- **Framework Preset**: **"Other"** (since you're using vanilla JavaScript, not a framework)
- **Root Directory**: `frontend` ⚠️ **Important!**
- **Build Command**: Leave **empty** (or `npm install` if you need dependencies)
- **Output Directory**: `public` ⚠️ **Important!**
- **Install Command**: Leave **empty**

### Advanced Settings (click "Show Advanced Options"):

- **Environment Variables**: Leave empty for now (we'll add backend URL later)

---

## 📝 Step 6: Deploy

1. Click **"Deploy"** button
2. Wait 1-2 minutes while Vercel:
   - Clones your repository
   - Builds your project
   - Deploys to their edge network

---

## 📝 Step 7: Get Your Frontend URL

After deployment completes, Vercel will show:

- **Production URL**: `https://ipmas-frontend.vercel.app` (or your custom name)
- **Deployment Status**: ✅ Success

**Save this URL!** You'll need it when we set up the backend.

---

## ✅ Verify Deployment

1. **Visit your Vercel URL**: `https://ipmas-frontend.vercel.app`
2. **Check the page loads**: You should see the IPMAS interface
3. **Open Browser Console** (F12):
   - You may see API connection errors (this is normal - no backend yet)
   - The UI should still load and display

---

## 🎉 Success!

Your frontend is now live on Vercel! 

**Frontend URL**: `https://ipmas-frontend.vercel.app`

---

## 📝 Next Steps

Once we set up the backend, we'll:

1. Update the API URL in `index.html` (meta tag)
2. Or set it via Vercel environment variables
3. Redeploy (Vercel auto-deploys on git push)

---

## 🐛 Troubleshooting

### Deployment Fails

**Check:**
- Root Directory is set to `frontend` (not root)
- Output Directory is set to `public`
- Build Command is empty (or correct)
- Check Vercel build logs for errors

### Page Loads but Shows Errors

**Normal!** This is expected because:
- No backend connected yet
- API calls will fail
- The UI should still display

### Can't Find Repository

**Solution:**
- Make sure you authorized Vercel to access your GitHub
- Check repository is public or you've granted access
- Try refreshing the import page

---

## 💰 Cost

**Vercel Free Tier:**
- ✅ Unlimited deployments
- ✅ 100GB bandwidth/month
- ✅ Automatic HTTPS
- ✅ Edge network (fast worldwide)
- ✅ No credit card required

**Total Cost**: $0/month

---

**Your frontend is now live!** 🎉

Next, we'll explore backend alternatives that don't require payment methods.

