//
//  File.swift
//  
//
//  Created by Tangram Yume on 2024/8/6.
//

import Foundation
import XCTest
import SwiftSyntax
import SwiftSyntaxBuilder
@testable import MigrationKit

final class SyntaxTests: XCTestCase {
    final func testHasOpen() {
        let syntax: DeclSyntax = """
        open class C {}
        """
        guard let decl = syntax.as(ClassDeclSyntax.self) else {
            XCTExpectFailure("")
            return
        }
        
        XCTAssertTrue(decl.hasOpen)
    }
    
    final func testHasFinal() {
        let syntax: DeclSyntax = """
        final class C {}
        """
        guard let decl = syntax.as(ClassDeclSyntax.self) else {
            XCTExpectFailure("")
            return
        }
        
        XCTAssertTrue(decl.hasFinal)
    }
    
    final func testHasMainActor() {
        let syntax: DeclSyntax = """
        @MainActor class C {}
        """
        guard let decl = syntax.as(ClassDeclSyntax.self) else {
            XCTExpectFailure("")
            return
        }
        
        XCTAssertTrue(decl.hasMainActor)
    }
    
    final func testHasNonisolated() {
        let syntax: DeclSyntax = """
        nonisolated(unsafe)
        var a = 1
        """
        guard let decl = syntax.as(VariableDeclSyntax.self) else {
            XCTExpectFailure("")
            return
        }
        
        XCTAssertTrue(decl.hasNonisolated)
    }
}
