//
//  IndexDBTests.swift
//
//
//  Created by Tangram Yume on 2024/8/6.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SKClient
import PathKit
import Testing
@testable import MigrationKit

private let preFolder = "IndexDB"

fileprivate func cleanUp(folder: String) throws {
    let dir = fixture + preFolder + folder.removeSuffix("()")
    if dir.exists && dir.isDirectory {
        try dir.delete()
    }
}

@Suite("Search Index Store DB", .serialized)
struct IndexDBTests {
    
    @Test("Target Have 2 Extension")
    func testExtensions2() throws {
        try cleanUp(folder: #function)
        guard let tool = try prepare(preFolder: preFolder, folder: #function, code:
        """
        struct Target {}
        extension Target {}
        extension Target {}
        """) else {
            Issue.record()
            return
        }
        
        /// Target
        let extensions = tool.store.findExtension(tool.usr(7))
        try #require(extensions.count == 2)
    }
    
    @Test("Target Have 3 Extension")
    func testExtensions3() throws {
        try cleanUp(folder: #function)
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
        try #require(extensions.count == 3)
    }
    
    @Test("Find C2's comforms")
    func testComforms() throws {
        try cleanUp(folder: #function)
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
        try #require(comforms == ["C1", "P1", "P2"])
        try #require(allComforms == ["C1", "P1", "P2", "P3"])
    }
    
    @Test("Find Int's comforms")
    func testComformsInt() throws {
        try cleanUp(folder: #function)
        guard let tool = try prepare(preFolder: preFolder, folder: #function, code:
        """
        let a = 1
        """) else {
            return
        }
        
        /// a -> Int
        let allComforms = tool.store.allComforms(tool.typeusr(4)).map(\.symbol.name)
        try #require(allComforms.count == 14)
        try #require(Set(allComforms) == Set([
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
    
    @Test("Find Target's propery")
    func testProperty() throws {
        try cleanUp(folder: #function)
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
        try #require(tool.store.property(tool.usr(7)).map(\.symbol.name) == ["p1", "p2", "p3"])
        try #require(tool.store.allProperty(tool.usr(7)).map(\.symbol.name) == ["sp1", "sp2", "sp3", "p1", "p2", "p3"])
    }
    
    @Test("Find Parent Class")
    func testParent() throws {
        try cleanUp(folder: #function)
        guard let tool = try prepare(preFolder: preFolder, folder: #function, code:
        """
        class C1 {}
        class C2: C1 {}
        class C3: C2 {}
        """) else {
            return
        }
        
        /// C3
        try #require(tool.store.parent(tool.usr(34))?.symbol.name == "C2")
        try #require(tool.store.parents(tool.usr(34)).map(\.symbol.name) == ["C2", "C1"])
        try #require(tool.store.rootParent(tool.usr(34))?.symbol.name == "C1")
    }
    
    @Test("Find Child Class")
    func testHasChild() throws {
        try cleanUp(folder: #function)
        guard let tool = try prepare(preFolder: preFolder, folder: #function, code:
        """
        class C1 {}
        class C2: C1 {}
        class C3: C2 {}
        """) else {
            return
        }
        
        try #require(tool.store.hasChildClass(tool.usr(6)))   // C1
        try #require(tool.store.hasChildClass(tool.usr(18)))  // C2
        try #require(!tool.store.hasChildClass(tool.usr(34))) // C3
    }
    
    @Test("Check Class Is NSObject")
    func testNSObject() throws {
        try cleanUp(folder: #function)
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
        
        try #require(tool.store.isNSObject(tool.usr(20)))   // TestView
        try #require(tool.store.isNSObject(tool.usr(46)))   // TestViewController
        try #require(tool.store.isNSObject(tool.usr(92)))   // TestView2
        try #require(tool.store.isNSObject(tool.usr(121)))  // Object
        
        try #require(!tool.store.isNSObject(tool.usr(147))) // C1
        try #require(!tool.store.isNSObject(tool.usr(159))) // C2
        try #require(!tool.store.isNSObject(tool.usr(175))) // C3
    }
    
    @Test("Find target's caller")
    func testFindCaller() throws {
        try cleanUp(folder: #function)
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
        try #require(
            callers.compactMap(\.relations.first?.symbol.name) ==
            /// origin: ["test1()", "test2()", "getter:test3", "getter:test4", "setter:test4"]
            ["test1()", "test2()", "test3", "test4", "test4"]
        )
        try #require(tool.usr(20) == callers[0].relations.first?.symbol.usr) // test1()
        try #require(tool.usr(70) == callers[1].relations.first?.symbol.usr) // test2()
        // - usr : "s:4Temp2C1C5test3Sivg"
        // - name : "getter:test3"
        /// all [def|dyn|childOf|accOf|canon]
        try #require(tool.usr(116) == callers[2].relations.first?.symbol.usr) // test3
        
        /// def    146
        /// getter 167
        /// setter 210
        try #require(tool.usr(146) == callers[3].relations.first?.symbol.usr) // test4
        try #require(tool.usr(146) == callers[4].relations.first?.symbol.usr) // test4
    }
    
    @Test("Is Sendable")
    func testSendable() throws {
        try cleanUp(folder: #function)
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
        
        try #require(tool.store.isSendable(tool.typeusr(110)))  // target
        try #require(!tool.store.isSendable(tool.typeusr(125))) // target1
        try #require(tool.store.isSendable(tool.typeusr(153)))  // target2
    }
    
    func testMainActor() throws {
        try cleanUp(folder: #function)
        guard let tool = try prepare(preFolder: preFolder, folder: #function, code:
        """
        @MainActor
        var target1 = 1
        
        @MainActor
        func target2() {}
        """) else {
            return
        }
        
        try #require(tool.store.isMainActor(tool.usr(15)))  // target1
        try #require(tool.store.isMainActor(tool.usr(44)))  // target2
    }
    
    @Test("Temp")
    func testX() throws {
        try cleanUp(folder: #function)
        guard let tool = try prepare(preFolder: preFolder, folder: #function, code:
        """
        protocol P {
            func p()
        }

        class C1: P {
            func p() {}
            func c() {}
        }

        class C2: C1 {
            override func p() {}
            override func c() {}
        }
        @MainActor
        var target = 1
        """) else {
            return
        }
        
        let p1 = tool.usr(22)
        let p2 = tool.usr(52)
        let p3 = tool.usr(111)
        
        let c1 = tool.usr(68)
        let c2 = tool.usr(136)
//        p1    String    "s:4Temp1PP1pyyF"
//        p2    String    "s:4Temp2C1C1pyyF"
//        p3    String    "s:4Temp2C2C1pyyF"
//        c1    String    "s:4Temp2C1C1cyyF"
//        c2    String    "s:4Temp2C2C1cyyF"
        
        let o1 = tool.store.all(p2)
        let o2 = tool.store.allRelated(p2)
        print(o2)
        // o1
        // relation1 overrideOf s:4Temp2C1C1cyyF -> c1
        // relation2 childOf    `C2`
    }
}
