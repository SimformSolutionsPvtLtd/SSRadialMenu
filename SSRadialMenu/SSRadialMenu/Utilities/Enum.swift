//
//  AlignmentType.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 04/06/25.
//

import SwiftUI

enum ScrollingBehavior {
    case simple
    case spinWheel
}

enum AlignmentType {
    case topLeading, topTrailing, bottomLeading, bottomTrailing

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
    
    // Legacy function for compatibility
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
    
    // Enhanced function for carousel system
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
    
    // Helper function to calculate momentum rotation based on alignment
    func calculateMomentumRotation(velocity: CGFloat, factor: Double = 0.004) -> Double {
        // Very slow momentum calculation for controlled regular scrolling
        let rawMomentum = Double(velocity) * factor
        
        // Use the same directional logic as drag delta for consistency
        switch self {
        case .topLeading, .bottomLeading:
            return -rawMomentum  // Same as drag delta: negative
        case .topTrailing, .bottomTrailing:
            return rawMomentum   // Same as drag delta: positive
        }
    }
}

enum MenuType {
    case main, sub, subSub
}

enum MenuLevel {
    case main, sub, subSub
}

enum RotationDirection {
    case next, previous
}
