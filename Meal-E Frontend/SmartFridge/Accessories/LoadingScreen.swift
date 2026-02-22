//
//  LoadingScreen.swift
//  SmartFridge
//
//  Created by Michael Pancras on 2/22/26.
//

import SwiftUI
import Combine

// MARK: - Loading Screen

struct LoadingScreen: View {
    let messages = [
        "Regenerating meal plan...",
        "Checking your fridge...",
        "Crunching the numbers...",
        "Cooking to perfection...",
        "Adding final touches...",
        "Spicing things up...",
        "...with Bindu...",
        "Picking the freshest ingredients...",
        "Balancing your macros...",
        "Almost ready...",
        "Prepping your meal plan...",
        "Good things take time...",
    ]

    @State private var currentMessageIndex = 0
    @State private var dotCount = 0
    @State private var messageOpacity = 1.0

    let dotTimer    = Timer.publish(every: 0.5,  on: .main, in: .common).autoconnect()
    let messageTimer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()

    var dots: String { String(repeating: ".", count: dotCount) }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "D8F3DC"), Color(hex: "EDF7F0"), Color(hex: "F0FAF4")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {

                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(hex: "1B4332"), Color(hex: "2D6A4F")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 90, height: 90)
                        .shadow(color: Color(hex: "1B4332").opacity(0.25), radius: 16, x: 0, y: 6)

                    Text("🌿")
                        .font(.system(size: 44))
                }

                // Title
                VStack(alignment: .center, spacing: 8) {
                    Text("Meal-E")
                        .font(.system(size: 28, weight: .heavy, design: .serif))
                        .foregroundStyle(Color(hex: "1B4332"))

                    Text("is thinking\(dots)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(hex: "2D6A4F").opacity(0.7))
                        .animation(nil, value: dots)
                }

                // Animated message
                Text(messages[currentMessageIndex])
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                    .foregroundStyle(Color(hex: "2D6A4F"))
                    .padding(.horizontal, 28).padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(hex: "52B788").opacity(0.3), lineWidth: 1)
                            )
                    )
                    .shadow(color: Color(hex: "2D6A4F").opacity(0.07), radius: 8, x: 0, y: 3)
                    .opacity(messageOpacity)
                    .animation(.easeInOut(duration: 0.4), value: messageOpacity)

                Spacer()
                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .onReceive(dotTimer) { _ in
            dotCount = (dotCount % 3) + 1
        }
        .onReceive(messageTimer) { _ in
            withAnimation { messageOpacity = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                currentMessageIndex = (currentMessageIndex + 1) % messages.count
                withAnimation { messageOpacity = 1 }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    LoadingScreen()
}
