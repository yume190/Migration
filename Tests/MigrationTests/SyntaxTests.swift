//
//  SyntaxTests.swift
//  
//
//  Created by Tangram Yume on 2024/8/6.
//

import Foundation
import Testing
import SwiftSyntax
import SwiftSyntaxBuilder
@testable import MigrationKit

@Suite("Syntax Tests")
struct SyntaxTests {}
    
    
// MARK: - globalActor
extension SyntaxTests {
    @Test("Is globalActor")
    func globalActor() throws {
        let syntax: DeclSyntax = """
        @globalActor actor TestActor {}
        """
        guard let decl = syntax.as(ActorDeclSyntax.self) else {
            Issue.record()
            return
        }
        try #require(decl.isGlobalActor)
    }
    
    @Test("globalActor(MainActor) class")
    func classGlobalActorMain() throws {
        let syntax: DeclSyntax = """
        @MainActor
        class Target {}
        """
        guard let decl = syntax.as(ClassDeclSyntax.self) else {
            Issue.record()
            return
        }
        try #require(decl.hasGlobalActor([]))
    }
    
    @Test("globalActor var")
    func varGlobalActor() throws {
        let syntax: DeclSyntax = """
        @TestActor var a = 1
        """
        guard let decl = syntax.as(VariableDeclSyntax.self) else {
            Issue.record()
            return
        }
        try #require(decl.hasGlobalActor(["@TestActor"]))
    }
    
    @Test("globalActor func")
    func functionGlobalActor() throws {
        let syntax: DeclSyntax = """
        @TestActor func target() {}
        """
        guard let decl = syntax.as(FunctionDeclSyntax.self) else {
            Issue.record()
            return
        }
        try #require(decl.hasGlobalActor(["@TestActor"]))
    }
    
    @Test("globalActor struct")
    func structGlobalActor() throws {
        let syntax: DeclSyntax = """
        @TestActor
        struct Target {}
        """
        guard let decl = syntax.as(StructDeclSyntax.self) else {
            Issue.record()
            return
        }
        try #require(decl.hasGlobalActor(["@TestActor"]))
    }
    
    @Test("globalActor class")
    func classGlobalActor() throws {
        let syntax: DeclSyntax = """
        @TestActor
        class Target {}
        """
        guard let decl = syntax.as(ClassDeclSyntax.self) else {
            Issue.record()
            return
        }
        try #require(decl.hasGlobalActor(["@TestActor"]))
    }
}

// MARK: - class
extension SyntaxTests {
    @Test("open class")
    func testHasOpen() throws {
        let syntax: DeclSyntax = """
        open class C {}
        """
        guard let decl = syntax.as(ClassDeclSyntax.self) else {
            Issue.record()
            return
        }
        
        try #require(decl.hasOpen)
    }
    
    @Test("final class")
    func testHasFinal() throws {
        let syntax: DeclSyntax = """
        final class C {}
        """
        guard let decl = syntax.as(ClassDeclSyntax.self) else {
            Issue.record()
            return
        }
        
        try #require(decl.hasFinal)
    }
}

// MARK: - @MainActor
extension SyntaxTests {
    @Test("@MainActor class")
    func testHasMainActor() throws {
        let syntax: DeclSyntax = """
        @MainActor class C {}
        """
        guard let decl = syntax.as(ClassDeclSyntax.self) else {
            Issue.record()
            return
        }
        
        try #require(decl.hasMainActor)
    }
    
    @Test("@MainActor function")
    func testHasMainActorFunction() throws {
        let syntax: DeclSyntax = """
        @MainActor
        func target() {}
        """
        guard let decl = syntax.as(FunctionDeclSyntax.self) else {
            Issue.record()
            return
        }
        
        try #require(decl.hasMainActor)
    }
    
    @Test("@MainActor var")
    func testHasMainActorVar() throws {
        let syntax: DeclSyntax = """
        @MainActor var a = 1
        """
        guard let decl = syntax.as(VariableDeclSyntax.self) else {
            Issue.record()
            return
        }
        
        try #require(decl.hasMainActor)
    }
    
    @Test("@MainActor let")
    func testHasMainActorlet() throws {
        let syntax: DeclSyntax = """
        @MainActor let a = 1
        """
        guard let decl = syntax.as(VariableDeclSyntax.self) else {
            Issue.record()
            return
        }
        
        try #require(decl.hasMainActor)
    }
}

// MARK: - nonisolated(unsafe)
extension SyntaxTests {
    @Test("nonisolated(unsafe) var")
    func testHasNonisolated() throws {
        let syntax: DeclSyntax = """
        nonisolated(unsafe)
        var a = 1
        """
        guard let decl = syntax.as(VariableDeclSyntax.self) else {
            Issue.record()
            return
        }
        
        try #require(decl.hasNonisolated)
    }
}
