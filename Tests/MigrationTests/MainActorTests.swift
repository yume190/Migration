import Foundation
import XCTest
import SwiftSyntax
import SwiftSyntaxBuilder
import SKClient
import PathKit
@testable import MigrationKit

private let preFolder = "MainActor"

final class MainActorTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        let dir = fixture + preFolder
        try? dir.delete()
    }
    
    final func todoSimple() throws {
        guard let modifiedCode = try addMainActor(preFolder: preFolder, folder: #function, code:
        """
        @MainActor
        var a: Int
        
        func test() {
            print(a)
        }
        """) else {
            return
        }
        
        let expectCode = """
        @MainActor
        var a: Int
        
        @MainActor func test() {
            print(a)
        }
        """
        
        XCTAssertEqual(modifiedCode, expectCode)
    }
    
    final func testSimple() throws {
        guard let modifiedCode = try addMainActor(preFolder: preFolder, folder: #function, code:
        """
        class C {
            var a: Int
            init(a: Int) {
                self.a = a
            }
        }
        
        func test1() {
            let c = C(a: 1)
            print(c.a)
        }
        
        func test2() {
            let c = C(a: 1)
            print(c)
        }
        """) else {
            return
        }
        
        let expectCode = """
        class C {
            @MainActor var a: Int
            @MainActor init(a: Int) {
                self.a = a
            }
        }
        
        @MainActor func test1() {
            let c = C(a: 1)
            print(c.a)
        }
        
        @MainActor func test2() {
            let c = C(a: 1)
            print(c)
        }
        """
        
        XCTAssertEqual(modifiedCode, expectCode)
    }
}
