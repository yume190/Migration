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
                occurrence.symbol.kind == .protocol &&
                occurrence.location.isSystem
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
