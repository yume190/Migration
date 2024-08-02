//
//  File.swift
//  Migration
//
//  Created by Tangram Yume on 2024/8/1.
//

import Foundation
import SwiftSyntax

extension MigrationRewriter {
    
    /// AttributeList: [@MainActor]
    /// ModifierList: [public final]
    func handle(_ node: StructDeclSyntax) -> StructDeclSyntax {
        do {
            
            let isSendable = try self.store.isSendable(typeusr(node.name))
            let comforms = try self.store.allComforms(typeusr(node.name))
            print(node.name.text, "is Sendable: ", isSendable, comforms)
            
            
        } catch {
            return node
        }
        
        return node
    }
    
    
}
