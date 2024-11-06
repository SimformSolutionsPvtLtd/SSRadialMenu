//
//  BlurredOverlayCircles.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 06/11/24.
//

import SwiftUI

struct BlurredOverlayCircles: View {
    @Binding var xOffset: CGFloat
    @Binding var yOffset: CGFloat
    @Binding var scaleEffect: CGFloat
    var frameWidth: CGFloat = 45
    var frameHeight: CGFloat = 55
    var color: Color = .blue

    // Optional external frame size parameters
    var externalFrameWidth: CGFloat? = nil
    var externalFrameHeight: CGFloat? = nil

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black)
                .blur(radius: 18.0)
                .frame(width: frameWidth, height: frameHeight)
                .offset(x: xOffset, y: yOffset)
                .scaleEffect(scaleEffect)
            Circle()
                .fill(Color.black)
                .blur(radius: 20.0)
                .frame(width: frameWidth * 2, height: frameHeight * 2)
        }
        // Apply external frame only if provided
        .applyExternalFrame(width: externalFrameWidth, height: externalFrameHeight)
        .overlay(
            Color(white: 0.5).opacity(0.8)
                .blendMode(.colorBurn)
                .allowsHitTesting(false)
        )
        .overlay(
            Color(white: 1.0).opacity(0.8)
                .blendMode(.colorDodge)
                .allowsHitTesting(false)
        )
        .overlay(
            color.opacity(0.8)
                .blendMode(.plusLighter)
                .allowsHitTesting(false)
        )
    }
}

// Custom modifier to apply the external frame size if provided
extension View {
    func applyExternalFrame(width: CGFloat?, height: CGFloat?) -> some View {
        Group {
            if let width = width, let height = height {
                self.frame(width: width, height: height)
            } else {
                self
            }
        }
    }
}
