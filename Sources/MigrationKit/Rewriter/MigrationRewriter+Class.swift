//
//  File.swift
//  Migration
//
//  Created by Tangram Yume on 2024/8/1.
//

import Foundation
import SwiftSyntax

extension MigrationRewriter {
    /// AttributeList: [@MainActor]
    /// ModifierList: [public final]
    func handle(_ node: ClassDeclSyntax) -> ClassDeclSyntax {
        /// is Sendable
        return node
    }
}
