//
//  File.swift
//  
//
//  Created by Tangram Yume on 2024/8/7.
//

import Foundation
import SwiftSyntax
import SKClient

public final class MainActorRewriter: SyntaxRewriter {
    let store: IndexStore
    let client: SKClient
    let logic: MainActorLogic
    private var _properties: [Property] = []
    
    public init(store: IndexStore, client: SKClient, logic: MainActorLogic) {
        self.store = store
        self.client = client
        self.logic = logic
    }
    
    public override func visit(_ node: VariableDeclSyntax) -> DeclSyntax {
        let properties = Property.parse(node)
        for property in properties {
            let usr = usr(property.syntax)
            
            let kind = try? client(property.syntax).kind
            let isInstanceVariable = kind == .declVarInstance
            if !isInstanceVariable {
                continue
            }
            
            if logic.fixs.contains(usr) {
                return .init(node.addMainActor())
            }
        }
        return .init(node)
    }
    
    public override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        let usr = usr(node.name)
        
        if logic.fixs.contains(usr) {
            return .init(node.addMainActor())
        }
        return .init(node)
    }
    
    public override func visit(_ node: InitializerDeclSyntax) -> DeclSyntax {
        let usr = usr(node.initKeyword)
        
        if logic.fixs.contains(usr) {
            return .init(node.addMainActor())
        }
        
        return .init(node)
    }
    
    public override func visit(_ node: SubscriptDeclSyntax) -> DeclSyntax {
        let usr = usr(node.subscriptKeyword)
        
        if logic.fixs.contains(usr) {
            return .init(node.addMainActor())
        }
        
        return .init(node)
    }
}

