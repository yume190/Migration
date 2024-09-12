//
//  SendableTests.swift
//  
//
//  Created by Tangram Yume on 2024/8/7.
//

import Foundation
import Testing
import SwiftSyntax
import SwiftSyntaxBuilder
import SKClient
import PathKit
@testable import MigrationKit

private let preFolder = "Sendable"
fileprivate func cleanUp(folder: String) throws {
    let dir = fixture + preFolder + folder.removeSuffix("()")
    if dir.exists && dir.isDirectory {
        try dir.delete()
    }
}

@Suite("Sendable Tests", .serialized)
struct SendableTests {

    @Test("O: Simple Case")
    func testSimple() throws {
        try cleanUp(folder: #function)
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
        
        try #require(modifiedCode == expectCode)
    }
    
    @Test("X: with generic")
    func testWithGeneric() throws {
        try cleanUp(folder: #function)
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        struct Target<T> {
            let a: T
        }
        """) else {
            return
        }
        
        let expectCode = """
        struct Target<T> {
            let a: T
        }
        """
        
        try #require(modifiedCode == expectCode)
    }
    
    /// 
    /// @Test("O: with generic Sendable")
    func _testWithGenericSendable() throws {
        try cleanUp(folder: #function)
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        struct Target<T: Sendable> {
            let a: T
        }
        """) else {
            return
        }
        
        let expectCode = """
        struct Target<T: Sendable> : Sendable {
            let a: T
        }
        """
        
        try #require(modifiedCode == expectCode)
    }
    
    @Test("X: with non-Sendable `b: NSObject`")
    func testWithNSObjectProperty() throws {
        try cleanUp(folder: #function)
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
        
        try #require(modifiedCode == expectCode)
    }
    
    @Test("O: Special Case only check `a: Int`")
    func testWithException() throws {
        try cleanUp(folder: #function)
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
        
        try #require(modifiedCode == expectCode)
    }
    
    @Test("O: Exist Sendable")
    func testExistSendable() throws {
        try cleanUp(folder: #function)
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
        
        try #require(modifiedCode == expectCode)
    }
    
    @Test("O: With Multi Inheritance")
    func testWithMultiInheritance() throws {
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
        
        try #require(modifiedCode == expectCode)
    }
    
    @Test("O: Step 1")
    func testStep1() throws {
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
        
        try #require(modifiedCode == expectCode)
    }
    
    @Test("O: Step 2")
    func testStep2() throws {
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
        
        try #require(modifiedCode == expectCode)
    }
    
    @Test("O: Step 3")
    func testStep3() throws {
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
        
        try #require(modifiedCode == expectCode)
    }
    
    class Target {
        let a: Int
        init(a: Int) {
            self.a = a
        }
    }
    
    @Test("O: Simple Case(class)")
    func testClass() throws {
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
        
        try #require(modifiedCode == expectCode)
    }
    
    @Test("X: C3 Inherit from NSObject")
    func testClassNSObject() throws {
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
        
        try #require(modifiedCode == expectCode)
    }
    
    @Test("O: Only C3 can be final class")
    func testClassOnlyNoChildClass() throws {
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
        
        try #require(modifiedCode == expectCode)
    }
}


extension SendableTests {
    
    @Test("O: Simple Case Enum")
    func testEnumSimple() throws {
        try cleanUp(folder: #function)
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        enum Target {
            case target1
            case target2
        }
        """) else {
            return
        }
        
        let expectCode = """
        enum Target : Sendable {
            case target1
            case target2
        }
        """
        
        try #require(modifiedCode == expectCode)
    }
    
    @Test("O: Enum with param")
    func testEnumWithParam() throws {
        try cleanUp(folder: #function)
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        enum Target {
            case target1(Int)
            case target2(Int)
        }
        """) else {
            return
        }
        
        let expectCode = """
        enum Target : Sendable {
            case target1(Int)
            case target2(Int)
        }
        """
        
        try #require(modifiedCode == expectCode)
    }
    
    @Test("O: Enum with Type")
    func testEnumWithType() throws {
        try cleanUp(folder: #function)
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        enum Target: Int {
            case target1 = 0
            case target2
        }
        """) else {
            return
        }
        
        let expectCode = """
        enum Target: Int, Sendable {
            case target1 = 0
            case target2
        }
        """
        
        try #require(modifiedCode == expectCode)
    }
    
    @Test("X: Enum with non-Sendable param")
    func testEnumWithNonSendableParam() throws {
        try cleanUp(folder: #function)
        guard let modifiedCode = try addSendable(preFolder: preFolder, folder: #function, code:
        """
        enum Target {
            case target1(NSObject)
            case target2(Int)
        }
        """) else {
            return
        }
        
        let expectCode = """
        enum Target {
            case target1(NSObject)
            case target2(Int)
        }
        """
        
        try #require(modifiedCode == expectCode)
    }
}
