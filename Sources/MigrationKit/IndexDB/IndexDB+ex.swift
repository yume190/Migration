//
//  File.swift
//  Migration
//
//  Created by Tangram Yume on 2024/8/1.
//

import Foundation
import IndexStoreDB

/// `occurrences(relatedToUSR:)`
extension IndexStore {
    /// [ref|baseOf]
    ///
    /// Decl: class BBB: AAA, PPP, @unchecked Sendable {}
    /// input: BBB
    /// output: [AAA, PPP, Sendable]
    func comforms(_ usr: String) -> [SymbolOccurrence] {
        return db.occurrences(relatedToUSR: usr, roles: [.reference, .baseOf])
    }
    
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
    
    /// [def|childOf|canon]
    ///
    /// instance let/var/getter
    func property(_ usr: String) -> [SymbolOccurrence] {
        return db.occurrences(relatedToUSR: usr, roles: [.definition, .childOf, .canonical])
            .filter { occurrence in
                occurrence.symbol.kind == .instanceProperty
            }
    }
    
    func all(_ usr: String) -> [SymbolOccurrence] {
        return db.occurrences(ofUSR: usr, roles: .all)
    }
    
    func allRelated(_ usr: String) -> [SymbolOccurrence] {
        return db.occurrences(relatedToUSR: usr, roles: .all)
    }
}

extension IndexStore {
    /// Find Parent Class
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



/// `occurrences(ofUSR:)`
extension IndexStore {
    /// [ref|extendedBy]
    ///
    /// extension XXX {}
    func findExtension(_ usr: String) -> [SymbolOccurrence] {
        return db.occurrences(ofUSR: usr, roles: [.reference, .extendedBy])
    }
    
    /// [ref|baseOf]
    ///
    /// class T: XXX {}
    func haveInheritance(_ usr: String) -> Bool {
        return !db.occurrences(ofUSR: usr, roles: [.reference, .baseOf]).isEmpty
    }
}
