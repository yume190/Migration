//
//  main.swift
//  Migration
//
//  Created by Yume on 2022/05/19.
//

import ArgumentParser
import Foundation
import MigrationKit
import Rainbow
import SKClient
import SwiftParser
import SourceKittenFramework
import Yams
import Derived
import PathKit

extension DerivedPath {
    /// Xcode 14 and later. Index.noindex
    public var indexStorePathXCode14: String? {
        let path = self.path() + "/Index.noindex"
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        return path
    }
}

@main
struct Command: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
        abstract: "A Tool to help you to migration to swift 6",
        discussion: """
        migration --module LeakDetectorDemo --file LeakDetectorDemo.xcworkspace
        """,
        version: "0.0.1"
    )
    
    @Flag(name: [.customLong("verbose", withSingleDash: false), .short], help: "verbose")
    var verbose: Bool = false
    
    @Option(name: [.customLong("sdk", withSingleDash: false)], help: "[\(SDK.all)]")
    var sdk: SDK = .iphonesimulator
    
    @Option(name: [.customLong("targetType", withSingleDash: false)], help: "[\(TargetType.all)]")
    var targetType: TargetType = .auto
    
    @Option(name: [.customLong("module", withSingleDash: false)], help: "Name of Swift module to document (can't be used with `--targetType singleFile`)")
    var moduleName = ""
    
    @Option(name: [.customLong("file", withSingleDash: false)], help: "xxx.xcworkspace/xxx.xcodeproj/xxx.swift")
    var file: String
    var path: String {
        URL(fileURLWithPath: file).path
    }
    
    var base: String {
        let _base = path.removeSuffix(file)
        
        if _base.isEmpty {
            return URL(fileURLWithPath: file).deletingLastPathComponent().path
        } else {
            return _base
        }
    }
    
    @Argument(help: "Arguments passed to `xcodebuild` or `swift build`")
    var arguments: [String] = []
    
    var indexDB: IndexStore? {
        switch targetType.detect(path) {
        case .xcodeproj: fallthrough
        case .xcworkspace:
            let derived = DerivedPath(path)
            guard let path = derived?.indexStorePath ?? derived?.indexStorePathXCode14 else {
                return nil
            }
            return IndexStore(path: path)
        case .spm:
            guard let path = DerivedPath.SPM(path.removeSuffix("/Package.swift"))?.indexStorePath else {
                return nil
            }
            return IndexStore(path: path)
        default:
            return nil
        }
    }
    
    private var module: Module? {
        let moduleName = self.moduleName.isEmpty ? nil : self.moduleName
        
        switch targetType.detect(path) {
        case .spm:
            //      Module(spmArguments: arguments, spmName: moduleName, inPath: "/Users/yume/git/Yume/Bazelize")
            return Module(spmArguments: arguments, spmName: moduleName, inPath: path.removeSuffix("/Package.swift"))
        case .singleFile:
            return nil
        case .xcodeproj:
            let newArgs: [String] = [
                "-project",
                path,
                "-scheme",
                self.moduleName,
            ]
            return Module(xcodeBuildArguments: arguments + newArgs, name: moduleName)
        case .xcworkspace:
            let newArgs: [String] = [
                "-workspace",
                path,
                "-scheme",
                self.moduleName,
            ]
            return Module(xcodeBuildArguments: arguments + newArgs, name: moduleName)
        case .auto:
            return nil
        }
    }
    
    mutating func run() async throws {
        if case .singleFile = targetType.detect(path) {
            return
        }
        
        guard let module = module else {
            print("Can't create module")
            return
        }
        guard let indexDB else {
            return
        }
        
        
        for file in module.sourceFiles {
            let client = try SKClient(path: file, arguments: module.compilerArguments)
            let path = Path(file)
            let code = try path.read(.utf8)
            let root = Parser.parse(source: code)
            let rewriter = SendableRewriter(store: indexDB, client: client)
            let modified = rewriter.visit(root)

            var result: String = ""
            modified.write(to: &result)

            let url: URL = URL(fileURLWithPath: file)
            let fileHandle = try FileHandle(forWritingTo: url)
            
            fileHandle.write(Data(result.utf8))
       }
        // let client = try SKClient(path: module.sourceFiles.first!, arguments: module.compilerArguments)
        // let logic = MainActorLogic(store: indexDB, client: client)
        // for file in module.sourceFiles {
        //     let client = try SKClient(path: file, arguments: module.compilerArguments)
        //     let path = Path(file)
        //     let code = try path.read(.utf8)
        //     let root = Parser.parse(source: code)
        //     let visitor = MainActorVisitor(store: indexDB, client: client)
        //     visitor.walk(root)

        //     logic.append(usrs: visitor.usrs)
        // }
        // logic.process()
        
        // print(logic.fixs)
        
        // for file in module.sourceFiles {
        //     let client = try SKClient(path: file, arguments: module.compilerArguments)
        //     let path = Path(file)
        //     let code = try path.read(.utf8)
        //     let root = Parser.parse(source: code)
        //     let rewriter = MainActorRewriter(store: indexDB, client: client, logic: logic)
        //     let modified = rewriter.visit(root)

        //     var result: String = ""
        //     modified.write(to: &result)

        //     let url: URL = URL(fileURLWithPath: file)
        //     let fileHandle = try FileHandle(forWritingTo: url)

        //     fileHandle.write(Data(result.utf8))
        // }
    }
}
