//
//  File.swift
//  Migration
//
//  Created by Tangram Yume on 2024/8/1.
//

import Foundation
import SwiftSyntax
import SKClient
import SwiftSyntaxBuilder

public final class SendableRewriter: SyntaxRewriter {
    let store: IndexStore
    let client: SKClient
    public init(store: IndexStore, client: SKClient) {
        self.store = store
        self.client = client
    }
      
    override public func visit(_ node: ClassDeclSyntax) -> DeclSyntax {
        return .init(handleExplicitSendable(node))
    }
    
    override public func visit(_ node: StructDeclSyntax) -> DeclSyntax {
        return .init(handleExplicitSendable(node))
    }
    
    override public func visit(_ node: EnumDeclSyntax) -> DeclSyntax {
        return .init(handleExplicitSendable(node))
    }
}

//Patch Root Package.swift
//

//```swift
//Patch Root Package.swift
//
//patch import Foudation if need
//
//patch let package -> var package
//
//patch func patch
//
//dependencies path
//
//macro
/// let package -> var pacakge
//#if os(macOS)

//import SwiftSyntax
//
//extension SyntaxProtocol {
//    var withoutTrivia: Self {
//        return self
//            .with(\.leadingTrivia, [])
//            .with(\.trailingTrivia, [])
//    }
//    var withNewline: Self {
//        return self
//            .with(\.leadingTrivia, .newline)
//            .with(\.trailingTrivia, .newline)
//    }
//}
public final class ScipioRewriter: SyntaxRewriter {
//    private func dependencies(_ package: ResolvedPackage) -> String {
//        return package.dependencies.map { dep in
//            """
//            .package(path: "../\(dep.manifest.displayName)"),
//            """
//        }.joined(separator: "\n")
//
//    }
//    module.recursiveTargetDependencies().filter { module in
//        module.type == .macro
//    }

    let foundationSyntax: DeclSyntax = """
    import Foundation
    """
    
    let patchFunctionCallSyntax: DeclSyntax = """
    patchToUsePrebuiltXcframeworks(in: &package)
    """
    //    if ProcessInfo.processInfo.environment["USE_PREBUILT"] != nil {
//    }
//    #endif
    
    let patchMacro = #"""
        func patchMacro(_ target: Target, _ macro: String) {
            var settings = target.swiftSettings ?? []
            settings.append(.unsafeFlags([
                "-load-plugin-executable", "XCFrameworks/\(macro)#\(macro)"
            ]))
            target.swiftSettings = settings
        }
    """#
    
    var patchFunctionSyntax: DeclSyntax {
        """
        private func patchToUsePrebuiltXcframeworks(in package: inout Package) {
        \(raw: patchMacro)
        
            package.dependencies = [
                // .package(name: "Swallow", path: "path/to/Swallow"),
                // or
                // .package(path: "path/to/Swallow"),
            ]
            // patch targets which depend on `MacroTarget`
            // "-load-plugin-executable", "XCFrameworks/Macro#Macro"
            for target in package.targets {
                if target.name == "abc" {
                    patchMacro(target, "a")
                    contiunue
                }
                //...
            }
        }
        """
    }
    
    let isNeedPatchFoundation: Bool
    let isNeedPatchFunctionCall: Bool
    let isNeedPatchFunction: Bool
    
    init(isNeedPatchFoundation: Bool, isNeedPatch1: Bool, isNeedPatch2: Bool) {
        self.isNeedPatchFoundation = isNeedPatchFoundation
        self.isNeedPatchFunctionCall = isNeedPatch1
        self.isNeedPatchFunction = isNeedPatch2
    }
    
    override public func visit(_ node: CodeBlockItemListSyntax) -> CodeBlockItemListSyntax {
        var list = node.map { $0 }
        
        if isNeedPatchFoundation {
            if let index = list.firstIndex(where: { syntax in
                return syntax.item.is(ImportDeclSyntax.self)
            }) {
                let syntax = CodeBlockItemSyntax(item: .decl(foundationSyntax.withNewline))
                list.insert(syntax, at: index + 1)
            }
        }
        
        if isNeedPatchFunctionCall {
            let syntax = CodeBlockItemSyntax(item: .decl(patchFunctionCallSyntax.withNewline))
            list.append(syntax)
        }
        
        if isNeedPatchFunction {
            let syntax = CodeBlockItemSyntax(item: .decl(patchFunctionSyntax.withNewline))
            list.append(syntax)
        }
        
        return CodeBlockItemListSyntax {
            list.map(visit)
        }
    }
    
    /// let package -> var pacakge
    override public func visit(_ node: VariableDeclSyntax) -> DeclSyntax {
        if let pattern = node.bindings.first?.pattern.as(IdentifierPatternSyntax.self) {
            if pattern.identifier.text == "package" {
                let bindingSpecifier: TokenSyntax = .keyword(.var)
                    .with(\.leadingTrivia, node.bindingSpecifier.leadingTrivia)
                    .with(\.trailingTrivia, node.bindingSpecifier.trailingTrivia)
                
                let newNode = node
                    .with(\.bindingSpecifier, bindingSpecifier)
                    
                return .init(newNode)
            }
        }
        return .init(node)
    }
    
    public override func visit(_ node: FunctionDeclSyntax) -> DeclSyntax {
        if node.name.text == "patch" {
            return .init(patchFunctionCallSyntax)
        }
        return .init(node)
    }
        
}

final class FoundationVisitor: SyntaxVisitor {
    var hasFoundation = false
    var hasPatchCall = false
    var hasPatchFunction = false
    override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        if hasFoundation { return .skipChildren }
        
        hasFoundation = !node.path.filter { pathComponent in
            pathComponent.name.text == "Foundation"
        }.isEmpty
        
        return .skipChildren
    }
    
    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        if hasPatchCall { return .skipChildren }
        
        if let expr = node.calledExpression.as(DeclReferenceExprSyntax.self) {
            hasPatchCall = expr.baseName.text == "patchToUsePrebuiltXcframeworks"
        }
        
        return .skipChildren
    }
    
    // MARK: - skip non global start
    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        if hasPatchFunction { return .skipChildren }
            
        hasPatchFunction = node.name.text == "patchToUsePrebuiltXcframeworks"
        
        return .skipChildren
    }
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }
    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }
    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }
    override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }
    // MARK: skip non global end -
}
