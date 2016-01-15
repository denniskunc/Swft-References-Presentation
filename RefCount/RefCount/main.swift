//
//  main.swift
//  RefCount
//
//  Created by Dennis Kunc on 1/6/16.
//  Copyright © 2016 LTS Technology Inc. All rights reserved.
//

import Foundation

// Helper to construct a hex string representation of an object based on its address and length from Mike Ash blog post
func contents(ptr: UnsafePointer<Void>, _ length: Int) -> String {
    let wordPtr = UnsafePointer<UInt>(ptr)
    let words = length / sizeof(UInt.self)
    let wordChars = sizeof(UInt.self) * 2
    let buffer = UnsafeBufferPointer<UInt>(start: wordPtr, count: words)
    let wordStrings = buffer.map({
        word -> String
        in var wordString = String(word, radix: 16)
        while wordString.characters.count < wordChars { wordString = "0" + wordString }
        return wordString
        }
    )
    return wordStrings.joinWithSeparator(" ")
}

//Builds and returns a function that creates print object information
func dumperFunc(obj: AnyObject) -> (Void -> String) {
    let objString = String(obj)
    let ptr = unsafeBitCast(obj, UnsafePointer<Void>.self)
    let length = class_getInstanceSize(obj.dynamicType)
    return {
        let bytes = contents(ptr, length)
        return "\(objString) \(ptr): \(bytes)"
    }
}

class Dependent {
    init (ref: Parent) {
        parent = ref
    }
    var parent: Parent
    deinit {
        print("Dependent deinit")
    }
}

class Parent {
    var header = 0x1234321012343210
    var child: Dependent?        //add weak modifier for second part of test 3
    var trailer: UInt = 0xabcdefabcdefabcd
    deinit {
        print("Parent deinit")
    }
}

do {
    let parent = Parent()
    let parentDump = dumperFunc(parent)
    print("Parent Dump 1")
    print(parentDump())
    
    //Test 2
    //Show ref count increases when object is assigned to a second pointer
    let parent2 = parent
    print("Parent Dump 2")
    print(parentDump())
    
    
    //Test 3  without weak then with weak
//    do {
//    let child = Dependent(ref: parent)
//    let childDump = dumperFunc(child)
//    parent.child = child
//    
//        print("child dump 1")
//        print(childDump())
//        print("parent dump 3")
//        print(parentDump())
//    }
    
    
}
print("Exiting program")



