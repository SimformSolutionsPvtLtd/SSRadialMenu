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
        switch self {
        case .topRight:
            baseAngle = .pi / 2
            angleRange = .pi / 2
        case .bottomRight:
            baseAngle = 3 * .pi / 2
            angleRange = -.pi / 2
        case .topLeft:
            baseAngle = 0
            angleRange = .pi / 2
        case .bottomLeft:
            baseAngle = 3 * .pi / 2
            angleRange = .pi / 2
        case .center:
            baseAngle = 0
            angleRange = 2 * .pi
        }

        let angle: CGFloat
        if self == .center {
            angle = (angleRange / CGFloat(totalItems)) * CGFloat(index)
        } else {
            angle = baseAngle + (angleRange / CGFloat(totalItems - 1)) * CGFloat(index)
        }
        let x = radius * cos(angle)
        let y = radius * sin(angle)
        return (x, y)
    }
}
