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

    func calculateOffset(radius: CGFloat, index: Int, totalItems: Int) -> (CGFloat, CGFloat) {
        let baseAngle: CGFloat
        let angleRange: CGFloat
        let isFullCircle = totalItems > 4

        let extraSpacingFactor: CGFloat = 1.1 // Adjust this factor to increase spacing

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

        // Adjust angle per item with extra spacing
        let angle = baseAngle + (angleRange * extraSpacingFactor / CGFloat(isFullCircle ? totalItems : totalItems - 1)) * CGFloat(index)
        let x = radius * cos(angle)
        let y = radius * sin(angle)
        return (x, y)
    }
}
