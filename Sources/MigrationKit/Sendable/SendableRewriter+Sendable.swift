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

extension SendableRewriter {
    private final func property(_ node: DeclGroupSyntax) -> [Property] {
        let properties: [[Property]] = node.memberBlock.members.compactMap { member in
            if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                return Property.parse(varDecl)
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
            if (property.decl.hasMainActor || property.decl.hasNonisolated) {
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
    
    final func handleExplicitSendable(_ node: StructDeclSyntax) -> StructDeclSyntax {
        if store.isSendable(usr(node.name)) { return node }
        
        if (isAllPropertiesSendable(node)) {
            return node.addSendable()
        }
        
        return node
    }
    
    final func handleExplicitSendable(_ node: ClassDeclSyntax) -> ClassDeclSyntax {
        if node.hasOpen { return node }
        if store.hasChildClass(usr(node.name)) { return node }
        if store.isSendable(usr(node.name)) { return node }
        if store.isNSObject(usr(node.name)) { return node }
        
        if (isAllPropertiesSendable(node)) {
            return node
                .addFinal()
                .addSendable()
        }
        
        return node
    }
    
    final func handleExplicitSendable(_ node: EnumDeclSyntax) -> EnumDeclSyntax {
        let visitor = EnumParameterVisitor(store: store, client: client)
        visitor.walk(node)
        if visitor.isSendable {
            return node.addSendable()
        }
        
        return node
    }
}

final class EnumParameterVisitor: SyntaxVisitor {
    let store: IndexStore
    let client: SKClient
    var isSendable = true
    public init(store: IndexStore, client: SKClient) {
        self.store = store
        self.client = client
        super.init(viewMode: .sourceAccurate)
    }
    
    override func visit(_ node: EnumCaseParameterSyntax) -> SyntaxVisitorContinueKind {
        /// early skip
        guard isSendable else { return .skipChildren }
        
        isSendable = isSendable && store.isSendable(usr(node.type))
        return .skipChildren
    }
}
