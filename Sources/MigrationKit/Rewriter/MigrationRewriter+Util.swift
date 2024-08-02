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
    func typeusr<Syntax: SyntaxProtocol>(_ syntax: Syntax) -> String {
        let usr = (try? client(syntax).typeusr) ?? ""
        if (usr.starts(with: "c:")) {
            return usr
        }
#if DEBUG
        let inputUsr = usr.removeSuffix("D")
#else
        let inputUsr = usr
#endif
        return USR(inputUsr)?.toIndexStoreDB().usr ?? ""
    }
    
    func usr<Syntax: SyntaxProtocol>(_ syntax: Syntax) -> String {
        let usr = (try? client(syntax).usr) ?? ""
        if (usr.starts(with: "c:")) {
            return usr
        }
#if DEBUG
        let inputUsr = usr.removeSuffix("D")
#else
        let inputUsr = usr
#endif
        return USR(inputUsr)?.toIndexStoreDB().usr ?? ""
    }
}
