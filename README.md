# RevUp Bikes Mobile App

A Flutter mobile application that provides an enhanced mobile experience for the RevUp Bikes website (https://revupbikes.com/). This app integrates the website seamlessly while offering mobile-optimized features and native functionality.

## Features

### 🚀 Core Features
- **Integrated WebView**: Full website functionality within the mobile app
- **Mobile-Optimized**: Enhanced user experience specifically designed for mobile devices
- **No External Redirections**: All website operations stay within the app
- **Offline Detection**: Smart connectivity monitoring with retry mechanisms
- **Native Phone Integration**: Direct calling functionality for customer support

### 📱 Mobile UX Enhancements
- **Splash Screen**: Beautiful animated startup screen with RevUp branding
- **Pull-to-Refresh**: Intuitive refresh functionality
- **Loading Indicators**: Progress bars and loading states for better user feedback
- **Custom Navigation**: Bottom navigation bar with back/forward/refresh/home buttons
- **Quick Action Buttons**: Floating action buttons for home and phone support

### ⚙️ Settings & Customization
- **Settings Screen**: Comprehensive settings with app preferences
- **Quick Actions**: Easy access to homepage, refresh, and support
- **About Section**: App information and company details
- **Privacy & Terms**: Direct access to policy pages
- **Share Functionality**: Easy app sharing with copy-to-clipboard

### 🔧 Technical Features
- **Connectivity Monitoring**: Real-time network status detection
- **Error Handling**: Graceful error states with retry options
- **JavaScript Injection**: Mobile optimization scripts for better web experience
- **URL Handling**: Smart navigation with external link management
- **Progressive Loading**: Smooth loading experience with progress indicators

## Installation

1. **Prerequisites**:
   - Flutter SDK installed
   - Android Studio or VS Code with Flutter extensions
   - Physical device or emulator

2. **Setup**:
   ```bash
   git clone [repository-url]
   cd rev_app
   flutter pub get
   flutter run
   ```

3. **Platform Configuration**:
   - Android: Internet permissions pre-configured
   - iOS: App Transport Security configured for web content

## Technical Implementation

### Dependencies
- `webview_flutter`: For web content integration
- `connectivity_plus`: For network monitoring
- `url_launcher`: For external app launches
- `flutter/material`: For UI components

### Platform Support
- **Android**: Full support with internet permissions
- **iOS**: Full support with App Transport Security configuration
- **Responsive Design**: Adapts to different screen sizes

## App Architecture

### Main Components
- **SplashScreen**: Animated startup screen
- **RevUpWebViewScreen**: Main webview integration
- **SettingsScreen**: App configuration and information
- **Error Handling**: Network and loading error management

### Navigation Flow
1. Splash Screen (2 seconds with animations)
2. Main WebView Screen (RevUp website integration)
3. Settings Screen (accessible via menu)
4. Error/Offline Screens (when needed)

## Mobile Optimizations

### Web Content Enhancements
- Custom CSS injection for mobile experience
- Viewport optimization for mobile devices
- Touch interaction improvements
- Smooth scrolling implementation

### Performance Features
- Lazy loading for better performance
- Memory management for webview
- Network optimization
- Progressive loading indicators

## Support & Contact

- **Website**: https://revupbikes.com/
- **Phone**: +91 7020038007
- **Email**: email@revupbikes.com

---

*Your Journey, Your Ride* 🏍️
