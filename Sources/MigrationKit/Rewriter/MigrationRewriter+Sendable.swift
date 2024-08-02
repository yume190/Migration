//
//  File.swift
//  
//
//  Created by Tangram Yume on 2024/8/2.
//

import Foundation
import SwiftSyntax
import SKClient

extension MigrationRewriter {
    private typealias Property = (letVar: String, syntax: SyntaxProtocol)
    private final func property(_ node: DeclGroupSyntax) -> [Property] {
        let properties: [[Property]] = node.memberBlock.members.compactMap { member in
            if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                let letVar = varDecl.bindingSpecifier.text
                for binding in varDecl.bindings {
                    if let pattern = binding.pattern.as(IdentifierPatternSyntax.self) {
                        return [(letVar, pattern)]
                    }
                    if let pattern = binding.pattern.as(TuplePatternSyntax.self) {
                        return pattern.elements.map { tuple in
                            (letVar, tuple)
                        }
                    }
                }
            }
            return nil
        }
        return properties.flatMap { $0 }
    }
    
    private final func isAllPropertiesSendable(_ node: DeclGroupSyntax) -> Bool {
        let properties = property(node)
        if properties.isEmpty {
            return true
        }
        
        for property in properties {
            if (property.letVar == "var") {
                return false
            }
            let isSendable = (try? store.isSendable(typeusr(property.syntax))) ?? false
            if (!isSendable) {
                return false
            }
        }
        return true
    }
    
    /// AttributeList: [@MainActor]
    /// ModifierList: [public final]
    final func handleExplicitSendable(_ node: StructDeclSyntax) -> StructDeclSyntax {
        if (isAllPropertiesSendable(node)) {
            var inheritance = node.inheritanceClause ?? InheritanceClauseSyntax(inheritedTypes: [])
            inheritance.inheritedTypes.append(Symbols.sendable)
            let newNode = node.with(\.inheritanceClause, inheritance)
            return newNode
        }
        
        return node
    }
    
    final func handleExplicitSendable(_ node: ClassDeclSyntax) -> ClassDeclSyntax {
        if (isAllPropertiesSendable(node)) {
            var inheritance = node.inheritanceClause ?? InheritanceClauseSyntax(inheritedTypes: [])
            inheritance.inheritedTypes.append(Symbols.sendable)
            
            var modifiers = node.modifiers
            modifiers.append(Symbols.final)
            
            let newNode = node
                .with(\.inheritanceClause, inheritance)
                .with(\.modifiers, modifiers)
            
            return newNode
        }
        
        return node
    }
}
