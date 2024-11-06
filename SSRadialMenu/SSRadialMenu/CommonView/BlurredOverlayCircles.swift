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
    var color: Color
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black)
                .blur(radius: 18.0)
                .frame(width: 45.0, height: 55.0)
                .offset(x: xOffset, y: yOffset)
                .scaleEffect(scaleEffect)
            Circle()
                .fill(Color.black)
                .blur(radius: 20.0)
                .frame(width: 90.0, height: 110.0)
        }
        .frame(width: 200.0, height: 200.0)
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
