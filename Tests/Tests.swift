//
//  Tests.swift
//  Tests
//
//  Created by DaoNV on 3/13/16.
//  Copyright © 2016 AsianTech Inc. All rights reserved.
//

import XCTest
import RealmSwift
@testable import RealmMapper

typealias JSObject = [String: Any]
typealias JSArray = [JSObject]

class Tests: XCTestCase {

    var jsUser: JSObject = [
        "id": "1",
        "name": "User",
        "address": [
            "street": "123 Street",
            "city": "City",
            "country": "Country",
            "phone": [
                "number": "+849876543210",
                "type": "Work"
            ]
        ],
        "dogs": [
            [
                "id": "1",
                "name": "Pluto",
                "color": "Black"
            ]
        ]
    ]

    let jsDogs: JSArray = [
        [
            "id": "1",
            "name": "Pluto",
            "color": "Black new"
        ],
        [
            "id": "2",
            "name": "Lux",
            "color": "White"
        ]
    ]

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
    }

    override func tearDown() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        super.tearDown()
    }

    func test_map() {
        do {
            let realm = try Realm()
            try realm.write {
                try realm.map(User.self, json: jsUser)
            }
            let userID: String! = jsUser["id"] as? String
            let user: User! = realm.objects(User.self).filter("id = %@", userID).first
            XCTAssertNotNil(user)
            let addr: Address! = user.address
            XCTAssertNotNil(addr)
            XCTAssertNotNil(addr.phone)
            XCTAssertEqual(user.dogs.count, 1)
            try realm.write {
                try realm.map(User.self, json: jsUser)
            }
            let users = realm.objects(User.self).filter("id = %@", userID)
            XCTAssertEqual(users.count, 1)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_add() {
        do {
            var dogs: [Dog] = []
            for i in 1...3 {
                let obj = Dog()
                obj.id = "\(i)"
                obj.name = "Pluto"
                obj.color = "white"
                dogs.append(obj)
            }
            let realm = try Realm()
            try realm.write {
                realm.add(dogs)
            }
            XCTAssertEqual(realm.objects(Dog.self).count, 3)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_addNilObject() {
        do {
            let realm = try Realm()
            try realm.write {
                try realm.map(User.self, json: jsUser)
            }
            guard let userID = jsUser["id"] else { assertionFailure("jsUser has no id"); return }
            if let user = realm.objects(User.self).filter("id = %@", userID).first {
                jsUser["address"] = nil
                try realm.write {
                    try realm.map(User.self, json: jsUser)
                }
                XCTAssertNotNil(user.address)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_addNullObject() {
        do {
            let realm = try Realm()
            try realm.write {
                try realm.map(User.self, json: jsUser)
            }
            guard let userID = jsUser["id"] else { assertionFailure("jsUser has no id"); return }
            guard let user = realm.objects(User.self).filter("id = %@", userID).first else { return }
            jsUser["address"] = NSNull()
            try realm.write {
                try realm.map(User.self, json: jsUser)
            }
            XCTAssertNil(user.address)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_addNilList() {
        do {
            let realm = try Realm()
            try realm.write {
                try realm.map(User.self, json: jsUser, allowUpdates: true)
            }
            guard let userID = jsUser["id"] else { assertionFailure("jsUser has no id"); return }
            if let user = realm.objects(User.self).filter("id = %@", userID).first {
                jsUser["dogs"] = nil
                try realm.write {
                    try realm.map(User.self, json: jsUser)
                }
                XCTAssertEqual(user.dogs.count, 1)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_addNullList() {
        do {
            let realm = try Realm()
            try realm.write {
                try realm.map(User.self, json: jsUser, allowUpdates: true)
            }
            guard let userID = jsUser["id"] else { assertionFailure("jsUser has no id"); return }
            if let user = realm.objects(User.self).filter("id = %@", userID).first {
                jsUser["dogs"] = NSNull()
                try realm.write {
                    try realm.map(User.self, json: jsUser)
                }
                XCTAssertEqual(user.dogs.count, 0)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
