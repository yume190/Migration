//
//  File.swift
//  
//
//  Created by Tangram Yume on 2024/8/2.
//

import Foundation
import SwiftSyntax
import SKClient

extension MigrationRewriter {
    func typeusr<Syntax: SyntaxProtocol>(_ syntax: Syntax) throws -> String {
#if DEBUG
        return try USR(client(syntax).typeusr?.removeSuffix("D"))?.toIndexStoreDB().usr ?? ""
#else
        return try USR(client(syntax).typeusr)?.toIndexStoreDB().usr ?? ""
#endif
    }
    
    func usr<Syntax: SyntaxProtocol>(_ syntax: Syntax) throws -> String {
#if DEBUG
        return try USR(client(syntax).usr?.removeSuffix("D"))?.toIndexStoreDB().usr ?? ""
#else
        return try USR(client(syntax).usr)?.toIndexStoreDB().usr ?? ""
#endif
    }
}
