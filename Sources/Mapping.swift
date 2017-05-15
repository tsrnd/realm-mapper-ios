//
//  Realm+ObjectMapper.swift
//  RealmMapper
//
//  Created by DaoNV on 3/13/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

extension NSError {
    internal static let domain = "RealmMapper"
}

extension Realm {
    /**
     Import JSON as BaseMappable Object.
     - parammeter T: BaseMappable Object.
     - parameter type: mapped type.
     - parameter json: JSON type is `[String: Any]`.
     - returns: mapped object.
     */
    @discardableResult
    public func map<T: Object>(_ type: T.Type, json: [String: Any], update: Bool = false) -> T? where T: BaseMappable {
        guard let obj = Mapper<T>().map(JSON: json) else {
            return nil
        }
        if obj.realm == nil {
            add(obj, update: update)
        }
        return obj
    }

    /**
     Import JSON as array of BaseMappable Object.
     - parammeter T: BaseMappable Object.
     - parameter type: mapped type.
     - parameter json: JSON type is `[[String: Any]]`.
     - returns: mapped objects.
     */
    @discardableResult
    public func map<T: Object>(_ type: T.Type, json: [[String: Any]], update: Bool = false) -> [T] where T: BaseMappable {
        var objs = [T]()
        for js in json {
            guard let obj = map(type, json: js, update: update) else { continue }
            objs.append(obj)
        }
        return objs
    }
}

// MARK: - StaticMappable pre-implement
extension Realm {
    /**
     Find cached BaseMappable Object.
     - parammeter T: BaseMappable Object.
     - parameter type: object type.
     - parameter map: Map object contains JSON.
     - parameter jsPk: primary key of JSON, default is equal to `primaryKey`.
     - returns: cached object.
     */
    public func object<T: Object>(ofType type: T.Type, forMapping map: Map, jsonPrimaryKey jsPk: String? = T.primaryKey()) -> T? where T: BaseMappable {
        guard let pk = T.primaryKey(), let jsPk = jsPk else {
            return T()
        }
        guard let id: Any = map[jsPk].value() else { return nil }
        if let exist = object(ofType: T.self, forPrimaryKey: id) {
            return exist
        }
        let new = T()
        new.setValue(id, forKey: pk)
        return new
    }
}
