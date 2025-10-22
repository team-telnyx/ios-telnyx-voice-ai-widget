//
//  View+Extensions.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI

extension View {
    /// Applies a transformation to a view conditionally
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Applies an optional modifier to a view if the modifier is not nil
    @ViewBuilder
    func ifLet<T, Content: View>(_ optional: T?, transform: (Self, T) -> Content) -> some View {
        if let unwrapped = optional {
            transform(self, unwrapped)
        } else {
            self
        }
    }
}
