//
//  KeyInputListener+ViewModifiers.swift
//
//
//  Created by Edon Valdman on 4/27/24.
//

import SwiftUI

// MARK: - Base-Level Funcs

extension View {
    @ViewBuilder
    private func _inputBackground(_ listenerView: KeyInputListener) -> some View {
        if #available(iOS 15.0, macOS 12.0, *) {
            self.background { listenerView }
        } else {
            self.background(listenerView)
        }
    }
    
    @ViewBuilder
    public func keyInputListener(
        isFocused: Binding<Bool>,
        onInput inputEventHandler: @escaping (_ event: KeyInputEvent) -> Void
    ) -> some View {
        let input = KeyInputListener(isFirstResponder: isFocused, keyInputEventHandler: inputEventHandler)
        _inputBackground(input)
    }
    
    @ViewBuilder
    public func keyInputListener(
        _ text: Binding<String>,
        isFocused: Binding<Bool>,
        onSubmit: (() -> Void)? = nil
    ) -> some View {
        self.keyInputListener(isFocused: isFocused) { event in
            switch event {
            case .character(let char, _):
                text.wrappedValue.append(char)
            case .backspace:
                text.wrappedValue.removeLast()
            case .space:
                text.wrappedValue.append(" ")
            case .enter:
                if let onSubmit {
                    onSubmit()
                } else {
                    text.wrappedValue.append("\n")
                }
            default:
                break
            }
        }
    }
}

// MARK: - Focus-Based Funcs

@available(iOS 15.0, macOS 12.0, *)
extension View {
    @ViewBuilder
    public func keyInputListener(
        isFocused: FocusState<Bool>.Binding,
        onInput inputEventHandler: @escaping (_ event: KeyInputEvent) -> Void
    ) -> some View {
        self.keyInputListener(isFocused: .init(get: {
            isFocused.wrappedValue
        }, set: { newValue in
            isFocused.wrappedValue = newValue
        }), onInput: inputEventHandler)
    }
    
    @ViewBuilder
    public func keyInputListener<Value: Hashable>(
        isFocused: FocusState<Value?>.Binding,
        equals value: Value,
        onInput inputEventHandler: @escaping (_ event: KeyInputEvent) -> Void
    ) -> some View {
        self.keyInputListener(isFocused: .init(get: {
            isFocused.wrappedValue == value
        }, set: { newValue in
            isFocused.wrappedValue = newValue ? value : nil
        }), onInput: inputEventHandler)
    }
}
