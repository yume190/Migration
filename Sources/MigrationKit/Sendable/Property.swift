//
//  File.swift
//  
//
//  Created by Tangram Yume on 2024/8/7.
//

import Foundation
import SwiftSyntax

struct Property {
    let letVar: String
    let decl: VariableDeclSyntax
    let syntax: SyntaxProtocol
    
    static func parse(_ node: VariableDeclSyntax) -> [Property] {
        let letVar = node.bindingSpecifier.text
        for binding in node.bindings {
            if let pattern = binding.pattern.as(IdentifierPatternSyntax.self) {
                return [Property(letVar: letVar, decl: node, syntax: pattern)]
            }
            if let pattern = binding.pattern.as(TuplePatternSyntax.self) {
                return pattern.elements.map { tuple in
                    Property(letVar: letVar, decl: node, syntax: tuple.pattern)
                }
            }
        }
        return []
    }
}
