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

protocol SyntaxExtension {
    var attributes: AttributeListSyntax { get }
    var modifiers: DeclModifierListSyntax { get }
}

/// AttributeList: [@MainActor]
/// ModifierList: [public final]
extension SyntaxExtension {
    var hasMainActor: Bool {
        return attributes.contains { attr in
            attr.withoutTrivia.description == Symbols.mainActor.description
        }
    }
    
    var hasFinal: Bool {
        return modifiers.contains(Symbols.final)
    }
    
    var hasOpen: Bool {
        return modifiers.contains(Symbols.open)
    }
}

extension SyntaxExtension where Self == VariableDeclSyntax {
    var hasNonisolated: Bool {
        return modifiers.contains { syntax in
            syntax.withoutTrivia.name.text == Symbols.nonisolated.name.text
        } && self.unexpectedBetweenModifiersAndBindingSpecifier?.withoutTrivia.description == "(unsafe)"
    }
}


extension VariableDeclSyntax: SyntaxExtension {}
extension StructDeclSyntax: SyntaxExtension {}
extension ClassDeclSyntax: SyntaxExtension {}


enum Symbols {
    /// Sendable
    static var sendable: InheritedTypeSyntax {
        InheritedTypeSyntax(
            leadingTrivia: Trivia.space,
            type: TypeSyntax(IdentifierTypeSyntax(name: TokenSyntax.keyword(.Sendable))),
            trailingTrivia: Trivia.space
        )
    }
    
    /// final
    static var `final`: DeclModifierSyntax {
        return DeclModifierSyntax(name: TokenSyntax.keyword(
            .final,
            leadingTrivia: .spaces(0),
            trailingTrivia: .space
        ))
    }
    
    /// open
    static var `open`: DeclModifierSyntax {
        return DeclModifierSyntax(name: TokenSyntax.keyword(
            .open,
            leadingTrivia: .spaces(0),
            trailingTrivia: .space
        ))
    }
    
    /// nonisolated(unsafe)
    static var nonisolated: DeclModifierSyntax {
        return DeclModifierSyntax(
            name: TokenSyntax.keyword(.nonisolated)
//            ,
//            detail: DeclModifierDetailSyntax(detail: TokenSyntax.keyword(.unsafe))
        )
    }
    
    /// @MainActor
    static var mainActor: AttributeSyntax {
        return AttributeSyntax(attributeName: TypeSyntax(IdentifierTypeSyntax(name: TokenSyntax.identifier("MainActor"))))
    }
}
