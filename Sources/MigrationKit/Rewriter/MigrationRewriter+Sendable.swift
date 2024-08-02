//
//  File.swift
//  
//
//  Created by Tangram Yume on 2024/8/2.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SKClient

extension MigrationRewriter {
    private typealias Property = (letVar: String, hasMainActor: Bool, hasNonisolated: Bool, syntax: SyntaxProtocol)
    private final func property(_ node: DeclGroupSyntax) -> [Property] {
        let properties: [[Property]] = node.memberBlock.members.compactMap { member in
            if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                let letVar = varDecl.bindingSpecifier.text
                let hasMainActor = varDecl.hasMainActor
                let hasNonisolated = varDecl.hasNonisolated
                varDecl.unexpectedBetweenModifiersAndBindingSpecifier
                for binding in varDecl.bindings {
                    if let pattern = binding.pattern.as(IdentifierPatternSyntax.self) {
                        return [(letVar, hasMainActor, hasNonisolated, pattern)]
                    }
                    if let pattern = binding.pattern.as(TuplePatternSyntax.self) {
                        return pattern.elements.map { tuple in
                            (letVar, hasMainActor, hasNonisolated, tuple)
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
            if (property.hasMainActor || property.hasNonisolated) {
                continue
            }
            
            if (property.letVar == "var") {
                return false
            }
            let isSendable = store.isSendable(typeusr(property.syntax))
            if (!isSendable) {
                return false
            }
        }
        return true
    }
    
    /// AttributeList: [@MainActor]
    /// ModifierList: [public final]
    final func handleExplicitSendable(_ node: StructDeclSyntax) -> StructDeclSyntax {
        if store.isSendable(usr(node.name)) { return node }
        
        print(node.name.text)
        if (isAllPropertiesSendable(node)) {
            let inheritance = InheritanceClauseSyntax {
                if let origin = node.inheritanceClause {
                    origin.inheritedTypes
                }
                Symbols.sendable
            }
            let newNode = node.with(\.inheritanceClause, inheritance)
            return newNode
        }
        
        return node
    }
    
    final func handleExplicitSendable(_ node: ClassDeclSyntax) -> ClassDeclSyntax {
        if node.hasOpen { return node }
        if store.haveInheritance(usr(node.name)) { return node }
        if store.isSendable(usr(node.name)) { return node }
        if store.isNSObject(usr(node.name)) { return node }
        
        if (isAllPropertiesSendable(node)) {
            let inheritance = InheritanceClauseSyntax {
                if let origin = node.inheritanceClause {
                    origin.inheritedTypes
                }
                Symbols.sendable
            }
            
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
