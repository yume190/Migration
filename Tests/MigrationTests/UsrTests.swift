//
//  File.swift
//  
//
//  Created by Tangram Yume on 2024/8/7.
//

import Foundation
import XCTest
import SKClient
import PathKit

final class UsrTests: XCTestCase {
    static let code = """
    import Foundation
    class Target: NSObject {}
    """
    static let wrongUsr = "s:4Temp6TargetC"
    static let rightUsr = "c:@M@Temp@objc(cs)Target"
    static let file = fixture + "Usr" + "Temp.swift"
    
    override class func setUp() {
        super.setUp()
        let dir = fixture + "Usr"
        try? dir.mkpath()
        try? file.write(code, encoding: .utf8)
    }
    
    func testUsr() throws {
        let client = try SKClient(path: Self.file.string, sdk: .macosx)
        let usr = try client(24).usr
        XCTAssertEqual(usr, Self.rightUsr) // 5.9 down
        
//#if swift(>=6.0)
//        XCTAssertEqual(usr, rightUsr) // 6.0 up
//#elseif swift(<5.10)
//        XCTAssertEqual(usr, rightUsr) // 5.9 down
//#else
//        XCTAssertEqual(usr, wrongUsr) // 5.10
//#endif
    }
}
