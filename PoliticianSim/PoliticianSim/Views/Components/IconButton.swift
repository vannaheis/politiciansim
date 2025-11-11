//
//  IconButton.swift
//  PoliticianSim
//
//  Icon-only circular button
//

import SwiftUI

struct IconButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        IconButton(icon: "plus", color: Constants.Colors.positive) {
            print("Add pressed")
        }

        IconButton(icon: "minus", color: Constants.Colors.negative) {
            print("Remove pressed")
        }

        IconButton(icon: "info.circle", color: Constants.Colors.charisma) {
            print("Info pressed")
        }

        IconButton(icon: "gearshape", color: .white) {
            print("Settings pressed")
        }

        IconButton(icon: "xmark", color: .red) {
            print("Close pressed")
        }
    }
    .padding()
    .background(Constants.Colors.background)
}
