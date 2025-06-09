//
//  Constants.swift
//  SSRadialMenu
//
//  Created by GitHub Copilot on 06/01/25.
//

import SwiftUI

// MARK: - Centralized Constants for Performance Optimization
struct Constants {
    
    // MARK: - Animation Constants
    struct AnimationConstants {
        static let defaultDuration: Double = 0.5
        static let springResponse: Double = 0.4
        static let springResponseSlow: Double = 0.5
        static let dampingFraction: Double = 0.3
        static let sequentialDelay: Double = 0.2
        static let bounceDelay: Double = 0.1
        static let collapseDelay: Double = 0.25
        static let hideDelay: Double = 0.2
        static let hideAnimationDuration: Double = 0.4
        static let finalCleanupDelay: Double = 0.6
        
        // CircularView animation constants
        static let menuAnimationDuration: Double = 0.3
        static let itemSequenceDelay: Double = 0.25
        static let springAnimationResponse: Double = 0.6
        static let springAnimationDamping: Double = 0.7
        static let fadeInDuration: Double = 0.2
        static let fadeOutDuration: Double = 0.15
        static let momentumDuration: Double = 0.6
        static let momentumUpdateDelay: Double = 0.05
    }
    
    // MARK: - Layout Constants
    struct LayoutConstants {
        static let defaultRadius: CGFloat = 35.0
        static let primaryRadius: CGFloat = 115.0
        static let subMenuRadius: CGFloat = 180.0
        static let subSubMenuRadius: CGFloat = 240.0
        static let cardSizeMain: CGFloat = 55.0
        static let cardSizeSub: CGFloat = 45.0
        static let cardSizeSubSub: CGFloat = 35.0
        static let maxVisibleItems: Int = 6
        static let spacing: CGFloat = 10.0
        static let frameWidthLarge: CGFloat = 100.0
        static let frameHeightLarge: CGFloat = 100.0
    }
    
    // MARK: - Visual Constants
    struct VisualConstants {
        static let shadowRadius: CGFloat = 10.0
        static let shadowRadiusLarge: CGFloat = 15.0
        static let shadowYOffset: CGFloat = 5.0
        static let shadowYOffsetLarge: CGFloat = 10.0
        static let scaleEffectSmall: CGFloat = 0.8
        static let scaleEffectNormal: CGFloat = 1.0
        static let scaleEffectMinimal: CGFloat = 0.1
        static let scaleEffectZoomed: CGFloat = 1.15
        static let blurRadius: CGFloat = 8.0
        static let opacityFull: Double = 1.0
        static let opacityHidden: Double = 0.0
        static let opacityBackground: Double = 0.8
        static let cornerRadiusFactor: CGFloat = 0.5
        static let visibilityBufferMultiplier: Double = 0.8
        static let fadeMultiplier: Double = 0.9
        
        // Font sizing constants
        static let fontSizeSmall: CGFloat = 0.18
        static let fontSizeMedium: CGFloat = 0.20
        static let fontSizeLarge: CGFloat = 0.25
        
        // Badge sizing constants
        static let badgeSizeSmall: CGFloat = 0.40
        static let badgeSizeMedium: CGFloat = 0.50
        static let badgeSizeLarge: CGFloat = 0.30
        static let badgeSizeExtraLarge: CGFloat = 0.60
        static let badgeOffset: CGFloat = 18.0
    }
    
    // MARK: - Angle Constants
    struct AngleConstants {
        static let topLeadingOffset: Double = 100.0
        static let topTrailingOffset: Double = 280.0
        static let baseOffset: Double = 190.0
        static let fullCircle: Double = 360.0
        static let halfCircle: Double = 180.0
        static let quarterCircle: Double = 90.0
        static let totalSpan: Double = 160.0
        static let anglePerItem: Double = 50.0
        static let triangleDetectionThreshold: Double = 30.0
    }
    
    // MARK: - Performance Constants
    struct PerformanceConstants {
        static let minimumVisibleOpacity: Double = 0.05
        static let bufferItemCount: Int = 2
        static let momentumVelocityThreshold: CGFloat = 100.0
        static let scrollThresholdItemCount: Int = 6
    }
}

// MARK: - Legacy Constants for Backward Compatibility
typealias AnimationConstants = Constants.AnimationConstants
typealias LayoutConstants = Constants.LayoutConstants
typealias VisualConstants = Constants.VisualConstants
typealias AngleConstants = Constants.AngleConstants
typealias PerformanceConstants = Constants.PerformanceConstants
