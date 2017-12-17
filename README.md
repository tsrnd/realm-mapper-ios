[![Build Status](https://travis-ci.org/tsrnd/realm-mapper-ios.svg?branch=master)](https://travis-ci.org/tsrnd/realm-mapper-ios)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/RealmMapper.svg)](https://img.shields.io/cocoapods/v/RealmMapper.svg)
[![Platform](https://img.shields.io/cocoapods/p/RealmMapper.svg?style=flat)](http://cocoadocs.org/docsets/RealmMapper)
[![Code Coverage](http://codecov.io/github/tsrnd/realm-mapper-ios/coverage.svg?branch=master)](http://codecov.io/github/tsrnd/realm-mapper-ios?branch=master)

[![RealmSwift](https://img.shields.io/badge/RealmSwift-~%3E%203.0-brightgreen.svg)](https://img.shields.io/badge/RealmSwift-~%3E%203.0-brightgreen.svg)
[![ObjectMapper](https://img.shields.io/badge/ObjectMapper-~%3E%202.2-brightgreen.svg)](https://img.shields.io/badge/ObjectMapper-~%3E%202.2-brightgreen.svg)

Realm + ObjectMapper
====================

## Requirements

 - iOS 8.0+
 - Xcode 8.3 (Swift 3.1)

## Installation

 > Embedded frameworks require a minimum deployment target of iOS 8

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
 ```

> CocoaPods 1.2+ is required to build RealmMapper 3.0+.

To integrate RealmMapper into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'RealmMapper', '~> 3.0'
```

Then, run the following command:

```bash
$ pod install
```

## Usage

### Mapping

**Rule:**
- Object has `primaryKey` must be StaticMappable (i)
- Object has no `primaryKey` should be Mappable (ii)

```swift
import RealmSwift
import ObjectMapper
import RealmMapper

final class User: Object, StaticMappable {
    dynamic var id: String!
    dynamic var name: String?
    dynamic var address: Address?
    let dogs = List<Dog>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        address <- map["address"]
        dogs <- map["dogs"]
    }
      
    static func objectForMapping(map: Map) -> BaseMappable? {
        do {
            let realm = try Realm()
            return realm.object(ofType: self, forMapping: map)
        } catch {
            return nil
        }
    }
}

// (ii)
final class Address: Object, Mappable {
    dynamic var street = ""
    dynamic var city = ""
    dynamic var country = ""

    dynamic var phone: Phone?

    let users = LinkingObjects(fromType: User.self, property: "address")

    convenience required init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        street <- map["street"]
        city <- map["city"]
        country <- map["country"]
        phone <- map["phone"]
    }
}
```

### Import JSON to Realm

```swift
do {
  let realm = try Realm()
  try realm.write {
    realm.map(User.self, json: jsUser) // map JSON object
    realm.map(Shop.self, json: jsShops) // map JSON array
  }
} catch {
}

```

> nil value will be bypass, if you want set `nil` please use `NSNull()` instead
