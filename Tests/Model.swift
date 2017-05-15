//
//  Model.swift
//  RealmS
//
//  Created by DaoNV on 3/14/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper
@testable import RealmMapper

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

final class Phone: Object, Mappable {
    enum PhoneType: String {
        case work
        case home
    }

    dynamic var number = ""
    dynamic var type = PhoneType.home.rawValue

    let addresses = LinkingObjects(fromType: Address.self, property: "phone")

    convenience required init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        number <- map["number"]
        type <- map["type"]
    }
}

final class Dog: Object, StaticMappable {
    dynamic var id: String!
    dynamic var name: String?
    dynamic var color: String?

    let users = LinkingObjects(fromType: User.self, property: "dogs")

    override class func primaryKey() -> String? {
        return "id"
    }

    func mapping(map: Map) {
        name <- map["name"]
        color <- map["color"]
    }

    static func objectForMapping(map: Map) -> BaseMappable? {
        do {
            let realm = try Realm()
            return realm.object(ofType: self, forMapping: map, jsonPrimaryKey: "pk")
        } catch {
            return nil
        }
    }
}
