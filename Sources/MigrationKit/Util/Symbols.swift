import SwiftSyntax

extension SyntaxProtocol {
    var withoutTrivia: Self {
        return self
            .with(\.leadingTrivia, [])
            .with(\.trailingTrivia, [])
    }
    var withNewline: Self {
        return self
            .with(\.leadingTrivia, .newline)
            .with(\.trailingTrivia, .newline)
    }
}

enum Symbols {
    /// Sendable
    static var sendable: InheritedTypeSyntax {
        InheritedTypeSyntax(
            type: TypeSyntax(IdentifierTypeSyntax(name: TokenSyntax.keyword(.Sendable)))
        )
    }
    
    /// final
    static var `final`: DeclModifierSyntax {
        return DeclModifierSyntax(name: TokenSyntax.keyword(.final))
    }
    
    /// open
    static var `open`: DeclModifierSyntax {
        return DeclModifierSyntax(name: TokenSyntax.keyword(.open))
    }
    
    /// nonisolated(unsafe)
    static var nonisolated: DeclModifierSyntax {
        return DeclModifierSyntax(
            name: TokenSyntax.keyword(.nonisolated)
        )
    }
    
    /// @MainActor
    static var mainActor: AttributeSyntax {
        return AttributeSyntax(
            attributeName: TypeSyntax(IdentifierTypeSyntax(name: TokenSyntax.identifier("MainActor")))
        )
    }
    
    /// @globalActor
    static var globalActor: AttributeSyntax {
        return AttributeSyntax(
            attributeName: TypeSyntax(IdentifierTypeSyntax(name: TokenSyntax.identifier("globalActor")))
        )
    }
}
