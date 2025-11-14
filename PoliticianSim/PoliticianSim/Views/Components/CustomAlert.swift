//
//  CustomAlert.swift
//  PoliticianSim
//
//  Custom alert system with game-themed styling
//

import SwiftUI

// MARK: - Alert Configuration

struct AlertConfig {
    let title: String
    let message: String
    let primaryButton: AlertButton
    let secondaryButton: AlertButton?

    init(
        title: String,
        message: String,
        primaryButton: AlertButton,
        secondaryButton: AlertButton? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
}

struct AlertButton {
    let title: String
    let role: ButtonRole
    let action: () -> Void

    enum ButtonRole {
        case normal
        case cancel
        case destructive

        var color: Color {
            switch self {
            case .normal: return Constants.Colors.political
            case .cancel: return Constants.Colors.secondaryText
            case .destructive: return Constants.Colors.negative
            }
        }
    }

    init(title: String, role: ButtonRole = .normal, action: @escaping () -> Void) {
        self.title = title
        self.role = role
        self.action = action
    }
}

// MARK: - Custom Alert View

struct CustomAlert: View {
    let config: AlertConfig
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    // Dismiss on background tap
                    withAnimation(.easeOut(duration: 0.2)) {
                        isPresented = false
                    }
                }

            // Alert card
            VStack(spacing: 0) {
                // Title
                Text(config.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 24)
                    .padding(.horizontal, 24)

                // Message
                Text(config.message)
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 12)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                Divider()
                    .background(Color.white.opacity(0.2))

                // Buttons
                HStack(spacing: 0) {
                    if let secondaryButton = config.secondaryButton {
                        AlertButtonView(
                            button: secondaryButton,
                            isPresented: $isPresented
                        )

                        Divider()
                            .background(Color.white.opacity(0.2))
                            .frame(height: 44)
                    }

                    AlertButtonView(
                        button: config.primaryButton,
                        isPresented: $isPresented
                    )
                }
                .frame(height: 44)
            }
            .frame(width: 300)
            .background(Color.black)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
            )
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            .scaleEffect(isPresented ? 1.0 : 0.8)
            .opacity(isPresented ? 1.0 : 0.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPresented)
        }
    }
}

// MARK: - Alert Button View

struct AlertButtonView: View {
    let button: AlertButton
    @Binding var isPresented: Bool
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            button.action()
            withAnimation(.easeOut(duration: 0.2)) {
                isPresented = false
            }
        }) {
            Text(button.title)
                .font(.system(size: 15, weight: button.role == .destructive ? .semibold : .medium))
                .foregroundColor(button.role.color)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isPressed ? Color.white.opacity(0.1) : Color.clear)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - View Extension

extension View {
    func customAlert(
        isPresented: Binding<Bool>,
        config: AlertConfig
    ) -> some View {
        ZStack {
            self

            if isPresented.wrappedValue {
                CustomAlert(config: config, isPresented: isPresented)
                    .transition(.opacity)
            }
        }
    }

    func customAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        primaryButton: String,
        primaryAction: @escaping () -> Void
    ) -> some View {
        customAlert(
            isPresented: isPresented,
            config: AlertConfig(
                title: title,
                message: message,
                primaryButton: AlertButton(title: primaryButton, action: primaryAction)
            )
        )
    }

    func customAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        primaryButton: String,
        primaryAction: @escaping () -> Void,
        secondaryButton: String,
        secondaryAction: @escaping () -> Void = {}
    ) -> some View {
        customAlert(
            isPresented: isPresented,
            config: AlertConfig(
                title: title,
                message: message,
                primaryButton: AlertButton(title: primaryButton, role: .destructive, action: primaryAction),
                secondaryButton: AlertButton(title: secondaryButton, role: .cancel, action: secondaryAction)
            )
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        Text("Background Content")
            .foregroundColor(.white)
    }
    .customAlert(
        isPresented: .constant(true),
        config: AlertConfig(
            title: "Reset Game Progress?",
            message: "This will reset all game progress and return you to character creation. This action cannot be undone.",
            primaryButton: AlertButton(title: "Reset", role: .destructive, action: {}),
            secondaryButton: AlertButton(title: "Cancel", role: .cancel, action: {})
        )
    )
}
