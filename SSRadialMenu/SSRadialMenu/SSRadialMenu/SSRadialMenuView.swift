//
//  SSRadialMenuView.swift
//  SSRadialMenuView
//
//  Created by Rishita Panchal on 07/12/23.
//

import SwiftUI

struct LiquidPeelAwayView: View {
    @State private var isPeeling: Bool = false
    @State private var rotationAngle: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var offsetY: CGFloat = 0
    @State private var timer: Timer? = nil

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.red) // Changed to blue for contrast
                .frame(width: 80 * scale, height:80 * scale)
                .offset(y: isPeeling ? -20 + offsetY : 0) // Move the circle up to simulate peeling
                .rotationEffect(.degrees(rotationAngle), anchor: .top) // Rotate for peeling effect
                .scaleEffect(isPeeling ? 1.05 : 1.0) // Scale effect for fluidity
                .animation(.easeInOut(duration: 0.3), value: isPeeling)

            // Parent layer (red) that stays in place
            Circle()
                .fill(Color.red)
                .frame(width: 120, height: 120)
                .cornerRadius(20)
                .border(.clear, width: 20)
        }
        .onTapGesture {
            isPeeling.toggle()
            if isPeeling {
                offsetY = 0
                timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                    rotationAngle += 10
                    // Add liquid-like bouncing effect
                    offsetY = sin(Double(rotationAngle) * .pi / 180) * 5 // Oscillate slightly
                    scale = 1 + 0.05 * sin(Double(rotationAngle) * .pi / 180) // Liquid scaling effect
                }
            } else {
                // Stop the rotation and reset the peeling effect
                timer?.invalidate()
                timer = nil
                rotationAngle = 0
                offsetY = 0
                scale = 1.0
            }
        }
    }
}

struct LiquidPeelAwayView_Previews: PreviewProvider {
    static var previews: some View {
        LiquidPeelAwayView()
    }
}
