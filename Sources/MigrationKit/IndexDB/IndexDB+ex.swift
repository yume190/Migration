//
//  File.swift
//  Migration
//
//  Created by Tangram Yume on 2024/8/1.
//

import Foundation
import IndexStoreDB

// MARK: - `occurrences(relatedToUSR:)`

/// Input Code
/// ```swift
/// protocol P1 {}
/// protocol P2 {}
///
/// class Class1 {}
/// class Class2: Class1, P1, @unchecked Sendable {
///     let property1: Int
///     var property2: Int
///     var property3: Int {
///         return 1
///     }
/// }
/// extension Class2: P2 {}
/// ```
extension IndexStore {
    /// [ref|baseOf]
    ///
    /// output: [Class1, P1, Sendable]
    func comforms(_ usr: String) -> [SymbolOccurrence] {
        return db.occurrences(
            relatedToUSR: usr,
            roles: [
//                .reference,
                .baseOf,
            ])
    }
    
    /// output: [Class1, P1, Sendable, P2]
    func allComforms(_ usr: String) -> [SymbolOccurrence] {
        let origin = comforms(usr)
        let extensions = findExtension(usr)
        let extensionsComforms = extensions.map(\.relations).flatMap{$0}.map(\.symbol.usr).map(comforms(_:)).flatMap{$0}
        return origin + extensionsComforms
    }
    
    func isSendable(_ usr: String) -> Bool {
        let comforms = allComforms(usr)
        return !comforms.filter { occurrence in
            return
                occurrence.symbol.name == "Sendable" &&
                occurrence.symbol.kind == .protocol
        }.isEmpty
    }
    
    func isMainActor(_ usr: String) -> Bool {
        let occurrences = db.occurrences(relatedToUSR: usr, roles: .containedBy)
        return !occurrences.filter { occurrence in
            return
                occurrence.symbol.name == "MainActor" &&
                occurrence.symbol.kind == .class
        }.isEmpty
    }
    
    /// [def|childOf|canon]
    ///
    /// instance let/var/getter
    /// output: [property1, property2, property3]
    func property(_ usr: String) -> [SymbolOccurrence] {
        return db.occurrences(relatedToUSR: usr, roles: [.definition, .childOf, .canonical])
            .filter { occurrence in
                occurrence.symbol.kind == .instanceProperty
            }
    }
    
    /// instance properyty and static property
    func allProperty(_ usr: String) -> [SymbolOccurrence] {
        return db.occurrences(relatedToUSR: usr, roles: [.definition, .childOf, .canonical])
            .filter { occurrence in
                occurrence.symbol.kind == .instanceProperty ||
                occurrence.symbol.kind == .staticProperty ||
                occurrence.symbol.kind == .classProperty
            }
    }
}

// MARK: - Find Parent Class

extension IndexStore {
    func parent(_ usr: String) -> SymbolOccurrence? {
        let conforms = comforms(usr).filter { occurence in
            return occurence.symbol.kind == .class
        }
        return conforms.first
    }
    
    func parents(_ usr: String) -> [SymbolOccurrence] {
        if let parent = parent(usr) {
            return [parent] + parents(parent.symbol.usr)
        }
        return []
    }
    
    func rootParent(_ usr: String) -> SymbolOccurrence? {
        return parents(usr).last
    }
    
    func isNSObject(_ usr: String) -> Bool {
        let root = rootParent(usr)
        return
            root?.symbol.name == "NSObject" &&
            root?.symbol.kind == .class
    }
}

// MARK: - `occurrences(ofUSR:)`
extension IndexStore {
    /// [ref|extendedBy]
    ///
    /// output: `extension Class2: P2 {}`
    func findExtension(_ usr: String) -> [SymbolOccurrence] {
        return db.occurrences(ofUSR: usr, roles: [.reference, .extendedBy])
    }
    
    /// [ref|baseOf]
    ///
    /// input: `Class1`
    /// ouput: ![Class2].isEmpty
    func hasChildClass(_ usr: String) -> Bool {
        return !db.occurrences(ofUSR: usr, roles: [.reference, .baseOf]).isEmpty
    }
}

// MARK:
extension IndexStore {
    /// all [ref|read|contBy]
    /// 7:11
    /// relation
        /// - usr : "s:7Library4testyyF"
        /// - name : "test()"
        /// [contBy]
    func findCaller(_ usr: String) -> [SymbolOccurrence] {
        return db.occurrences(ofUSR: usr, roles: [.reference, .read, .containedBy])
            .filter { occurrence in
                return !occurrence.relations.isEmpty
            }
            .flatMap { occurrence in
                /// [def|dyn|childOf|accOf|canon]
                if occurrence.relations.first!.symbol.name.hasPrefix("getter:") || occurrence.relations.first!.symbol.name.hasPrefix("setter:") {
                    let result = db.occurrences(ofUSR: occurrence.relations.first!.symbol.usr, roles: [.accessorOf])
                    return result
                }
                return [occurrence]
            }
    }
}

// MARK: - Other

extension IndexStore {
    func all(_ usr: String) -> [SymbolOccurrence] {
        return db.occurrences(ofUSR: usr, roles: .all)
    }
    
    func allRelated(_ usr: String) -> [SymbolOccurrence] {
        return db.occurrences(relatedToUSR: usr, roles: .all)
    }
}
