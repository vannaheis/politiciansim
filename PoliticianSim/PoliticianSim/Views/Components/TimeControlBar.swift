//
//  TimeControlBar.swift
//  PoliticianSim
//
//  Time control buttons (Skip Day/Week)
//

import SwiftUI

struct TimeControlBar: View {
    let onSkipDay: () -> Void
    let onSkipWeek: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onSkipDay) {
                HStack(spacing: 6) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 14, weight: .semibold))

                    Text("Skip Day")
                        .font(.system(size: Constants.Typography.buttonTextSize, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Constants.Colors.buttonPrimary)
                )
            }

            Button(action: onSkipWeek) {
                HStack(spacing: 6) {
                    Image(systemName: "forward.end.fill")
                        .font(.system(size: 14, weight: .semibold))

                    Text("Skip Week")
                        .font(.system(size: Constants.Typography.buttonTextSize, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Constants.Colors.buttonSecondary)
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color.black.opacity(0.3)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

#Preview {
    VStack {
        Spacer()

        TimeControlBar(
            onSkipDay: {
                print("Skip day pressed")
            },
            onSkipWeek: {
                print("Skip week pressed")
            }
        )
    }
    .background(Constants.Colors.background)
}
