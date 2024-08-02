//
//  File.swift
//  Migration
//
//  Created by Tangram Yume on 2024/8/1.
//

import Foundation
import SwiftSyntax
import SKClient

public final class MigrationRewriter: SyntaxRewriter {
    let store: IndexStore
    let client: SKClient
    public init(store: IndexStore, client: SKClient) {
        self.store = store
        self.client = client
    }
      
    override public func visit(_ node: ClassDeclSyntax) -> DeclSyntax {
        return .init(handleExplicitSendable(node))
    }
    
    override public func visit(_ node: StructDeclSyntax) -> DeclSyntax {
        return .init(handleExplicitSendable(node))
    }
    
}
