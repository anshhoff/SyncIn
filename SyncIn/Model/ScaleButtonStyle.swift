//
//  ScaleButtonStyle.swift
//  SyncIN
//
//  Created by Ansh Hardaha on 2025/01/28.
//

import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.smooth(duration: 0.2), value: configuration.isPressed)
    }
}

