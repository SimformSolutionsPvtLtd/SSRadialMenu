//
//  AlignmentType.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 04/06/25.
//

import SwiftUI

// MARK: - Scrolling Behavior
/// Scrolling behavior types for radial menu
enum ScrollingBehavior {
    case simple
    case spinWheel
}

// MARK: - Spin Wheel Speed
/// Speed settings for spin wheel behavior
enum SpinWheelSpeed {
    case slow
    case normal
    case fast
    
    /// Speed multiplier for momentum calculations
    var speedMultiplier: Double {
        switch self {
        case .slow:
            return 0.75
        case .normal:
            return 1.0
        case .fast:
            return 1.5
        }
    }
    
    /// Velocity multiplier for drag sensitivity
    var velocityMultiplier: Double {
        switch self {
        case .slow:
            return 0.025
        case .normal:
            return 0.035
        case .fast:
            return 0.055
        }
    }
    
    /// Maximum momentum velocity
    var maxVelocity: Double {
        switch self {
        case .slow:
            return 6.0
        case .normal:
            return 8.0
        case .fast:
            return 12.0
        }
    }
}

// MARK: - Alignment Type
/// Alignment positions for radial menu
enum AlignmentType {
    case topLeading, topTrailing, bottomLeading, bottomTrailing

    /// Converts alignment type to SwiftUI Alignment
    var toAlignment: Alignment {
        switch self {
        case .topLeading:
                .topLeading
        case .topTrailing:
                .topTrailing
        case .bottomLeading:
                .bottomLeading
        case .bottomTrailing:
                .bottomTrailing
        }
    }
    
    /// Calculates item angle for legacy menu system
    func itemAngle(index: Int, angle: Double, anglePerItem: Double) -> Double {
        switch self {
        case .topLeading:
            -(anglePerItem * Double(index) + 100 + angle - 190.0).truncatingRemainder(dividingBy: 360.0)
        case .topTrailing:
            (anglePerItem * Double(index) + 280 + angle - 190.0).truncatingRemainder(dividingBy: 360.0)
        case .bottomLeading:
            (anglePerItem * Double(index) + 100 + angle - 190.0).truncatingRemainder(dividingBy: 360.0)
        case .bottomTrailing:
            -(anglePerItem * Double(index) + 280 + angle - 190.0).truncatingRemainder(dividingBy: 360.0)
        }
    }
    
    /// Calculates item angle for carousel system
    func itemAngleForCarousel(rotation: Double) -> Double {
        switch self {
        case .topLeading:
            -(rotation + 100 - 190.0).truncatingRemainder(dividingBy: 360.0)
        case .topTrailing:
            (rotation + 280 - 190.0).truncatingRemainder(dividingBy: 360.0)
        case .bottomLeading:
            (rotation + 100 - 190.0).truncatingRemainder(dividingBy: 360.0)
        case .bottomTrailing:
            -(rotation + 280 - 190.0).truncatingRemainder(dividingBy: 360.0)
        }
    }
    
    /// Calculates drag delta for rotation
    func calculateDragDelta(translation: CGSize, sensitivity: Double = 1.2) -> Double {
        // Very low sensitivity for much slower and more controlled dragging
        let rawDelta = Double(translation.width) * sensitivity
        
        switch self {
        case .topLeading, .bottomLeading:
            return -rawDelta
        case .topTrailing, .bottomTrailing:
            return rawDelta
        }
    }
    
    /// Calculates momentum rotation from velocity
    func calculateMomentumRotation(velocity: CGFloat, factor: Double = 0.004) -> Double {
        let rawMomentum = Double(velocity) * factor

        switch self {
        case .topLeading, .bottomLeading:
            return -rawMomentum
        case .topTrailing, .bottomTrailing:
            return rawMomentum
        }
    }
}

// MARK: - Menu Type
/// Hierarchical menu types
enum MenuType {
    case main, sub, subSub
}

// MARK: - Menu Level
/// Menu depth levels for navigation
enum MenuLevel {
    case main, sub, subSub
}

// MARK: - Rotation Direction
/// Rotation directions for menu navigation
enum RotationDirection {
    case next, previous
}
