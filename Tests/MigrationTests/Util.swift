//
//  Util.swift
//  TypeFillTests
//
//  Created by Yume on 2021/10/21.
//

import Foundation
import SKClient
import SwiftCommand
import SKClient
import PathKit
import SwiftParser
import SwiftSyntax
import IndexStoreDB
@testable import MigrationKit

enum Commands {
    static let swiftc = Command.findInPath(withName: "swiftc")
    static let xcrun = Command.findInPath(withName: "xcrun")
}

struct Tool: SyntaxTool {
    let store: IndexStore
    let client: SKClient
}

let pwd = #file
let root = Path(pwd).parent().parent().parent()
let fixture = root + "TestFixture"

func cleanUp(_ preFolder: String, _ folder: String) throws {
    let dir = fixture + preFolder + folder.removeSuffix("()")
    if dir.exists && dir.isDirectory {
        try dir.delete()
    }
}

func prepare(preFolder: String, folder: String, code: String) throws -> Tool? {
    let dir = fixture + preFolder + folder.removeSuffix("()")
    let file = dir + "Temp.swift"
    let object = dir + "Temp.o"
    let indexDdDir = dir + "Index"
    try dir.mkpath()
    try file.write(code, encoding: .utf8)
    
    _ = try Commands.swiftc?.addArguments([
        file.string,
        "-o", object.string,
        "-index-store-path", indexDdDir.string,
    ]).waitForOutput()
    
    
    let client = try SKClient(path: file.string, sdk: .macosx)
    guard let store = IndexStore(path: indexDdDir.string) else {
        return nil
    }
    
    return Tool(store: store, client: client)
}


func addSendable(preFolder: String, folder: String, code: String) throws -> String? {
    guard let tool = try prepare(preFolder: preFolder, folder: folder, code: code) else {
        return nil
    }
    let source = Parser.parse(source: code)
    let rewriter = SendableRewriter(store: tool.store, client: tool.client)
    let modified = rewriter.visit(source)
    var result: String = ""
    modified.write(to: &result)
    return result
}


func addMainActor(preFolder: String, folder: String, code: String) throws -> String? {
    guard let tool = try prepare(preFolder: preFolder, folder: folder, code: code) else {
        return nil
    }
    let source = Parser.parse(source: code)
    let logic = MainActorLogic(store: tool.store, client: tool.client)
    let visitor = MainActorVisitor(store: tool.store, client: tool.client)
    visitor.walk(source)
    
    logic.append(usrs: visitor.usrs)
    logic.process()
    
    let rewriter = MainActorRewriter(store: tool.store, client: tool.client, logic: logic)
    let modified = rewriter.visit(source)
    var result: String = ""
    modified.write(to: &result)
    return result
}
