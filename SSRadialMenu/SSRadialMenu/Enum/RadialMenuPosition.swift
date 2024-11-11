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
  
    func calculateOffset(radius: CGFloat, index: Int, totalItems: Int, overlapThreshold: CGFloat = 20) -> (CGFloat, CGFloat)? {
        let baseAngle: CGFloat
        let angleRange: CGFloat
        let isFullCircle = totalItems > 4

        // Define extra spacing factor for increased distance between items
        let extraSpacingFactor: CGFloat = 1.0

        // Calculate minimum required radius to prevent overlap
        let minRequiredRadius = calculateMinRadiusForItems(totalItems, overlapThreshold: overlapThreshold)

        // If the radius is too small, calculate how many items can fit within it
        if radius < minRequiredRadius {
            let maxItemsThatFit = Int(2 * .pi / (overlapThreshold / radius))      
            if index >= maxItemsThatFit {
                return nil
            }

            // Print the maximum number of items that can fit within the available radius
            print("Displaying item \(index + 1) out of \(totalItems). Maximum possible items: \(maxItemsThatFit).")
        }

        // Define base angle and angle range for each case (quadrant)
        switch self {
        case .topRight:
            baseAngle = 3 * .pi / 2
            angleRange = isFullCircle ? -2 * .pi : -.pi / 2
        case .bottomRight:
            baseAngle = 3 * .pi / 2
            angleRange = isFullCircle ? -2 * .pi : -.pi / 2
        case .topLeft:
            baseAngle = 0
            angleRange = isFullCircle ? 2 * .pi : .pi / 2
        case .bottomLeft:
            baseAngle = 3 * .pi / 2
            angleRange = isFullCircle ? 2 * .pi : .pi / 2
        case .center:
            baseAngle = 0
            angleRange = 2 * .pi
        }

        // Adjust angle step to prevent overlap by dividing the angle range based on total items
        let adjustedAngleRange = angleRange * extraSpacingFactor / CGFloat(totalItems)
        let angle = baseAngle + adjustedAngleRange * CGFloat(index)

        // Calculate x and y positions based on the radius and angle
        let x = radius * cos(angle)
        let y = radius * sin(angle)

        // Print x and y positions for debugging
//        print("x: \(x), y: \(y)")

        
        return (x, y)
    }

    // Helper function to calculate minimum required radius for a given number of items
    func calculateMinRadiusForItems(_ totalItems: Int, overlapThreshold: CGFloat) -> CGFloat {
        // Calculate the minimum radius based on overlap threshold and item spacing
        let anglePerItem = 2 * .pi / CGFloat(totalItems)
        let requiredRadius = (overlapThreshold / tan(anglePerItem / 2)) // Adjust based on angle spacing
        return requiredRadius
    }

}
