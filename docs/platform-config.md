# Android Configuration

## AndroidManifest.xml permissions
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

## ProGuard rules
```proguard
-keep class com.chaoxing.** { *; }
-dontwarn com.chaoxing.**
```

# iOS Configuration

## Info.plist settings
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

# Windows Configuration

## Windows-specific settings
- Enable Windows desktop support
- Configure Windows-specific permissions
- Setup Windows-specific video player integration
