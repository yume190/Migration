//
//  File.swift
//  
//
//  Created by Tangram Yume on 2024/8/7.
//

import Foundation
import SKClient

public class MainActorLogic {
    public typealias Fix = Set<String>
    public private(set) var fixs: Fix = []
    
    let store: IndexStore
    let client: SKClient
    
    public init(store: IndexStore, client: SKClient) {
        self.store = store
        self.client = client
    }
    
    public func append(usrs: [String]) {
        fixs = fixs.union(Set(usrs))
    }
    
    public func process() {
        fixs = findCaller(origin: fixs, input: fixs)
    }
    
    private func findCaller(origin: Set<String>, input: Set<String>) -> Set<String> {
        let newUsrs: [String] = input
            .map { usr in
                store.findCaller(usr)
            }
            .flatMap {$0}
            .compactMap(\.relations.first?.symbol.usr)
        let newSet = Set(newUsrs)
        
        let nextInput = newSet.subtracting(origin)
        if nextInput.isEmpty {
            return origin
        }
        
        return findCaller(
            origin: origin.union(nextInput),
            input: nextInput
        )
    }
}
