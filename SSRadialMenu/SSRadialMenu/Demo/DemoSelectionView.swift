//
//  DemoSelectionView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 11/06/25.
//

import SwiftUI

struct DemoSelectionView: View {
    @State private var selectedDemo: DemoType? = nil

    enum DemoType: String, CaseIterable {
        case calendarMenu = "Calendar Menu"
        case foodMenu = "Food Menu"

        var icon: String {
            switch self {
            case .calendarMenu: return "calendar.badge.plus"
            case .foodMenu: return "fork.knife"
            }
        }

        var description: String {
            switch self {
            case .calendarMenu: return "Monthly calendar with date selection\nFeatures hierarchical menu navigation"
            case .foodMenu: return "Delicious food menu with categories\nImage-based menu items"
            }
        }

        var gradient: LinearGradient {
            switch self {
            case .calendarMenu:
                return LinearGradient(
                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .foodMenu:
                return LinearGradient(
                    colors: [Color.orange.opacity(0.8), Color.red.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }

    var body: some View {
        if let selectedDemo = selectedDemo {
            // Show the selected demo
            switch selectedDemo {
            case .calendarMenu:
                CalendarDemoView(onBack: { self.selectedDemo = nil })
            case .foodMenu:
                FoodDemoView(onBack: { self.selectedDemo = nil })
            }
        } else {
            // Show selection screen
            ZStack {
                // Animated background

                Color.black
                    .ignoresSafeArea()
                // Floating particles
                ForEach(0..<30, id: \.self) { _ in
                    FloatingParticle()
                }


                VStack(spacing: 40) {
                    // Title Section
                    VStack(spacing: 16) {
                        Text("SSRadialMenu")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)

                        Text("Choose Your Demo Experience")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)

                    Spacer()

                    // Demo Selection Cards
                    VStack(spacing: 30) {
                        ForEach(DemoType.allCases, id: \.self) { demo in
                            DemoCard(
                                demo: demo,
                                isSelected: selectedDemo == demo,
                                onTap: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        selectedDemo = demo
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 30)

                    Spacer()

                    // Footer
                    Text("Tap a card to explore the radial menu")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 40)
                }
            }
            .ignoresSafeArea()
        }
    }
}

struct DemoCard: View {
    let demo: DemoSelectionView.DemoType
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 20) {
                // Icon Section
                ZStack {
                    Circle()
                        .fill(demo.gradient)
                        .frame(width: 70, height: 70)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)

                    Image(systemName: demo.icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                }

                // Text Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(demo.rawValue)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    Text(demo.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                }

                Spacer()

                // Arrow
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .scaleEffect(isPressed ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: isPressed)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct FloatingParticle: View {
    @State private var position = CGPoint(x: CGFloat.random(in: 0...1000),
                                          y: CGFloat.random(in: 0...800))
    @State private var opacity = Double.random(in: 0.1...0.4)
    @State private var scale = CGFloat.random(in: 0.5...1.5)

    var body: some View {
        Circle()
            .fill(Color.white.opacity(opacity))
            .blur(radius: 2)
            .frame(width: 4, height: 4)
            .scaleEffect(scale)
            .position(position)
            .onAppear {
                withAnimation(.linear(duration: Double.random(in: 15...25)).repeatForever(autoreverses: false)) {
                    position.y -= 900
                }

                withAnimation(.easeInOut(duration: Double.random(in: 2...4)).repeatForever(autoreverses: true)) {
                    opacity = Double.random(in: 0.1...0.6)
                    scale = CGFloat.random(in: 0.3...2.0)
                }
            }
    }
}

#Preview {
    DemoSelectionView()
}
