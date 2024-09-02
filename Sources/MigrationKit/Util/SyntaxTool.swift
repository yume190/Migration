//
//  File.swift
//  
//
//  Created by Tangram Yume on 2024/8/2.
//

import Foundation
import SwiftSyntax
import SKClient

protocol SyntaxTool {
    var store: IndexStore { get }
    var client: SKClient { get }
}

extension MainActorVisitor: SyntaxTool {}
extension MainActorRewriter: SyntaxTool {}
extension SendableRewriter: SyntaxTool {}
extension EnumParameterVisitor: SyntaxTool {}


extension SyntaxTool {
    func typeusr<Syntax: SyntaxProtocol>(_ syntax: Syntax) -> String {
        let usr = (try? client(syntax).typeusr) ?? ""
        if (usr.starts(with: "c:")) {
            return usr
        }

        /// suffix `D`: for debug
        let inputUsr = usr.removeSuffix("D")
        return USR(inputUsr)?.toIndexStoreDB().usr ?? ""
    }
    
    func typeusr(_ offset: Int) -> String {
        let usr = (try? client(offset).typeusr) ?? ""
        if (usr.starts(with: "c:")) {
            return usr
        }

        /// suffix `D`: for debug
        let inputUsr = usr.removeSuffix("D")
        return USR(inputUsr)?.toIndexStoreDB().usr ?? ""
    }
    
    func usr<Syntax: SyntaxProtocol>(_ syntax: Syntax) -> String {
        let usr = (try? client(syntax).usr) ?? ""
        if (usr.starts(with: "c:")) {
            return usr
        }

        /// suffix `D`: for debug
        let inputUsr = usr.removeSuffix("D")
        return USR(inputUsr)?.toIndexStoreDB().usr ?? ""
    }
    
    func usr(_ offset: Int) -> String {
        let usr = (try? client(offset).usr) ?? ""
        if (usr.starts(with: "c:")) {
            return usr
        }

        /// suffix `D`: for debug
        let inputUsr = usr.removeSuffix("D")
        return USR(inputUsr)?.toIndexStoreDB().usr ?? ""
    }
}
