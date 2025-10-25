# Pinger iOS App

A Swift iOS application that monitors a URL by periodically "pinging" it and checking for specific content. The app sends push notifications when the expected content is not found.

## Features

- ✅ **URL Monitoring**: Configurable URL to monitor
- ✅ **Flexible Frequency**: Set ping frequency in seconds
- ✅ **Content Validation**: Define a content mask to search for in the response
- ✅ **Push Notifications**: Get notified when the mask is not found
- ✅ **Simple Interface**: Easy On/Off toggle to control monitoring
- ✅ **Configuration Screen**: Dedicated settings page for all parameters
- ✅ **Test Connection**: Test your configuration before saving

## How to Use

### 1. Configure Settings
1. Launch the app
2. Tap **"Configure Settings"**
3. Enter the following information:
   - **URL**: The website you want to monitor (e.g., `https://example.com`)
   - **Frequency**: How often to check in seconds (e.g., `30` for every 30 seconds)
   - **Content Mask**: Text to search for in the response (e.g., `"Welcome"`, `"OK"`, etc.)
4. Optionally tap **"Test Connection"** to verify your settings
5. Tap **"Save Configuration"**

### 2. Start Monitoring
1. Return to the main screen
2. Tap the **"START"** button
3. The app will begin monitoring your URL
4. Monitor status and last ping results on the main screen

### 3. Stop Monitoring
- Tap the **"STOP"** button to cease monitoring

## Notifications

The app will send a push notification in the following scenarios:
- **Content mask not found**: The response doesn't contain your specified text
- **Network error**: Unable to reach the URL
- **Invalid response**: Server returns an error status code
- **No content**: Empty response received

## Technical Details

### Architecture
- **MVC Pattern**: Clean separation of Model, View, and Controller
- **Singleton Services**: Centralized ping service and configuration management
- **Background Tasks**: Limited background execution support
- **UserNotifications**: Local push notifications

### Key Components

1. **PingConfiguration**: Model for storing URL, frequency, and mask settings
2. **ConfigurationManager**: Persistent storage of settings using UserDefaults
3. **PingService**: Core networking and monitoring logic
4. **MainViewController**: Main interface with start/stop controls
5. **ConfigurationViewController**: Settings screen with input validation

### Requirements
- iOS 13.0+
- Internet connection
- Notification permissions (requested on first launch)

### Limitations
- Background execution is limited by iOS (typically 30 seconds to 10 minutes)
- For continuous monitoring, keep the app in foreground
- HTTPS URLs recommended for security

## Files Structure

```
Pinger/
├── AppDelegate.swift              # App lifecycle and notification setup
├── SceneDelegate.swift            # Scene management
├── PingConfiguration.swift        # Data model and configuration manager
├── PingService.swift             # Network monitoring service
├── MainViewController.swift       # Main interface controller
├── ConfigurationViewController.swift # Settings screen controller
├── Main.storyboard               # User interface layout
├── LaunchScreen.storyboard       # App launch screen
└── Info.plist                    # App configuration and permissions
```

## Example Usage

1. **Website Monitoring**: Monitor `https://mywebsite.com` every 60 seconds, looking for "Server Status: OK"
2. **API Health Check**: Ping `https://api.service.com/health` every 30 seconds, looking for `"healthy"`
3. **Service Status**: Monitor `https://status.company.com` every 120 seconds, looking for "All Systems Operational"

## Error Handling

The app handles various error scenarios gracefully:
- Invalid URLs
- Network timeouts
- Server errors
- Missing content
- Configuration validation

All errors are logged and appropriate notifications are sent to the user.

---

**Note**: This app is designed for monitoring purposes. Excessive pinging of external servers should be done responsibly and with permission from the server owners.