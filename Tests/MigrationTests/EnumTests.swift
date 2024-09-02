import Foundation
import XCTest
import PathKit
import SwiftSyntax
import SwiftSyntaxBuilder
@testable import MigrationKit

private let preFolder = "Enum"

final class EnumTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        let dir = fixture + preFolder
        try? dir.delete()
    }
}

extension EnumTests {
    func testSimple() throws {
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        enum Target {
            case target1
            case target2
        }
        """) else {
            XCTFail()
            return
        }
        
        let expectCode = """
        enum Target : Sendable {
            case target1
            case target2
        }
        """
        
        XCTAssertEqual(modifiedCode, expectCode)
    }
    
    func testWithSendableParameter() throws {
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        enum Target {
            case target1(String)
            case target2(Int)
        }
        """) else {
            XCTFail()
            return
        }
        
        let expectCode = """
        enum Target : Sendable {
            case target1(String)
            case target2(Int)
        }
        """
        
        XCTAssertEqual(modifiedCode, expectCode)
    }
    
    func testWithSendableType() throws {
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        enum Target: Int {
            case a
            case b
        }
        """) else {
            XCTFail()
            return
        }
        
        let expectCode = """
        enum Target: Int, Sendable {
            case a
            case b
        }
        """
        
        XCTAssertEqual(modifiedCode, expectCode)
    }
    
    func testWithNonsendableParameter() throws {
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        enum Target {
            case target1(NSObject)
            case target2(Int)
        }
        """) else {
            XCTFail()
            return
        }
        
        let expectCode = """
        enum Target {
            case target1(NSObject)
            case target2(Int)
        }
        """
        
        XCTAssertEqual(modifiedCode, expectCode)
    }
}
