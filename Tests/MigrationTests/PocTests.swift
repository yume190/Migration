import Foundation
import XCTest
import SwiftSyntax
import SwiftSyntaxBuilder
import SKClient
import IndexStoreDB
import PathKit
@testable import MigrationKit

private let preFolder = "Poc"

final class PocTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        
        let dir = fixture + preFolder
        try? dir.delete()
    }
}

extension PocTests {
    final func testGeneric() throws {
        guard let tool = try prepare(preFolder: preFolder, folder: #function, code:
        """
        struct Target<T: Sendable> {
            let a: T
        }
        """) else {
            return
        }
        
        //        $sxD
        let info14 = try tool.client(14)
        let info37 = try tool.client(37)
        let t = tool.store.all("s:4Temp6TargetV1Txmfp")
        let t2 = tool.store.allRelated("s:4Temp6TargetV1Txmfp")
        print(info37)
    }
    
    final func testExtensions2() throws {
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
        /// find `class C2: C1, P1, P2 {}` comforms
        /// found: `C1, P1, P2`
        let c2BaseOf = tool.store.db.occurrences(relatedToUSR: tool.usr(63), roles: .baseOf)
        
        XCTAssertEqual(c2BaseOf.count, 3)
        
        XCTAssertEqual(c2BaseOf[0].symbol.name, "C1")
        XCTAssertEqual(c2BaseOf[0].symbol.kind, .class)
        XCTAssertEqual(c2BaseOf[0].relations.first?.roles, .baseOf)
        
        XCTAssertEqual(c2BaseOf[1].symbol.name, "P1")
        XCTAssertEqual(c2BaseOf[1].symbol.kind, .protocol)
        XCTAssertEqual(c2BaseOf[1].relations.first?.roles, .baseOf)
        
        XCTAssertEqual(c2BaseOf[2].symbol.name, "P2")
        XCTAssertEqual(c2BaseOf[2].symbol.kind, .protocol)
        XCTAssertEqual(c2BaseOf[2].relations.first?.roles, .baseOf)
        
        /// find extesions `extension C2: P3 {}`
        let c2ExtendedBy = tool.store.db.occurrences(ofUSR: tool.usr(63), roles: .extendedBy)
        XCTAssertEqual(c2ExtendedBy.count, 1)
        XCTAssertEqual(c2ExtendedBy[0].relations.first?.symbol.kind, .extension)
        XCTAssertEqual(c2ExtendedBy[0].relations.first?.symbol.usr, "s:e:s:4Temp2C2Cs:4Temp2P3P")
        
        /// find extesion `extension C2: P3 {}` comforms
        /// found: `P3`
        let c2ExtensionBaseOf = tool.store.db.occurrences(relatedToUSR: "s:e:s:4Temp2C2Cs:4Temp2P3P", roles: .baseOf)
        XCTAssertEqual(c2ExtensionBaseOf.count, 1)
        XCTAssertEqual(c2ExtensionBaseOf[0].symbol.name, "P3")
        XCTAssertEqual(c2ExtensionBaseOf[0].symbol.kind, .protocol)
        XCTAssertEqual(c2ExtensionBaseOf[0].relations.first?.roles, .baseOf)
    }
    
    final func testGlobalActor() throws {
        guard let tool = try prepare(preFolder: preFolder, folder: #function, code:
        """
        @globalActor actor TestActor {
            static var shared = TestActor()
        }
        
        @MainActor class ClassInMainActor {}
        @TestActor class ClassInTestActor {}
        """) else {
            return
        }
        
        let info0 = try tool.client(0)
        let info1 = try tool.client(1)
        let info19 = try tool.client(19)
        
        /// TestActor
        let classTestActor = tool.store.db.occurrences(ofUSR: tool.usr(19), roles: .all)
        
        let cursorInfo = try tool.client(19)
        XCTAssertEqual(cursorInfo.usr, "s:4Temp9TestActorC")
        XCTAssertEqual(cursorInfo.typeusr, "$s4Temp9TestActorCmD")
        
        
        XCTAssertEqual(classTestActor[0].symbol.name, "TestActor")
        XCTAssertEqual(classTestActor[0].symbol.kind, .class)
        XCTAssertEqual(classTestActor[0].roles, [.canonical, .definition])
        
        XCTAssertEqual(classTestActor[1].relations.count, 1)
        XCTAssertEqual(classTestActor[1].relations.first?.symbol.name, "shared")
        XCTAssertEqual(classTestActor[1].relations.first?.symbol.kind, .staticProperty)
        XCTAssertEqual(classTestActor[1].relations.first?.roles, .containedBy)
        
        XCTAssertEqual(classTestActor[2].relations.count, 0)
        XCTAssertEqual(classTestActor[2].roles, .reference)
        
        /// ClassInMainActor
        let classClassInMainActor = tool.store.db.occurrences(relatedToUSR: tool.usr(87), roles: .all)
        XCTAssertEqual(classClassInMainActor.count, 1)
        XCTAssertEqual(classClassInMainActor[0].relations.count, 1)
        
        /// ClassInTestActor
        let classClassInTestActor = tool.store.db.occurrences(relatedToUSR: tool.usr(124), roles: .all)
        XCTAssertEqual(classClassInTestActor.count, 1)
        XCTAssertEqual(classClassInTestActor[0].relations.count, 1)
    }
}


import SwiftParser
extension PocTests {
    func testScipio() throws {
        let code = """
        import ABC
        
        let package = 1
        """
        let source = Parser.parse(source: code)
        let rewriter = ScipioRewriter()
        let modified = rewriter.visit(source)
        var result: String = ""
        modified.write(to: &result)
        
        let visitor = FoundationVisitor.init(viewMode: .all)
        visitor.walk(source)
        print(visitor.hasFoundation)
    }
}
