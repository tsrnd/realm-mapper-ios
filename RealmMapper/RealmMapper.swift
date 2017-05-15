//
//  Realm+ObjectMapper.swift
//  RealmMapper
//
//  Created by DaoNV on 3/13/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

public typealias JSObject = [String: Any]
public typealias JSArray = [JSObject]

public let RMErrorDomain = "RealmMapper"

// MARK: MAPPING
extension Realm {

    // MARK: Import

    /**
     Import JSON as Mappable Object.
     - parammeter T: Mappable Object.
     - parameter type: mapped type.
     - parameter json: JSON type is `[String: AnyObject]`.
     - returns: mapped object.
     */
    @discardableResult
    public func map<T: Object>(_ type: T.Type, json: JSObject) throws -> T where T: Mappable {
        let obj = try Mapper<T>().map(json)
        if obj.realm == nil {
            add(obj)
        }
        return obj
    }
    
    /**
     Import JSON as Mappable Object.
     - parammeter T: Mappable Object.
     - parameter type: mapped type.
     - parameter json: JSON type is `[String: AnyObject]`.
     - returns: mapped object.
     */
    @discardableResult
    public func map<T: Object>(_ type: T.Type, json: JSObject, allowUpdates: Bool) throws -> T where T: Mappable {
        let obj = try Mapper<T>().map(json)
        if obj.realm == nil {
            add(obj, update: allowUpdates)
        }
        return obj
    }

    /**
     Import JSON as array of Mappable Object.
     - parammeter T: Mappable Object.
     - parameter type: mapped type.
     - parameter json: JSON type is `[[String: AnyObject]]`.
     - returns: mapped objects.
     */
    @discardableResult
    public func map<T: Object>(_ type: T.Type, json: JSArray) throws -> [T] where T: Mappable {
        var objs = [T]()
        for js in json {
            let obj = try map(type, json: js)
            objs.append(obj)
        }
        return objs
    }
}

// Workaround Mappable init
extension Mappable {
    fileprivate init?(_ map: Map) {
        self.init(map: map)
    }
}

extension Mapper where N: Object, N: Mappable {

    /**
     Map JSON as Mappable Object.
     - parammeter N: Mappable Object.
     - parameter json: JSON type is `[String: AnyObject]`.
     - returns: mapped object.
     */
    public func map(_ json: JSObject) throws -> N {
        let mapper = Mapper<N>()
        let map = Map(mappingType: .fromJSON, JSON: json, toObject: true)

        guard let key = N.primaryKey() else {
            guard let obj: N = N(map) else {
                let info: JSObject = [NSLocalizedDescriptionKey: "Invalid \(N.self) JSON: \(map.JSON)"]
                throw NSError(domain: RMErrorDomain, code: -999, userInfo: info)
            }
            return mapper.map(JSON: json, toObject: obj)
        }
        guard let obj = N.init(map) else {
            let info: JSObject = [NSLocalizedDescriptionKey: "Invalid \(N.self) JSON: \(map.JSON)"]
            throw NSError(domain: RMErrorDomain, code: -999, userInfo: info)
        }
        guard let id = obj.value(forKey: key) else {
            let info: JSObject = [NSLocalizedDescriptionKey: "\(N.self)'s primary key must be mapped in init?(_ map: Map)"]
            throw NSError(domain: RMErrorDomain, code: -999, userInfo: info)
        }

        let realm = try Realm()
        if let old = realm.object(ofType: N.self, forPrimaryKey: id) {
            return mapper.map(JSON: json, toObject: old)
        } else {
            return mapper.map(JSON: json, toObject: obj)
        }
    }

    /**
     Map JSON as Mappable Object.
     - parammeter N: Mappable Object.
     - parameter jsArray: JSON type is `[[String: AnyObject]]`.
     - returns: mapped objects.
     */
    public func map(_ jsArray: JSArray) throws -> [N] {
        var objs = [N]()
        for json in jsArray {
            let obj = try map(json)
            objs.append(obj)
        }
        return objs
    }
}

// MARK: OPERATORS

/**
 Map to optional Mappable Object.
 - parammeter T: Mappable Object.
 - parameter left: Optional variable.
 - parameter right: Map object.
 */
public func <- <T: Object>(left: inout T?, right: Map) throws where T: Mappable {
    if right.mappingType == MappingType.fromJSON {
        if !right.isKeyPresent { return }
        guard let value = right.currentValue else {
            left = nil
            return
        }
        guard let json = value as? JSObject else { return }
        let obj = try Mapper<T>().map(json)
        left = obj
    } else {
        left <- (right, ObjectTransform<T>())
    }
}

/**
 Map to implicitly unwrapped optional Mappable Object.
 - parammeter T: Mappable Object.
 - parameter left: Implicitly unwrapped optional variable.
 - parameter right: Map object.
 */
public func <- <T: Object>(left: inout T!, right: Map) throws where T: Mappable {
    var object: T? = left
    try object <- right
}

/**
 Relation must be marked as being optional or implicitly unwrapped optional.
 - parammeter T: Mappable Object.
 - parameter left: mapped variable.
 - parameter right: Map object.
 */
@available( *, deprecated : 1, message : "Relation must be marked as being optional or implicitly unwrapped optional.")
public func <- <T: Object>(left: inout T, right: Map) where T: Mappable {
    fatalError("DEPRECATED: Relation must be marked as being optional or implicitly unwrapped optional.")
}

/**
 Map to List of Mappable Object.
 - parammeter T: Mappable Object.
 - parameter left: mapped variable.
 - parameter right: Map object.
 */
public func <- <T: Object>(left: List<T>, right: Map) throws where T: Mappable {
    if right.mappingType == MappingType.fromJSON {
        if !right.isKeyPresent { return }
        left.removeAll()
        guard let json = right.currentValue as? JSArray else { return }
        let objs = try Mapper<T>().map(json)
        left.append(objectsIn: objs)
    } else {
        var _left = left
        _left <- (right, ListTransform<T>())
    }
}

// MARK: TRANSFORM

/**
 Transform for Object, only support transform to JSON.
 */
private class ObjectTransform<T: Object>: TransformType where T: Mappable {
    @available( *, deprecated: 1, message: "Please use direct mapping without transform.")
    func transformFromJSON(_ value: Any?) -> T? {
        fatalError("DEPRECATED: Please use direct mapping without transform.")
    }

    func transformToJSON(_ value: T?) -> Any? {
        guard let obj = value else { return NSNull() }
        var json = Mapper<T>().toJSON(obj)
        if let key = T.primaryKey() {
            json[key] = obj.value(forKey: key)
        }
        return json
    }
}

/**
 Transform for List of Object, only support transform to JSON.
 */
private class ListTransform<T: Object>: TransformType where T: Mappable {
    @available( *, deprecated: 1, message: "Please use direct mapping without transform.")
    func transformFromJSON(_ value: Any?) -> List<T>? {
        fatalError("DEPRECATED: Please use direct mapping without transform.")
    }

    func transformToJSON(_ value: List<T>?) -> Any? {
        guard let list = value else { return NSNull() }
        var json = JSArray()
        let mapper = Mapper<T>()
        for obj in list {
            json.append(mapper.toJSON(obj))
        }
        return json
    }
}
