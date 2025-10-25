# How to Test Pinger iOS App on Appetize.io

## ✅ FIXED: Updated GitHub Actions Workflow

The workflow has been updated to use `actions/upload-artifact@v4` to resolve the deprecation warning.

## Option 1: Using GitHub Actions (Recommended)

### Steps:
1. **Create GitHub Repository**
   ```bash
   git init
   git add .
   git commit -m "Initial Pinger iOS app with fixed workflow"
   git branch -M main
   git remote add origin https://github.com/yourusername/pinger-ios.git
   git push -u origin main
   ```

2. **Trigger Build**
   - Go to your GitHub repository
   - Click on **Actions** tab
   - Click **"Build iOS App for Appetize"**
   - Click **"Run workflow"**
   - Wait for the build to complete (5-10 minutes)

3. **Download IPA**
   - Once build completes, click on the workflow run
   - Download the **"Pinger-iOS-App"** artifact
   - Extract the `.ipa` file

4. **Upload to Appetize.io**
   - Go to https://appetize.io
   - Click **"Upload App"**
   - Upload your `.ipa` file
   - Wait for processing
   - Get shareable link for testing

## Option 2: Alternative Cloud Build Services

### Codemagic
1. Connect your GitHub repository
2. Configure iOS workflow
3. Build and download IPA

### Bitrise
1. Add your repository 
2. Configure iOS build workflow
3. Download generated IPA

## Testing Configuration

### Test URLs for Pinger App:
```
✅ Success Test:
URL: https://httpbin.org/json
Frequency: 10 seconds
Content Mask: "slideshow"

❌ Failure Test:
URL: https://httpbin.org/status/404
Frequency: 5 seconds  
Content Mask: "success" (will not be found)

⏱️ Timeout Test:
URL: https://httpbin.org/delay/35
Frequency: 15 seconds
Content Mask: "delay" (will timeout)
```

## Expected Features to Test:

1. **Configuration Screen**
   - Enter URL, frequency, and content mask
   - Test connection button
   - Save configuration

2. **Main Screen**
   - START/STOP toggle button
   - Live status updates
   - Last ping results

3. **Push Notifications**
   - Grant notification permissions
   - Receive alerts when content mask not found
   - Receive alerts on network errors

4. **Background Operation**
   - App continues pinging when minimized (limited time)
   - UI updates when returning to foreground

## Troubleshooting

### If Build Fails:
- Check GitHub Actions logs
- Ensure all files are committed
- Verify Xcode project structure

### If Appetize Upload Fails:
- Ensure IPA file is not corrupted
- Try different upload browser
- Check file size limits

### If App Crashes:
- Check configuration values
- Ensure valid URLs
- Test with simpler URLs first

## Ready to Deploy!

Your Pinger iOS app is now ready for testing on Appetize.io. The app includes:

- ✅ Complete iOS Swift implementation
- ✅ Professional UI with storyboards
- ✅ Push notifications
- ✅ Background task support
- ✅ Configuration persistence
- ✅ Error handling
- ✅ Network monitoring

Upload the generated `.ipa` file to Appetize.io and start testing your URL monitoring app!