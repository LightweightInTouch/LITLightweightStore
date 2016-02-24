# LITLightweightStore

[![CI Status](http://img.shields.io/travis/Lobanov Dmitry/LITLightweightStore.svg?style=flat)](https://travis-ci.org/Lobanov Dmitry/LITLightweightStore)
[![Version](https://img.shields.io/cocoapods/v/LITLightweightStore.svg?style=flat)](http://cocoapods.org/pods/LITLightweightStore)
[![License](https://img.shields.io/cocoapods/l/LITLightweightStore.svg?style=flat)](http://cocoapods.org/pods/LITLightweightStore)
[![Platform](https://img.shields.io/cocoapods/p/LITLightweightStore.svg?style=flat)](http://cocoapods.org/pods/LITLightweightStore)


This is a lightweight key-value store which could be useful if you have several settings in app and you don't know where you should place them

##Requirements
iOS 7 or later

##Features

- Easy to use
- Convenience setup

###What implemented?

- in-Memory dictionary store
- Defaults store
- Keychain store ( [UICKeyChainStore inside](https://github.com/kishikawakatsumi/UICKeyChainStore)
)
- Policy switching (move your data between stores)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

LITLightweightStore is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "LITLightweightStore"
```

###Import

Import store into your project, just add 

```objective-c
#import<LITLightweightStore/LITLightweightStore.h>
// or
@import LITLightweightStore;
```

###Examples

#### Storing device Id
Suppose, that you have sensitive data or settings.
Suppose, that you need a device id that you generated by yourself or you need first-user-install option.

Let's see example:

```objective-c
# put device id 
NSString *deviceId = @"deviceId"; // please, use not so obvious name, of course.

// setup store in memory
LITLightweightStore *store = 
[LITLightweightStore storeWithPolicy:LITLightweightStorePolicyMemory options:@{LITLightweightStoreOptionsStoreScopeNameKey: @"app_settings", LITLightweightStoreOptionsAllFieldsArrayKey: deviceId}];

[store setField:deviceId byValue:@"YOUR_DEVICE_ID"];

// and if you go to release:
[store switchPolicy:LITLightweightStorePolicyDefaults];

// or more long-live:
[store switchPolicy:LITLightweightStorePolicyKeychain];
```

#### Cleanup

```objective-c
[store tearDown]; // cleanup store

[store setField:deviceId byValue:nil]; // cleanup value for field +deviceId+
```

#### Switch policy

```objective-c
LITLightweightStore *newStore = [store switchPolicy:LITLightweightStorePolicyDefaults];
LITLightweightStore *newStore = [store switchPolicy:LITLightweightStorePolicyKeychain];
```

## Author

Lobanov Dmitry, gaussblurinc@gmail.com

## License

LITLightweightStore is available under the MIT license. See the LICENSE file for more info.
