//
//  File.swift
//  
//
//  Created by Tangram Yume on 2024/8/7.
//

import Foundation
import XCTest
import SwiftSyntax
import SwiftSyntaxBuilder
import SKClient
import PathKit
@testable import MigrationKit

private let preFolder = "Sendable"

final class SendableTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        let dir = fixture + preFolder
        try? dir.delete()
    }
    
    final func testSimple() throws {
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        struct Target {
            let a: Int
        }
        """) else {
            return
        }
        
        let expectCode = """
        struct Target : Sendable {
            let a: Int
        }
        """
        
        XCTAssertEqual(modifiedCode, expectCode)
    }
    
    final func testWithNSObjectProperty() throws {
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        import Foundation
        struct Target {
            let a: Int
            let b: NSObject
        }
        """) else {
            return
        }
        
        let expectCode = """
        import Foundation
        struct Target {
            let a: Int
            let b: NSObject
        }
        """
        
        XCTAssertEqual(modifiedCode, expectCode)
    }
    
    final func testWithException() throws {
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        struct Target {
            let a: Int
            @MainActor
            var b: Int
            nonisolated(unsafe)
            var c: Int
        }
        """) else {
            return
        }
        
        let expectCode = """
        struct Target : Sendable {
            let a: Int
            @MainActor
            var b: Int
            nonisolated(unsafe)
            var c: Int
        }
        """
        
        XCTAssertEqual(modifiedCode, expectCode)
    }
    
    final func testExistSendable() throws {
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        struct Target : Sendable {
            let a: Int
        }
        """) else {
            return
        }
        
        let expectCode = """
        struct Target : Sendable {
            let a: Int
        }
        """
        
        XCTAssertEqual(modifiedCode, expectCode)
    }
    
    final func testWithMultiInheritance() throws {
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        protocol P1 {}
        protocol P2 {}
        struct Target : P1, P2 {
            let a: Int
        }
        """) else {
            return
        }
        
        let expectCode = """
        protocol P1 {}
        protocol P2 {}
        struct Target : P1, P2, Sendable {
            let a: Int
        }
        """
        
        XCTAssertEqual(modifiedCode, expectCode)
    }
    
    final func testStep1() throws {
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        struct Target1 {
            let a: Int
        }
        struct Target2 {
            let a: Target1
        }
        struct Target3 {
            let a: Target2
        }
        """) else {
            return
        }
        
        let expectCode = """
        struct Target1 : Sendable {
            let a: Int
        }
        struct Target2 {
            let a: Target1
        }
        struct Target3 {
            let a: Target2
        }
        """
        
        XCTAssertEqual(modifiedCode, expectCode)
    }
    
    final func testStep2() throws {
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        struct Target1 : Sendable {
            let a: Int
        }
        struct Target2 {
            let a: Target1
        }
        struct Target3 {
            let a: Target2
        }
        """) else {
            return
        }
        
        let expectCode = """
        struct Target1 : Sendable {
            let a: Int
        }
        struct Target2 : Sendable {
            let a: Target1
        }
        struct Target3 {
            let a: Target2
        }
        """
        
        XCTAssertEqual(modifiedCode, expectCode)
    }
    
    final func testStep3() throws {
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        struct Target1 : Sendable {
            let a: Int
        }
        struct Target2 : Sendable {
            let a: Target1
        }
        struct Target3 {
            let a: Target2
        }
        """) else {
            return
        }
        
        let expectCode = """
        struct Target1 : Sendable {
            let a: Int
        }
        struct Target2 : Sendable {
            let a: Target1
        }
        struct Target3 : Sendable {
            let a: Target2
        }
        """
        
        XCTAssertEqual(modifiedCode, expectCode)
    }
    
    class Target {
        let a: Int
        init(a: Int) {
            self.a = a
        }
    }
    
    final func testClass() throws {
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        class Target {
            let a: Int
            init(a: Int) {
                self.a = a
            }
        }
        """) else {
            return
        }
        
        let expectCode = """
        final class Target : Sendable {
            let a: Int
            init(a: Int) {
                self.a = a
            }
        }
        """
        
        XCTAssertEqual(modifiedCode, expectCode)
    }
    
    final func testClassNSObject() throws {
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        import Foundation
        class C1: NSObject {}
        class C2: C1 {}
        class C3: C2 {}
        """) else {
            return
        }
        
        let expectCode = """
        import Foundation
        class C1: NSObject {}
        class C2: C1 {}
        class C3: C2 {}
        """
        
        XCTAssertEqual(modifiedCode, expectCode)
    }
    
    final func testClassOnlyNoChildClass() throws {
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        class C1 {}
        class C2: C1 {}
        class C3: C2 {}
        """) else {
            return
        }
        
        let expectCode = """
        class C1 {}
        class C2: C1 {}
        final class C3: C2, Sendable {}
        """
        
        XCTAssertEqual(modifiedCode, expectCode)
    }
}
