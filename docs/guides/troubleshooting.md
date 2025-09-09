# Troubleshooting - Flutter SDK
## Use Realm with the macOS App Sandbox
If you are developing with the Realm Flutter SDK in the macOS App Sandbox,
network requests do not work by default due to built-in macOS security settings.

To enable network requests, add the following code to **both** the files
`macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<!--  Other entitlements -->
<key>com.apple.security.network.client</key>
<true/>
<!--  Other entitlements -->
```

> **NOTE:** You can still use Realm locally without adding this network access permission.
>

For more information about Flutter development for macOS, refer to
[Building macOS apps with Flutter](https://docs.flutter.dev/development/platform-integration/macos/building#setting-up-entitlements)
in the Flutter documentation.

## iOS/iPad OS Bad Alloc/Not Enough Memory Available
In iOS or iPad devices with little available memory, or where you have a
memory-intensive application that uses multiple realms or many notifications,
you may encounter the following error:

```console
libc++abi: terminating due to an uncaught exception of type std::bad_alloc: std::bad_alloc
```

This error typically indicates that a resource cannot be allocated
because not enough memory is available.

If you are building for iOS 15+ or iPad 15+, you can add the
[Extended Virtual Addressing Entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_kernel_extended-virtual-addressing)
to resolve this issue.

Add the following keys to your Property List, and set the values to
`true`:

```xml
<key>com.apple.developer.kernel.extended-virtual-addressing</key>
<true/>
<key>com.apple.developer.kernel.increased-memory-limit</key>
<true/>
```
