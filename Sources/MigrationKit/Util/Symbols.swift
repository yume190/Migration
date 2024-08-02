//
//  File.swift
//  
//
//  Created by Tangram Yume on 2024/8/2.
//

import SwiftSyntax

extension SyntaxProtocol {
    var withoutTrivia: Self {
        return self
            .with(\.leadingTrivia, .spaces(0))
            .with(\.trailingTrivia, .spaces(0))
    }
}

enum Symbols {
    static var sendable: InheritedTypeSyntax {   
        InheritedTypeSyntax(
            leadingTrivia: Trivia.space,
            type: TypeSyntax(IdentifierTypeSyntax(name: TokenSyntax.keyword(.Sendable))),
            trailingTrivia: Trivia.space
        )
    }
    
    static var `final`: DeclModifierSyntax {
        return DeclModifierSyntax(name: TokenSyntax.keyword(
            .final,
            leadingTrivia: .spaces(0),
            trailingTrivia: .space
        ))
    }
    
    static var mainActor: AttributeSyntax {
        return AttributeSyntax(attributeName: TypeSyntax(IdentifierTypeSyntax(name: TokenSyntax.identifier("@MainActor"))))
    }
}
