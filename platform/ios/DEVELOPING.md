# Contributing to the Mapbox Maps SDK for iOS

This document explains how to build the Mapbox iOS SDK and the osxapp demo application for the purpose of developing the SDK itself.

### Requirements

The Mapbox iOS SDK and iosapp demo application build against the iOS 7.0 SDK and require Xcode on a computer running OS X.

### Build

1. [Install core dependencies](../../INSTALL.md).
  * For development on OS X, you can install pkg-config using `brew install pkg-config`  

1. Install [jazzy](https://github.com/realm/jazzy) for generating API documentation:

   ```
   [sudo] gem install jazzy
   ```

1. From the path at the root of the project, e.g. `/path/to/mapbox-gl-native $ `, run
```
  make ipackage  #  makes ./build/ios/pkg/static/
```
 The packaging script will produce the statically-linked `libMapbox.a`, `Mapbox.bundle` for resources, a `Headers` folder, and a `Docs` folder with HTML API documentation.

 ![makes ./build/ios/pkg/static/](libMapbox.a.png)

1.  Which will create and open an Xcode project that can build the entire library from source, as well as an Objective-C test app.
```
make iproj    # makes ./build/ios-all/gyp/ios.xcodeproj/
```
After opening `ios.xcodeproj`, you will see a couple of targets

  ![Open the project ios.xcodeproj](ios.xcodeproj.png)  

  ![Targets within ios.xcodeproj](ios.xcodeproj.targets.png)



If you don't have an Apple Developer account, change the destination from "My Mac" to a simulator such as "iPhone 6" before you run and build the app.

### Access Tokens

_The demo applications use Mapbox vector tiles, which require a Mapbox account and API access token. Obtain an access token on the [Mapbox account page](https://www.mapbox.com/studio/account/tokens/)._

Set up the access token by editing the scheme for the application target, then adding an environment variable with the name `MAPBOX_ACCESS_TOKEN`.

![edit scheme](https://cloud.githubusercontent.com/assets/98601/5460702/c4610262-8519-11e4-873a-8597821da468.png)

![setting access token in Xcode scheme](https://cloud.githubusercontent.com/assets/162976/5349358/0a086f00-7f8c-11e4-8433-bdbaccda2b58.png)

### Test

Run

    make itest

To run the included integration tests on the command line.

If you want to run the tests in Xcode instead, first `make ipackage` to create a local static library version, then open `test/ios/ios-tests.xcodeproj`, and lastly `Command + U` on the `Mapbox GL Tests` application target.

### Usage

- Pan to move
- Pinch to zoom
- Use two fingers to rotate
- Double-tap to zoom in one level
- Two-finger single-tap to zoom out one level
- Double-tap, long-pressing the second, then pan up and down to "quick zoom" (iPhone only, meant for one-handed use)
- Use the debug menu to add test annotations, reset position, and cycle through the debug options.
