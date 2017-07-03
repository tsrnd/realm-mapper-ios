//
//  Operator.swift
//  RealmMapper
//
//  Created by DaoNV on 5/15/17.
//  Copyright © 2017 AsianTech Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

/**
 Map to optional BaseMappable Object.
 - parammeter T: BaseMappable Object.
 - parameter left: Optional variable.
 - parameter right: Map object.
 */
public func <- <T: Object>(left: inout T?, right: Map) where T: BaseMappable {
    if right.mappingType == MappingType.fromJSON {
        if !right.isKeyPresent { return }
        guard let value = right.currentValue else {
            left = nil
            return
        }
        guard let json = value as? [String: Any],
            let obj = Mapper<T>().map(JSON: json) else { return }
        left = obj
    } else {
        left <- (right, ObjectTransform<T>())
    }
}

/**
 Map to implicitly unwrapped optional BaseMappable Object.
 - parammeter T: BaseMappable Object.
 - parameter left: Implicitly unwrapped optional variable.
 - parameter right: Map object.
 */
public func <- <T: Object>(left: inout T!, right: Map) where T: BaseMappable {
    var object: T? = left
    object <- right
}

/**
 Map to List of BaseMappable Object.
 - parammeter T: BaseMappable Object.
 - parameter left: mapped variable.
 - parameter right: Map object.
 */
public func <- <T: Object>(left: List<T>, right: Map) where T: BaseMappable {
    if right.mappingType == MappingType.fromJSON {
        if !right.isKeyPresent { return }
        left.removeAll()
        guard let json = right.currentValue as? [[String: Any]] else { return }
        let objs = Mapper<T>().mapArray(JSONArray: json)
        left.append(objectsIn: objs)
    } else {
        var _left = left
        _left <- (right, ListTransform<T>())
    }
}

// MARK: - Deprecated

/**
 Relation must be marked as being optional or implicitly unwrapped optional.
 - parammeter T: BaseMappable Object.
 - parameter left: mapped variable.
 - parameter right: Map object.
 */
@available( *, deprecated: 1, message: "Relation must be marked as being optional or implicitly unwrapped optional.")
public func <- <T: Object>(left: inout T, right: Map) where T: BaseMappable {
    fatalError("Deprecated: Relation must be marked as being optional or implicitly unwrapped optional.")
}
