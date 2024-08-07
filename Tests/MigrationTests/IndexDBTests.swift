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
import SKClient
import PathKit
@testable import MigrationKit

private let preFolder = "IndexDB"

final class IndexDBTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        
        let dir = fixture + preFolder
        try? dir.delete()
    }
    
    final func testExtensions2() throws {
        guard let tool = try prepare(preFolder: preFolder, folder: #function, code:
        """
        struct Target {}
        extension Target {}
        extension Target {}
        """) else {
            return
        }
        
        /// Target
        let extensions = tool.store.findExtension(tool.usr(7))
        XCTAssertEqual(extensions.count, 2)
    }
    
    final func testExtensions3() throws {
        guard let tool = try prepare(preFolder: preFolder, folder: #function, code:
        """
        struct Target {}
        extension Target {}
        extension Target {}
        extension Target {}
        """) else {
            return
        }
        
        /// Target
        let extensions = tool.store.findExtension(tool.usr(7))
        XCTAssertEqual(extensions.count, 3)
    }
    
    final func testComforms() throws {
        guard let tool = try prepare(preFolder: preFolder, folder: #function, code:
        """
        protocol P1 {}
        protocol P2 {}
        protocol P3 {}
        class C1 {}
        class C2: C1, P1, P2 {}
        extension C2: P3 {}
        """) else {
            return
        }
        
        /// C2
        let comforms = tool.store.comforms(tool.usr(63)).map(\.symbol.name)
        let allComforms = tool.store.allComforms(tool.usr(63)).map(\.symbol.name)
        XCTAssertEqual(comforms, ["C1", "P1", "P2"])
        XCTAssertEqual(allComforms, ["C1", "P1", "P2", "P3"])
    }
    
    final func testComformsInt() throws {
        guard let tool = try prepare(preFolder: preFolder, folder: #function, code:
        """
        let a = 1
        """) else {
            return
        }
        
        /// a -> Int
        let allComforms = tool.store.allComforms(tool.typeusr(4)).map(\.symbol.name)
        XCTAssertEqual(allComforms.count, 14)
        XCTAssertEqual(Set(allComforms), Set([
            "FixedWidthInteger",
            "SignedInteger",
            "_ExpressibleByBuiltinIntegerLiteral",
            "CVarArg",
            "Hashable",
            "_HasCustomAnyHashableRepresentation",
            "Sendable",
            "CodingKeyRepresentable",
            "SIMDScalar",
            "Int",
            "Sendable",
            "CustomReflectable",
            "_CustomPlaygroundQuickLookable",
            "MirrorPath",
        ]))
    }
    
    final func testProperty() throws {
        guard let tool = try prepare(preFolder: preFolder, folder: #function, code:
        """
        struct Target {
            static let sp1 = 1
            static var sp2 = 1
            static var sp3: Int { 1 }
            let p1 = 1
            var p2 = 1
            var p3: Int { 1 }
        }
        """) else {
            return
        }
        
        /// Target
        XCTAssertEqual(tool.store.property(tool.usr(7)).map(\.symbol.name), ["p1", "p2", "p3"])
        XCTAssertEqual(tool.store.allProperty(tool.usr(7)).map(\.symbol.name), ["sp1", "sp2", "sp3", "p1", "p2", "p3"])
    }
    
    final func testParent() throws {
        guard let tool = try prepare(preFolder: preFolder, folder: #function, code:
        """
        class C1 {}
        class C2: C1 {}
        class C3: C2 {}
        """) else {
            return
        }
        
        /// C3
        XCTAssertEqual(tool.store.parent(tool.usr(34))?.symbol.name, "C2")
        XCTAssertEqual(tool.store.parents(tool.usr(34)).map(\.symbol.name), ["C2", "C1"])
        XCTAssertEqual(tool.store.rootParent(tool.usr(34))?.symbol.name, "C1")
    }
    
    final func testHasChild() throws {
        guard let tool = try prepare(preFolder: preFolder, folder: #function, code:
        """
        class C1 {}
        class C2: C1 {}
        class C3: C2 {}
        """) else {
            return
        }
        
        XCTAssertTrue(tool.store.hasChildClass(tool.usr(6)))   // C1
        XCTAssertTrue(tool.store.hasChildClass(tool.usr(18)))  // C2
        XCTAssertFalse(tool.store.hasChildClass(tool.usr(34))) // C3
    }
    
    final func testNSObject() throws {
        guard let tool = try prepare(preFolder: preFolder, folder: #function, code:
        """
        import AppKit
        class TestView: NSView {}
        class TestViewController: NSViewController {}
        class TestView2: TestView {}
        class Object: NSObject {}
        class C1 {}
        class C2: C1 {}
        class C3: C2 {}
        """) else {
            return
        }
        
        XCTAssertTrue(tool.store.isNSObject(tool.usr(20)))   // TestView
        XCTAssertTrue(tool.store.isNSObject(tool.usr(46)))   // TestViewController
        XCTAssertTrue(tool.store.isNSObject(tool.usr(92)))   // TestView2
        XCTAssertTrue(tool.store.isNSObject(tool.usr(121)))  // Object
        
        XCTAssertFalse(tool.store.isNSObject(tool.usr(147))) // C1
        XCTAssertFalse(tool.store.isNSObject(tool.usr(159))) // C2
        XCTAssertFalse(tool.store.isNSObject(tool.usr(175))) // C3
    }
    
    func testFindCaller() throws {
        guard let tool = try prepare(preFolder: preFolder, folder: #function, code:
        """
        let target = 1
        func test1() {
            print(target)
        }
        class C1 {
            func test2() {
                print(target)
            }
            var test3: Int { target }
            var test4: Int {
                get {
                    target
                }
                set {
                    print(target)
                }
            }
        }
        """) else {
            return
        }
        
        /// target
        let callers = tool.store.findCaller(tool.usr(4))
        XCTAssertEqual(
            callers.compactMap(\.relations.first?.symbol.name),
            /// origin: ["test1()", "test2()", "getter:test3", "getter:test4", "setter:test4"]
            ["test1()", "test2()", "test3", "test4", "test4"]
        )
        XCTAssertEqual(tool.usr(20), callers[0].relations.first?.symbol.usr) // test1()
        XCTAssertEqual(tool.usr(70), callers[1].relations.first?.symbol.usr) // test2()
        // - usr : "s:4Temp2C1C5test3Sivg"
        // - name : "getter:test3"
        /// all [def|dyn|childOf|accOf|canon]
        XCTAssertEqual(tool.usr(116), callers[2].relations.first?.symbol.usr) // test3
        
        /// def    146
        /// getter 167
        /// setter 210
        XCTAssertEqual(tool.usr(146), callers[3].relations.first?.symbol.usr) // test4
        XCTAssertEqual(tool.usr(146), callers[4].relations.first?.symbol.usr) // test4
    }
    
    func testSendable() throws {
        guard let tool = try prepare(preFolder: preFolder, folder: #function, code:
        """
        public struct Target1 {
            public let a: Int
        }
        public struct Target2: Sendable {
            public let a: Int
        }
        let target = 1
        let target1 = Target1(a: 1)
        let target2 = Target2(a: 1)
        """) else {
            return
        }
        
        XCTAssertTrue(tool.store.isSendable(tool.typeusr(110)))  // target
        XCTAssertFalse(tool.store.isSendable(tool.typeusr(125))) // target1
        XCTAssertTrue(tool.store.isSendable(tool.typeusr(153)))  // target2
    }
    
    func testMainActor() throws {
        guard let tool = try prepare(preFolder: preFolder, folder: #function, code:
        """
        @MainActor
        var target1 = 1
        
        @MainActor
        func target2() {}
        """) else {
            return
        }
        
        XCTAssertTrue(tool.store.isMainActor(tool.usr(15)))  // target1
        XCTAssertTrue(tool.store.isMainActor(tool.usr(44)))  // target2
    }
}
