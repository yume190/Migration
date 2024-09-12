//
//  File.swift
//  
//
//  Created by Tangram Yume on 2024/8/12.
//



@globalActor actor TestActor {
    static var shared = TestActor()
}

@MainActor class ClassInMainActor {}
@TestActor class ClassInTestActor {}
