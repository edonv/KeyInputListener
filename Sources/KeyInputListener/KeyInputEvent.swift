//
//  KeyInputEvent.swift
//  
//
//  Created by Edon Valdman on 4/27/24.
//

import Foundation

public enum KeyInputEvent {
    case character(Character)
    case backspace
    case space
    case enter
    case escape
    
    case specialKey(SpecialKey)
    
    #if canImport(AppKit)
    public typealias SpecialKey = NSEvent.SpecialKey
    #else
    public typealias SpecialKey = Never
    #endif
}
