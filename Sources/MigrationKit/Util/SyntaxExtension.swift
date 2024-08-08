//
//  File.swift
//  
//
//  Created by Tangram Yume on 2024/8/7.
//

import Foundation
import SwiftSyntax

protocol SyntaxExtension: SyntaxProtocol {
    var attributes: AttributeListSyntax { get set }
    var modifiers: DeclModifierListSyntax { get set }
}

protocol StructureSyntaxExtension: SyntaxExtension {
    var inheritanceClause: InheritanceClauseSyntax? { get set }
}


extension SyntaxExtension {
    func addMainActor() -> Self {
        let attributes = AttributeListSyntax {
            self.attributes
            if !hasMainActor {
                Symbols.mainActor
                    .with(\.leadingTrivia, .space)
                    .with(\.trailingTrivia, [])
            }
        }
            .with(\.leadingTrivia, leadingTrivia)
            .with(\.trailingTrivia, [])
        return self
            .with(\.leadingTrivia, .space)
            .with(\.attributes, attributes)
    }
    
    func addFinal() -> Self {
        let modifiers = DeclModifierListSyntax {
            self.modifiers
            if !hasFinal {
                Symbols.final
                    .with(\.leadingTrivia, .space)
                    .with(\.trailingTrivia, [])
            }
        }
            .with(\.leadingTrivia, leadingTrivia)
            .with(\.trailingTrivia, [])
        return self
            .with(\.leadingTrivia, .space)
            .with(\.modifiers, modifiers)
    }
}

extension StructureSyntaxExtension {
    func addSendable() -> Self {
        let inheritance = InheritanceClauseSyntax {
            if let origin = self.inheritanceClause {
                origin.inheritedTypes
                    .with(\.leadingTrivia, .space)
                    .with(\.trailingTrivia, [])
            }
            Symbols.sendable
                .with(\.leadingTrivia, .space)
                .with(\.trailingTrivia, .space)
        }
        return self
            .with(\.inheritanceClause, inheritance)
    }
}


/// AttributeList: [@MainActor]
/// ModifierList: [public final]
extension SyntaxExtension {
    /// @MainActor
    var hasMainActor: Bool {
        return attributes.contains { attr in
            attr.withoutTrivia.description == Symbols.mainActor.description
        }
    }
    
    /// final
    var hasFinal: Bool {
        return modifiers.contains { modifier in
            modifier.withoutTrivia.description == Symbols.final.description
        }
    }
    
    /// open
    var hasOpen: Bool {
        return modifiers.contains { modifier in
            modifier.withoutTrivia.description == Symbols.open.description
        }
    }
}

extension SyntaxExtension where Self == VariableDeclSyntax {
    /// nonisolated(unsafe)
    var hasNonisolated: Bool {
        return modifiers.contains { syntax in
            syntax.withoutTrivia.name.text == Symbols.nonisolated.name.text
        } && self.unexpectedBetweenModifiersAndBindingSpecifier?.withoutTrivia.description == "(unsafe)"
    }
}

extension VariableDeclSyntax: SyntaxExtension {}
extension FunctionDeclSyntax: SyntaxExtension {}
extension InitializerDeclSyntax: SyntaxExtension {}
extension SubscriptDeclSyntax: SyntaxExtension {}


extension StructDeclSyntax: StructureSyntaxExtension {}
extension ClassDeclSyntax: StructureSyntaxExtension {}
