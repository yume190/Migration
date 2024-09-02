//
//  IndexDB.swift
//  TypeFillKit
//
//  Created by Yume on 2021/4/13.
//

import Foundation
import SKClient
import IndexStoreDB

/// xcrun --find sourcekit-lsp
/// /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp
///
/// libIndexStore:
/// /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib
public struct IndexStore {
  private static let defaultLibPath: String = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib"
  
  public let db: IndexStoreDB
    
  public init?(path: String) {
    guard let lspPath: String = Exec.run(
      "/usr/bin/xcrun",
      "--find", "sourcekit-lsp"
    ).string else { return nil }
    
    let indexStoreLibPath: URL = URL(fileURLWithPath: lspPath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appendingPathComponent("lib/libIndexStore.dylib")
    
    let libPath: String = indexStoreLibPath.path
    let databasePath = NSTemporaryDirectory() + "\(UUID())"
    do {
      try self.db = IndexStoreDB(
        storePath: path,
//        databasePath: NSTemporaryDirectory() + "index_\(getpid())",
        databasePath: databasePath,
        library: IndexStoreLibrary(dylibPath: libPath)
      )
      db.pollForUnitChangesAndWait()
    } catch {
      print(error)
      return nil
    }
  }
}
