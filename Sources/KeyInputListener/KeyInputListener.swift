//
//  KeyInputListener.swift
//
//
//  Created by Edon Valdman on 4/27/24.
//

import SwiftUI

#if canImport(UIKit)
typealias CrossPlatView = UIView
#else
typealias CrossPlatView = NSView
#endif

class _TextInput: CrossPlatView {
    var keyInputEventHandler: ((KeyInputEvent) -> Void)? = nil
    
    private func newCharacter(_ char: Character) {
        if char == " " {
            keyInputEventHandler?(.space)
        } else {
            #if canImport(AppKit)
            var modifiers = modifiers
            if char.isUppercase && modifiers.contains(.shift) {
                modifiers.subtract(.shift)
            }
            #endif
            keyInputEventHandler?(.character(char))
        }
    }
    
    private func backspace() {
        keyInputEventHandler?(.backspace)
    }
}

#if canImport(UIKit)
extension _TextInput: UIKeyInput {
    // MARK: - UIKeyInput
    
    override var canBecomeFirstResponder: Bool { true }
    
    var hasText: Bool { true }
    
    func insertText(_ text: String) {
        for char in text {
            if char.isNewline {
                keyInputEventHandler?(.enter)
            } else {
                newCharacter(char)
            }
        }
    }
    
    func deleteBackward() {
        backspace()
    }
}
#else
import Carbon.HIToolbox
extension _TextInput {
    override var acceptsFirstResponder: Bool { true }
    
    override func keyDown(with keyInputEvent: NSEvent) {
        // If pressed `escape`
        if Int(keyInputEvent.keyCode) == kVK_Escape {
            keyInputEventHandler?(.escape)
        } else if let specialKey = keyInputEvent.specialKey {
            // if pressed a special key
            switch specialKey {
            case .backspace, .delete:
                backspace()
            case .enter, .carriageReturn:
                keyInputEventHandler?(.enter)
            default:
                keyInputEventHandler?(.specialKey(specialKey))
            }
        } else if let char = keyInputEvent.charactersIgnoringModifiers {
            // otherwise, new character
            newCharacter(Character(char))
        }
    }
}
#endif

internal struct KeyInputListener {
    internal typealias ViewType = _TextInput
    
    @Binding private var isFirstResponder: Bool
    private let keyInputEventHandler: (KeyInputEvent) -> Void
    
    internal init(
        isFirstResponder: Binding<Bool>,
        keyInputEventHandler: @escaping (KeyInputEvent) -> Void
    ) {
        self._isFirstResponder = isFirstResponder
        self.keyInputEventHandler = keyInputEventHandler
    }
    
    private func createView() -> ViewType {
        let view = ViewType()
        view.keyInputEventHandler = self.keyInputEventHandler
        return view
    }
}

#if canImport(UIKit)
extension KeyInputListener: UIViewRepresentable {
    func makeUIView(context: Context) -> ViewType {
        createView()
    }
    
    func updateUIView(_ uiView: ViewType, context: Context) {
        if isFirstResponder {
            uiView.becomeFirstResponder()
        } else {
            uiView.resignFirstResponder()
        }
    }
}
#else
extension KeyInputListener: NSViewRepresentable {
    func makeNSView(context: Context) -> ViewType {
        createView()
    }
    
    func updateNSView(_ nsView: ViewType, context: Context) {
        if isFirstResponder {
            nsView.becomeFirstResponder()
        } else {
            nsView.resignFirstResponder()
        }
    }
}
#endif
