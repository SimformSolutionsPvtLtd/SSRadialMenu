//
//  RadialMenuPosition.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 04/11/24.
//

import SwiftUI

enum Position {
    case topRight, bottomRight, topLeft, bottomLeft, center

    var floatingButtonAlignment: Alignment {
        switch self {
        case .topRight:
                .topTrailing
        case .bottomRight:
                .bottomTrailing
        case .topLeft:
                .topLeading
        case .bottomLeft:
                .bottomLeading
        case .center:
                .center
        }
    }
  
    func calculateOffset(radius: CGFloat, index: Int, totalItems: Int, peelingAngle: CGFloat = .zero, overlapThreshold: CGFloat = 20) -> (CGFloat, CGFloat)? {
        let baseAngle: CGFloat
        let angleRange: CGFloat
        let isFullCircle = totalItems > 4

        // Dynamically calculate extra spacing factor for fewer items
        let extraSpacingFactor: CGFloat = totalItems <= 4 ? 1.3 + (4 - CGFloat(totalItems)) * 0.4 : 1.0

        // Calculate minimum required radius to prevent overlap
        let minRequiredRadius = calculateMinRadiusForItems(totalItems, overlapThreshold: overlapThreshold)

        // Limit the number of items that can fit if radius is too small
        if radius < minRequiredRadius {
            let maxItemsThatFit = Int(2 * .pi / (overlapThreshold / radius))
            if index >= maxItemsThatFit {
                return nil
            }
        }

        // Define base angle and angle range for each quadrant
        switch self {
        case .topRight:
            baseAngle = 3 * .pi / 2 + peelingAngle  // Adjust by peeling angle
            angleRange = isFullCircle ? -2 * .pi : -.pi / 2
        case .bottomRight:
            baseAngle = 3 * .pi / 2 + peelingAngle
            angleRange = isFullCircle ? -2 * .pi : -.pi / 2
        case .topLeft:
            baseAngle = 0 + peelingAngle
            angleRange = isFullCircle ? 2 * .pi : .pi / 2
        case .bottomLeft:
            baseAngle = 3 * .pi / 2 + peelingAngle
            angleRange = isFullCircle ? 2 * .pi : .pi / 2
        case .center:
            baseAngle = 0 + peelingAngle
            angleRange = 2 * .pi
        }

        // Adjust angle step for spacing based on total items and spacing factor
        let adjustedAngleRange = angleRange * extraSpacingFactor / CGFloat(totalItems)
        let angle = baseAngle + adjustedAngleRange * CGFloat(index)

        // Calculate x and y positions based on the radius and angle
        let x = radius * cos(angle)
        let y = radius * sin(angle)
        return (x, y)
    }

    // Helper function to calculate minimum required radius for a given number of items
    func calculateMinRadiusForItems(_ totalItems: Int, overlapThreshold: CGFloat) -> CGFloat {
        // Calculate minimum radius based on overlap threshold and item spacing
        let anglePerItem = 2 * .pi / CGFloat(totalItems)
        let requiredRadius = overlapThreshold / tan(anglePerItem / 2)
        return requiredRadius
    }
    

}
