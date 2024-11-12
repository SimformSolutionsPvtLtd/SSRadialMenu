//
//  BlurredOverlayCircles.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 06/11/24.
//
import SwiftUI

struct BlurredOverlayCircles: View {
    @Binding var isExpanded: Bool
    @Binding var xOffset: CGFloat
    @Binding var yOffset: CGFloat
    @Binding var scaleEffect: CGFloat
    @Binding var currentPeelingAngle: Double
    var frameWidth: CGFloat = 45
    var frameHeight: CGFloat = 55
    var color: Color = .blue
    var isMainMenu = false
    var externalFrameWidth: CGFloat? = nil
    var externalFrameHeight: CGFloat? = nil
    var index: Int // To track the index of the item in the loop
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .blur(radius: 8.0)
                .frame(width: frameWidth, height: frameHeight)
                .offset(x: xOffset, y: yOffset)
                .scaleEffect(scaleEffect)

            // Display the overlay only if it's the main menu or if the item is not yet fully displayed
            if isMainMenu {
                Circle()
                    .fill(color)
                    .blur(radius: 10.0)
                    .frame(width: frameWidth * 2, height: frameHeight * 2)
                    .overlay(
                        Color(white: 0.5).opacity(0.8)
                            .blendMode(.colorBurn)
                            .allowsHitTesting(false)
                            .clipShape(Circle())
                            .scaleEffect(2) // scales the circle to twice its size
                    )
                    .overlay(
                        Color(white: 1.0).opacity(0.8)
                            .blendMode(.colorDodge)
                            .allowsHitTesting(false)
                            .clipShape(Circle())
                            .scaleEffect(2)
                    )
            } else {
                Circle()
                    .fill(color)
                    .frame(width: frameWidth * 2, height: frameHeight * 2)
            }
        }
        .overlay {
            if isMainMenu {
                PlusToCrossView(isCross: $isExpanded)
            }
        }
        .applyExternalFrame(width: externalFrameWidth, height: externalFrameHeight)
    }
}

extension View {
    func applyExternalFrame(width: CGFloat?, height: CGFloat?) -> some View {
        Group {
            if let width = width, let height = height {
                self.frame(width: width, height: height, alignment: .bottomTrailing)
            } else {
                self
            }
        }
    }
}

