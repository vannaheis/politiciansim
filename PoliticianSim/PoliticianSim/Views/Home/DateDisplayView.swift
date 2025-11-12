//
//  DateDisplayView.swift
//  PoliticianSim
//
//  Displays current date and character age
//

import SwiftUI

struct DateDisplayView: View {
    let currentDate: Date
    let age: Int

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: currentDate)
    }

    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: currentDate)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                // Calendar icon
                ZStack {
                    Circle()
                        .fill(Constants.Colors.political.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: "calendar")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Constants.Colors.political)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(dayOfWeek)
                        .font(.system(size: Constants.Typography.captionSize, weight: .medium))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text(formattedDate)
                        .font(.system(size: Constants.Typography.bodyTextSize, weight: .semibold))
                        .foregroundColor(.white)
                }

                Spacer()

                // Age display
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Age")
                        .font(.system(size: Constants.Typography.captionSize, weight: .medium))
                        .foregroundColor(Constants.Colors.secondaryText)

                    Text("\(age)")
                        .font(.system(size: Constants.Typography.heroNumberSize, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
            )
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        StandardBackgroundView()
        DateDisplayView(currentDate: Date(), age: 25)
            .padding()
    }
}
