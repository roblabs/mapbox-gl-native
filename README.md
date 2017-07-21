# Mapbox GL Native

A library for embedding interactive, customizable vector maps into native applications on multiple platforms. It takes stylesheets that conform to the [Mapbox Style Specification](https://github.com/mapbox/mapbox-gl-style-spec/), applies them to vector tiles that conform to the [Mapbox Vector Tile Specification](https://github.com/mapbox/vector-tile-spec), and renders them using OpenGL. [Mapbox GL JS](https://github.com/mapbox/mapbox-gl-js) is the WebGL-based counterpart, designed for use on the Web.

## Mapbox GL + WebP for iOS

This branch is to demonstrate and document source code on how to use Mapbox GL + WebP for iOS.

For the Cleveland National Forest map, "raster tiling with lossless PNG" created map data of 103 MB.  "Raster tiling using WebP", covering the same region, and the same zoom level created map data of 34 MB.  A reduction in size of 66 MB!!

Given that [iOS Apps are capped at 100 MB](https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/Chapters/SubmittingTheApp.html)... we at the Rob Labs are bullish on [WebP](http://RobLabs.com/webp).


This demo is based on the `mapbox-gl-native` tag  [ios-v3.6.0](https://github.com/mapbox/mapbox-gl-native/tree/ios-v3.6.0)

### WebP as a `mason` package

Ideally, WebP should be compiled using the [`mapbox/mason`](https://github.com/mapbox/mason) architecture.  *cf.* [#450](https://github.com/mapbox/mason/issues/450)

*  [platform/ios/config.cmake](platform/ios/config.cmake#L4) has comments on how to pull in WebP using Mason

### iOS Demo

* The base layer map for this Cleveland National Forest map is WebP at zoom level 14.

![webp-demo-mapbox-3.6.0.png](http://www.roblabs.com/assets/img/1970-01-01-webp-webp-demo-mapbox-3.6.0.png)

### WebP as a framework

For this Mapbox GL + WebP in iOS demonstration, we will be using the precompiled WebP framework downloaded from the [WebP source](https://developers.google.com/speed/webp/download).

1. Add WebP support based on discussion of [`mapbox/mapbox-gl-native` #3572](https://github.com/mapbox/mapbox-gl-native/issues/3572) and the branch [`webp-darwin`](https://github.com/mapbox/mapbox-gl-native/tree/webp-darwin)
  1. ✅ - See   [`image.mm`](platform/darwin/src/image.mm)
  1. ✅ - See  [`image.cpp`](platform/default/image.cpp)
1. ✅ - Add `WebP.framework` to `platform/ios`
1. `make clean`
1. `make iproj`
1. ✅ - Update the Headers Search path.  See the file  [`config.cmake`](platform/ios/config.cmake#L87)
1. ⚠️ - Manually add WebP to `build/ios/mbgl.xcodeproj`- * **TODO: - ** would be nice if this could be part of the Make*
  1. Open the `mbgl-core` target in Xcode
  1. Build Phases > `+` > New Link Binary with Libraries Phase
  1. `+` > Add others... > Navigate to WebP.framework
1. `make ipackage`

###### Emoji Interpreter

✅ = already done for you

⚠️ = manual step

#### Testing WebP on Mapbox GL for iOS

1. To test WebP tiles, you can base your style on these [examples](https://www.mapbox.com/ios-sdk/api/3.6.0/tile-url-templates.html) of PNG and [other](https://www.mapbox.com/mapbox-gl-js/example/third-party/) tiles

``` javascript
{
  "version": 8,
  "sources": {
    "webp-tiles": {
      "type": "raster",
      "url": "http://RobLabs.server/webp/raster/{z}/{x}/{y}.webp",
      "tileSize": 512
    }
  },
  "layers": [
    {
      "id": "webp-tiles-id",
      "type": "raster",
      "source": "webp-tiles"
    }
  ]
}
```
-----

## The Mapbox GL ecosystem

This repository hosts the cross-platform Mapbox GL Native library, plus convenient SDKs for several platforms. The cross-platform library comes with a [GLFW](https://github.com/glfw/glfw)-based demo application for Ubuntu Linux and macOS. The SDKs target the usual languages on their respective platforms:

| SDK                                     | Languages                          | Build status                             |
| --------------------------------------- | ---------------------------------- | ---------------------------------------- |
| [Mapbox GL Native](INSTALL.md)          | C++14                              | [![Travis](https://travis-ci.org/mapbox/mapbox-gl-native.svg?branch=master)](https://travis-ci.org/mapbox/mapbox-gl-native/builds) [![Coverage Status](https://coveralls.io/repos/github/mapbox/mapbox-gl-native/badge.svg?branch=master)](https://coveralls.io/github/mapbox/mapbox-gl-native?branch=master) |
| [Mapbox Android SDK](platform/android/) | Java                               | [![Bitrise](https://www.bitrise.io/app/79cdcbdc42de4303.svg?token=_InPF8bII6W7J6kFr-L8QQ&branch=master)](https://www.bitrise.io/app/79cdcbdc42de4303) |
| [Mapbox iOS SDK](platform/ios/)         | Objective-C or Swift               | [![Bitrise](https://www.bitrise.io/app/7514e4cf3da2cc57.svg?token=OwqZE5rSBR9MVWNr_lf4sA&branch=master)](https://www.bitrise.io/app/7514e4cf3da2cc57) |
| [Mapbox macOS SDK](platform/macos/)     | Objective-C, Swift, or AppleScript | [![Bitrise](https://www.bitrise.io/app/155ef7da24b38dcd.svg?token=4KSOw_gd6WxTnvGE2rMttg&branch=master)](https://www.bitrise.io/app/155ef7da24b38dcd) |
| [node-mapbox-gl-native](platform/node/) | Node.js                            | [![Linux](https://travis-ci.org/mapbox/mapbox-gl-native.svg?branch=master)](https://travis-ci.org/mapbox/mapbox-gl-native/builds) [![macOS](https://www.bitrise.io/app/55e3a9bf71202106.svg?token=5qf5ZUcKVN3LDnHhW7rO0w)](https://www.bitrise.io/app/55e3a9bf71202106) |
| [Mapbox Qt SDK](platform/qt)            | C++03                              | [![Travis](https://travis-ci.org/mapbox/mapbox-gl-native.svg?branch=master)](https://travis-ci.org/mapbox/mapbox-gl-native/builds) [![Bitrise](https://www.bitrise.io/app/96cfbc97e0245c22.svg?token=GxsqIOGPXhn0F23sSVSsYA&branch=master)](https://www.bitrise.io/app/96cfbc97e0245c22) |

Additional Mapbox GL Native–based libraries for **hybrid applications** are developed outside of this repository:

| Toolkit                                  | Android | iOS | Developer   |
| ---------------------------------------- | --------|-----|------------ |
| [React Native](https://github.com/mapbox/react-native-mapbox-gl/) ([npm](https://www.npmjs.com/package/react-native-mapbox-gl)) | :white_check_mark: | :white_check_mark: |  |
| [Apache Cordova](http://plugins.telerik.com/cordova/plugin/mapbox/) ([npm](https://www.npmjs.com/package/cordova-plugin-mapbox)) | :white_check_mark: | :white_check_mark: | Telerik |
| [NativeScript](http://plugins.telerik.com/nativescript/plugin/mapbox/) ([npm](https://www.npmjs.com/package/nativescript-mapbox/)) | :white_check_mark: | :white_check_mark: | Telerik |
| [Xamarin](https://components.xamarin.com/view/mapboxsdk/) | :white_check_mark: | :white_check_mark: | Xamarin |

If your platform or hybrid application framework isn’t listed here, consider embedding [Mapbox GL JS](https://github.com/mapbox/mapbox-gl-js) using the standard Web capabilities on your platform.
