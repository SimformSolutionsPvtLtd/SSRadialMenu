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
    var frameWidth: CGFloat = 45
    var frameHeight: CGFloat = 55
    var color: Color = .blue

    var externalFrameWidth: CGFloat? = nil
    var externalFrameHeight: CGFloat? = nil

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.red)
                .blur(radius: 8.0)
                .frame(width: frameWidth, height: frameHeight)
                .offset(x: xOffset, y: yOffset)
                .scaleEffect(scaleEffect)
            Circle()
                .fill(Color.red)
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
        }
        .overlay {
            PlusToCrossView(isCross: $isExpanded)
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
