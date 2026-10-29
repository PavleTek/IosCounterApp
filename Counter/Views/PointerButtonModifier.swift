//
//  PointerButtonModifier.swift
//  Counter
//

import SwiftUI

struct PointerButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .hoverEffect(.highlight)
    }
}

extension View {
    func pointerButton() -> some View {
        modifier(PointerButtonModifier())
    }
}
