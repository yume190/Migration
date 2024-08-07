//
//  File.swift
//
//
//  Created by Tangram Yume on 2024/8/5.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SKClient

public final class MainActorVisitor: SyntaxVisitor {
    let store: IndexStore
    let client: SKClient
    private var _properties: [Property] = []
    
    public init(store: IndexStore, client: SKClient) {
        self.store = store
        self.client = client
        super.init(viewMode: .sourceAccurate)
    }
    
    public override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        _properties += Property.parse(node)
        return .visitChildren
    }
    
    var properties: [Property] {
        return _properties.filter { property in
            if (property.decl.hasMainActor || property.decl.hasNonisolated) {
                return false
            }
            
            //            let kind = try? client(property.syntax).kind
            //            let isInstanceVariable = kind == .declVarInstance
            //            if !isInstanceVariable {
            //                return false
            //            }
            
            if (property.letVar == "var") {
                return true
            }
            let isSendable = store.isSendable(typeusr(property.syntax))
            return !isSendable
        }
    }
    
    public var usrs: [String] {
        return properties.map { property in
            usr(property.syntax)
        }
    }
}
