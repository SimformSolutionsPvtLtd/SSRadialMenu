//
//  CircularView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 02/12/24.
import SwiftUI

struct SSRadialMenu: View {
    let menuItems: [RadialMenuItems]
    var alignment: AlignmentType = .bottomTrailing
    let expandMenuIcon: String?
    let collapseMenuIcon: String?
    let expandMenuImage: String?
    let collapseMenuImage: String?
    let mainCardSize: CGFloat
    let spinsItemsDuringDrag: Bool
    let wrapEnabled: Bool
    let zoomEffectEnabled: Bool
    let zoomEffectScale: CGFloat?
    let zoomOpacityReduction: Double

    // MARK: - Icon-based Initializers
    
    /// Create a radial menu with SF Symbol icons for FAB buttons
    /// - Parameters:
    ///   - menuItems: Array of RadialMenuItems (can contain both icons and images)
    ///   - alignment: Alignment of the menu
    ///   - expandMenuIcon: SF Symbol name for the expand button
    ///   - collapseMenuIcon: SF Symbol name for the collapse button (optional)
    ///   - mainCardSize: Size of the main menu cards
    ///   - spinsItemsDuringDrag: Whether items spin during drag
    ///   - wrapEnabled: Whether wrapping is enabled for scrolling
    ///   - zoomEffectEnabled: Whether zoom effect is enabled
    ///   - zoomEffectScale: Scale factor for zoom effect
    ///   - zoomOpacityReduction: Opacity reduction for non-zoomed items
    init(menuItems: [RadialMenuItems],
         alignment: AlignmentType = .bottomTrailing,
         expandMenuIcon: String,
         collapseMenuIcon: String? = nil,
         mainCardSize: CGFloat = 55.0,
         spinsItemsDuringDrag: Bool = true,
         wrapEnabled: Bool = true,
         zoomEffectEnabled: Bool = true,
         zoomEffectScale: CGFloat? = nil,
         zoomOpacityReduction: Double = 0.3
    ) {
        self.menuItems = menuItems
        self.alignment = alignment
        self.expandMenuIcon = expandMenuIcon
        self.collapseMenuIcon = collapseMenuIcon
        self.expandMenuImage = nil
        self.collapseMenuImage = nil
        self.mainCardSize = mainCardSize
        self.spinsItemsDuringDrag = spinsItemsDuringDrag
        self.wrapEnabled = wrapEnabled
        self.zoomEffectEnabled = zoomEffectEnabled
        self.zoomEffectScale = zoomEffectScale
        self.zoomOpacityReduction = zoomOpacityReduction
    }

    // MARK: - Image-based Initializers
    
    /// Create a radial menu with asset images for FAB buttons
    /// - Parameters:
    ///   - menuItems: Array of RadialMenuItems (can contain both icons and images)
    ///   - alignment: Alignment of the menu
    ///   - expandMenuImage: Image asset name for the expand button
    ///   - collapseMenuImage: Image asset name for the collapse button (optional)
    ///   - mainCardSize: Size of the main menu cards
    ///   - spinsItemsDuringDrag: Whether items spin during drag
    ///   - wrapEnabled: Whether wrapping is enabled for scrolling
    ///   - zoomEffectEnabled: Whether zoom effect is enabled
    ///   - zoomEffectScale: Scale factor for zoom effect
    ///   - zoomOpacityReduction: Opacity reduction for non-zoomed items
    init(menuItems: [RadialMenuItems],
         alignment: AlignmentType = .bottomTrailing,
         expandMenuImage: String,
         collapseMenuImage: String? = nil,
         mainCardSize: CGFloat = 55.0,
         spinsItemsDuringDrag: Bool = true,
         wrapEnabled: Bool = true,
         zoomEffectEnabled: Bool = true,
         zoomEffectScale: CGFloat? = nil,
         zoomOpacityReduction: Double = 0.3
    ) {
        self.menuItems = menuItems
        self.alignment = alignment
        self.expandMenuIcon = nil
        self.collapseMenuIcon = nil
        self.expandMenuImage = expandMenuImage
        self.collapseMenuImage = collapseMenuImage
        self.mainCardSize = mainCardSize
        self.spinsItemsDuringDrag = spinsItemsDuringDrag
        self.wrapEnabled = wrapEnabled
        self.zoomEffectEnabled = zoomEffectEnabled
        self.zoomEffectScale = zoomEffectScale
        self.zoomOpacityReduction = zoomOpacityReduction
    }

    // Core UI State
    @State private var selectedItemName: String = "Default Item"
    @State private var showMenuCards: Bool = false
    @State private var showingSubMenuForIndex: Int? = nil
    @State private var showingSubSubMenuForIndex: (mainIndex: Int, subIndex: Int)? = nil
    @State private var zoomedItemIndex: Int? = nil // Track which main item is zoomed

    // Animation states consolidated
    @State private var animatedIndices: Set<Int> = []
    @State private var subMenuAnimatedIndices: Set<Int> = []
    @State private var subSubMenuAnimatedIndices: Set<Int> = []

    // Unified rotation and dragging states
    @State private var rotations: (main: Double, sub: Double, subSub: Double) = (0, 0, 0)
    @State private var startAngles: (main: Double, sub: Double, subSub: Double) = (0, 0, 0)
    @State private var isDragging: (main: Bool, sub: Bool, subSub: Bool) = (false, false, false)
    @State private var scaleEffects: (main: CGFloat, sub: CGFloat, subSub: CGFloat) = (1.0, 1.0, 1.0)

    // Constants
    private let radius: CGFloat = LayoutConstants.primaryRadius
    private let subMenuRadius: CGFloat = LayoutConstants.subMenuRadius
    private let subSubMenuRadius: CGFloat = LayoutConstants.subSubMenuRadius
    private let maxVisibleItems: Int = LayoutConstants.maxVisibleItems
    private let totalSpan: Double = AngleConstants.totalSpan

    // Computed properties
    var anglePerItem: Double { totalSpan / Double(maxVisibleItems - 1) }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)

            DebugInfoView(
                showMenuCards: showMenuCards,
                continuousRotation: rotations.main,
                itemCount: menuItems.count,
                isMainMenuScrollingEnabled: isScrollingEnabled(menuLevel: .main),
                anglePerItem: anglePerItem,
                animatedIndicesCount: animatedIndices.count,
                showingSubMenuForIndex: showingSubMenuForIndex,
                subMenuRotation: rotations.sub,
                subMenuItemsCount: showingSubMenuForIndex != nil ? (menuItems[showingSubMenuForIndex!].subMenuItems?.count ?? 0) : 0,
                isSubMenuScrollingEnabled: { index in isScrollingEnabled(menuLevel: .sub, mainIndex: index) },
                rotateSubMenuToPreviousItem: { rotateMenu(.sub, direction: .previous) },
                rotateSubMenuToNextItem: { rotateMenu(.sub, direction: .next) },
                rotateToPreviousItem: { rotateMenu(.main, direction: .previous) },
                rotateToNextItem: { rotateMenu(.main, direction: .next) }
            )

            GeometryReader { geometry in
                ZStack {
                    if showMenuCards {
                        createMenuView(for: .main)
                    }

                    if showingSubMenuForIndex != nil {
                        createMenuView(for: .sub, mainIndex: showingSubMenuForIndex!)
                    }

                    if let (mainIndex, subIndex) = showingSubSubMenuForIndex {
                        createMenuView(for: .subSub, mainIndex: mainIndex, subIndex: subIndex)
                    }

                    mainFabButton
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: alignment.toAlignment)
                .padding(.top, -20)
            }
        }
    }
}

// Menu View Creation - UI-related view building functions:
extension SSRadialMenu {
    // FAB Button
    @ViewBuilder
    private var mainFabButton: some View {
        Button(action: {
            if showingSubMenuForIndex != nil {
                closeSubMenu()
            }
            showMenuCards.toggle()
            if showMenuCards {
                resetAllScrollPositions()
                startSequentialAnimation(for: .main, itemCount: menuItems.count)
            } else {
                animatedIndices.removeAll()
                // Reset zoom effect when closing the menu, if enabled
                if zoomEffectEnabled {
                    zoomedItemIndex = nil
                }
            }
        }, label: {
            ZStack {
                // Collapse button (shown when menu is expanded)
                if collapseMenuIcon != nil || collapseMenuImage != nil {
                    Group {
                        if let collapseImage = collapseMenuImage {
                            // Use asset image for collapse button
                            Image(collapseImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                        } else if let collapseIcon = collapseMenuIcon {
                            // Use SF Symbol for collapse button
                            Image(systemName: collapseIcon)
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                    }
                    .opacity(showMenuCards ? 1.0 : 0.0)
                    .scaleEffect(showMenuCards ? 1.0 : 0.3)
                }

                // Expand button (shown when menu is collapsed)
                Group {
                    if let expandImage = expandMenuImage {
                        // Use asset image for expand button
                        Image(expandImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    } else if let expandIcon = expandMenuIcon {
                        // Use SF Symbol for expand button
                        Image(systemName: expandIcon)
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                }
                .opacity((showMenuCards && (collapseMenuIcon != nil || collapseMenuImage != nil)) ? 0.0 : 1.0)
                .scaleEffect((showMenuCards && (collapseMenuIcon != nil || collapseMenuImage != nil)) ? 0.3 : 1.0)
            }
        })
        .frame(width: 80, height: 80)
        .clipShape(Circle())
    }

    // Unified menu view creation
    @ViewBuilder
    private func createMenuView(for menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> some View {
        let visibleItems = getVisibleItems(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
        let currentAnimatedIndices = getCurrentAnimatedIndices(for: menuLevel)
        let currentRadius = getRadius(for: menuLevel)
        let currentDragging = getCurrentDragging(for: menuLevel)
        let currentScaleEffect = getCurrentScaleEffect(for: menuLevel)

        ZStack {
            ForEach(Array(visibleItems.enumerated()), id: \.element.index) { _, item in
                let (_, itemAngle, opacity) = calculateItemProperties(for: item, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)

                if shouldItemBeVisible(visualIndex: item.visualIndex, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex) && opacity > Constants.PerformanceConstants.minimumVisibleOpacity {
                    let initialPosition = getInitialPosition(for: item, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
                    let finalPosition = CGPoint(
                        x: currentRadius * cos(itemAngle * .pi / 180),
                        y: currentRadius * sin(itemAngle * .pi / 180)
                    )

                    let currentPosition = CGPoint(
                        x: currentAnimatedIndices.contains(item.visualIndex) ? finalPosition.x : initialPosition.x,
                        y: currentAnimatedIndices.contains(item.visualIndex) ? finalPosition.y : initialPosition.y
                    )

                    let progressiveOpacity = calculateProgressiveOpacity(
                        startPosition: initialPosition,
                        endPosition: finalPosition,
                        currentPosition: currentPosition,
                        isAnimated: currentAnimatedIndices.contains(item.visualIndex)
                    )

                    let baseOpacity = currentAnimatedIndices.contains(item.visualIndex) ? min(progressiveOpacity, opacity) : 0.0

                    // Apply zoom opacity reduction for non-zoomed items when zoom effect is active
                    let finalOpacity: Double = {
                        if zoomEffectEnabled && menuLevel == .main && zoomedItemIndex != nil {
                            if shouldApplyZoomEffect(menuLevel: menuLevel, itemIndex: item.index) {
                                // This is the zoomed item, keep full opacity
                                return baseOpacity
                            } else {
                                // This is a non-zoomed item, apply opacity reduction
                                return baseOpacity * (1.0 - zoomOpacityReduction)
                            }
                        } else {
                            // No zoom effect active, use base opacity
                            return baseOpacity
                        }
                    }()

                    MenuCard(
                        item: item.item,
                        itemNumber: menuLevel == .main ? item.index + 1 : nil,
                        hierarchicalIndex: getHierarchicalIndex(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex, itemIndex: item.index),
                        cardSize: getCardSize(for: menuLevel)
                    )
                    .rotationEffect(.degrees(spinsItemsDuringDrag ? -itemAngle : 0))
                    .offset(x: currentPosition.x, y: currentPosition.y)
                    .scaleEffect(shouldApplyZoomEffect(menuLevel: menuLevel, itemIndex: item.index) ?
                                getZoomScale() :
                                (currentAnimatedIndices.contains(item.visualIndex) ? currentScaleEffect : VisualConstants.scaleEffectMinimal))
                    .opacity(finalOpacity)
                    .animation(currentDragging ? .none : .spring(response: AnimationConstants.springResponseSlow, dampingFraction: AnimationConstants.springAnimationDamping), value: currentAnimatedIndices)
                    .animation(currentDragging ? .none : .linear(duration: AnimationConstants.fadeOutDuration), value: getCurrentRotation(for: menuLevel))
                    .animation(currentDragging ? .none : .spring(response: AnimationConstants.springAnimationResponse, dampingFraction: AnimationConstants.springAnimationDamping), value: currentScaleEffect)
                    .animation(zoomEffectEnabled && zoomEffectScale != 0 ?
                              .spring(response: 0.3, dampingFraction: 0.6) : .none, value: zoomedItemIndex)
                    .onTapGesture {
                        handleItemTap(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex, itemIndex: item.index, item: item.item)
                    }
                    .onChange(of: itemAngle) { _ in
                        if menuLevel == .main && isCardNearTriangle(itemAngle) {
                            selectedItemName = item.item.name
                        }
                    }
                }
            }
        }
        .gesture(createConditionalDragGesture(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex))
    }
}

// MenuCard Component - The MenuCard view builder function
extension SSRadialMenu {
    @ViewBuilder
    func MenuCard(item: RadialMenuItems, itemNumber: Int? = nil, hierarchicalIndex: String? = nil, cardSize: CGFloat = 55) -> some View {
        ZStack {
            // Support both SF Symbols (via icon) and asset images (via image)
            if let imageName = item.image {
                // Use asset image if provided
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cardSize, height: cardSize)
                    .clipShape(Circle())
                    .padding(cardSize * 0.07)
            } else {
                if let systemIcon = item.icon {
                    // Fallback to SF Symbol icon
                    Image(systemName: systemIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: cardSize * 0.6, height: cardSize * 0.6)
                        .foregroundColor(.white)
                        .padding(cardSize * 0.07)
                }
            }

            let displayText: String? = {
                if let badgeText = item.badgeText, !badgeText.isEmpty {
                    return badgeText
                } else {
                    return nil
                }
            }()

            let fontSize: CGFloat = {
                if displayText != nil {
                    if let hierarchicalIndex = hierarchicalIndex {
                        let levelCount = hierarchicalIndex.components(separatedBy: ".").count
                        switch levelCount {
                        case 2: return cardSize * VisualConstants.fontSizeMedium
                        case 3: return cardSize * VisualConstants.fontSizeSmall
                        default: return cardSize * VisualConstants.fontSizeLarge
                        }
                    } else {
                        return cardSize * VisualConstants.fontSizeLarge
                    }
                } else {
                    return 0
                }
            }()

            let badgeSize: CGFloat = {
                if displayText != nil {
                    if let hierarchicalIndex = hierarchicalIndex {
                        let levelCount = hierarchicalIndex.components(separatedBy: ".").count
                        switch levelCount {
                        case 2: return cardSize * VisualConstants.badgeSizeLarge
                        case 3: return cardSize * VisualConstants.badgeSizeExtraLarge
                        default: return cardSize * VisualConstants.badgeSizeMedium
                        }
                    } else {
                        return cardSize * VisualConstants.badgeSizeSmall
                    }
                } else {
                    return 0
                }
            }()

            let offsetMultiplier: CGFloat = cardSize / mainCardSize

            // Only show badge if displayText is not nil
            if let displayText = displayText {
                Text(displayText)
                    .font(.bold(.system(size: fontSize))())
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(VisualConstants.opacityBackground))
                            .frame(width: badgeSize, height: badgeSize)
                    )
                    .offset(x: VisualConstants.badgeOffset * offsetMultiplier, y: -VisualConstants.badgeOffset * offsetMultiplier)
            }
        }
    }
}

// Menu Configuration & Scrolling - Functions related to menu setup and scrolling behavior.
extension SSRadialMenu {
    private func isScrollingEnabled(menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> Bool {
        switch menuLevel {
        case .main:
            return menuItems.count > Constants.PerformanceConstants.scrollThresholdItemCount
        case .sub:
            guard mainIndex < menuItems.count,
                  let subItems = menuItems[mainIndex].subMenuItems else { return false }
            return subItems.count > Constants.PerformanceConstants.scrollThresholdItemCount
        case .subSub:
            guard mainIndex < menuItems.count,
                  let subItems = menuItems[mainIndex].subMenuItems,
                  subIndex < subItems.count,
                  let subSubItems = subItems[subIndex].subMenuItems else { return false }
            return subSubItems.count > Constants.PerformanceConstants.scrollThresholdItemCount
        }
    }

    private func getEffectiveSpan(itemCount: Int, isScrollable: Bool) -> Double {
        return isScrollable ? totalSpan : min(AngleConstants.totalSpan, Double(itemCount - 1) * anglePerItem)
    }

    private func getVisibleItems(for menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> [(item: RadialMenuItems, index: Int, visualIndex: Int)] {
        let (items, isScrollable, currentRotation): ([RadialMenuItems], Bool, Double) = {
            switch menuLevel {
            case .main:
                return (menuItems, isScrollingEnabled(menuLevel: .main), rotations.main)
            case .sub:
                guard let subItems = menuItems[mainIndex].subMenuItems else { return ([], false, 0) }
                return (subItems, isScrollingEnabled(menuLevel: .sub, mainIndex: mainIndex), rotations.sub)
            case .subSub:
                guard let subItems = menuItems[mainIndex].subMenuItems,
                      let subSubItems = subItems[subIndex].subMenuItems else { return ([], false, 0) }
                return (subSubItems, isScrollingEnabled(menuLevel: .subSub, mainIndex: mainIndex, subIndex: subIndex), rotations.subSub)
            }
        }()

        var result: [(item: RadialMenuItems, index: Int, visualIndex: Int)] = []

        if !isScrollable {
            for i in 0..<items.count {
                result.append((item: items[i], index: i, visualIndex: i))
            }
            return result
        }

        let floatingOffset = currentRotation / anglePerItem
        let bufferItems = Constants.PerformanceConstants.bufferItemCount
        let startIndex = Int(floor(floatingOffset)) - bufferItems
        let endIndex = startIndex + maxVisibleItems + (bufferItems * Constants.PerformanceConstants.bufferItemCount)

        if wrapEnabled {
            // With wrap enabled, we use modulo to wrap around the indices
            for i in startIndex...endIndex {
                let actualIndex = modulo(i, items.count)
                result.append((item: items[actualIndex], index: actualIndex, visualIndex: i))
            }
        } else {
            // Without wrap, we filter to only valid indices within the range
            for i in startIndex...endIndex {
                if i >= 0 && i < items.count {
                    result.append((item: items[i], index: i, visualIndex: i))
                }
            }
        }

        return result
    }

    private func modulo(_ a: Int, _ b: Int) -> Int {
        if wrapEnabled {
            let remainder = a % b
            return remainder >= 0 ? remainder : remainder + b
        } else {
            // When wrap is disabled, clamp the value to the valid range [0, b-1]
            return max(0, min(a, b - 1))
        }
    }
}

// Visibility & Opacity Calculations - Functions for item visibility and opacity
extension SSRadialMenu {
    private func shouldItemBeVisible(visualIndex: Int, menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> Bool {
        if !isScrollingEnabled(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex) {
            return true
        }

        let currentRotation: Double = {
            switch menuLevel {
            case .main: return rotations.main
            case .sub: return rotations.sub
            case .subSub: return rotations.subSub
            }
        }()

        let itemRotation = Double(visualIndex) * anglePerItem - currentRotation
        let normalizedRotation = ((itemRotation + AngleConstants.halfCircle).truncatingRemainder(dividingBy: AngleConstants.fullCircle)) - AngleConstants.halfCircle
        let visibilityThreshold = (totalSpan / 2) + (anglePerItem * VisualConstants.visibilityBufferMultiplier)
        return abs(normalizedRotation) <= visibilityThreshold
    }

    private func getItemOpacity(visualIndex: Int, menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> Double {
        if !isScrollingEnabled(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex) {
            return 1.0
        }

        let currentRotation: Double = {
            switch menuLevel {
            case .main: return rotations.main
            case .sub: return rotations.sub
            case .subSub: return rotations.subSub
            }
        }()

        let itemRotation = Double(visualIndex) * anglePerItem - currentRotation
        let normalizedRotation = ((itemRotation + AngleConstants.halfCircle).truncatingRemainder(dividingBy: AngleConstants.fullCircle)) - AngleConstants.halfCircle
        let coreDistance = totalSpan / 2
        let bufferDistance = coreDistance + (anglePerItem * VisualConstants.visibilityBufferMultiplier)
        let distance = abs(normalizedRotation)

        if distance <= coreDistance {
            return VisualConstants.opacityFull
        } else if distance <= bufferDistance {
            let fadeDistance = distance - coreDistance
            let fadeRange = bufferDistance - coreDistance
            let fadeRatio = fadeDistance / fadeRange
            return max(VisualConstants.opacityHidden, VisualConstants.opacityFull - (fadeRatio * VisualConstants.fadeMultiplier))
        } else {
            return VisualConstants.opacityHidden
        }
    }

    private func calculateProgressiveOpacity(startPosition: CGPoint, endPosition: CGPoint, currentPosition: CGPoint, isAnimated: Bool) -> Double {
        guard isAnimated else { return 0.0 }
        let totalDistance = hypot(endPosition.x - startPosition.x, endPosition.y - startPosition.y)
        guard totalDistance > 1.0 else { return 1.0 }
        let currentDistance = hypot(currentPosition.x - startPosition.x, currentPosition.y - startPosition.y)
        return min(currentDistance / totalDistance, 1.0)
    }
}

// Menu Level Helper Functions - Helper functions for different menu levels.
extension SSRadialMenu {
    // Helper methods for zoom effect
    private func shouldApplyZoomEffect(menuLevel: MenuLevel, itemIndex: Int) -> Bool {
        guard zoomEffectEnabled && zoomEffectScale != 0 && menuLevel == .main else {
            return false
        }
        return zoomedItemIndex == itemIndex
    }

    private func getZoomScale() -> CGFloat {
        return zoomEffectScale ?? VisualConstants.scaleEffectZoomed
    }

    private func getCurrentAnimatedIndices(for menuLevel: MenuLevel) -> Set<Int> {
        switch menuLevel {
        case .main: return animatedIndices
        case .sub: return subMenuAnimatedIndices
        case .subSub: return subSubMenuAnimatedIndices
        }
    }

    private func getCurrentRotation(for menuLevel: MenuLevel) -> Double {
        switch menuLevel {
        case .main: return rotations.main
        case .sub: return rotations.sub
        case .subSub: return rotations.subSub
        }
    }

    private func getCurrentDragging(for menuLevel: MenuLevel) -> Bool {
        switch menuLevel {
        case .main: return isDragging.main
        case .sub: return isDragging.sub
        case .subSub: return isDragging.subSub
        }
    }

    private func getCurrentScaleEffect(for menuLevel: MenuLevel) -> CGFloat {
        switch menuLevel {
        case .main: return scaleEffects.main
        case .sub: return scaleEffects.sub
        case .subSub: return scaleEffects.subSub
        }
    }

    private func getRadius(for menuLevel: MenuLevel) -> CGFloat {
        switch menuLevel {
        case .main: return radius
        case .sub: return subMenuRadius
        case .subSub: return subSubMenuRadius
        }
    }

    private func getCardSize(for menuLevel: MenuLevel) -> CGFloat {
        switch menuLevel {
        case .main: return mainCardSize
        case .sub: return mainCardSize * 0.82  // Sub cards are ~18% smaller than main
        case .subSub: return mainCardSize * 0.64  // Sub-sub cards are ~36% smaller than main
        }
    }

    private func getHierarchicalIndex(menuLevel: MenuLevel, mainIndex: Int, subIndex: Int, itemIndex: Int) -> String? {
        switch menuLevel {
        case .main: return nil
        case .sub: return "\(mainIndex + 1).\(itemIndex + 1)"
        case .subSub: return "\(mainIndex + 1).\(subIndex + 1).\(itemIndex + 1)"
        }
    }
}

// Item Properties & Position Calculations - Functions for calculating item properties and positions:
extension SSRadialMenu {
    private func calculateItemProperties(for item: (item: RadialMenuItems, index: Int, visualIndex: Int), menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> (rotation: Double, angle: Double, opacity: Double) {
        if !isScrollingEnabled(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex) {
            let staticItemRotation = Double(item.index) * anglePerItem
            let staticItemAngle = alignment.itemAngleForCarousel(rotation: staticItemRotation)
            return (staticItemRotation, staticItemAngle, 1.0)
        }

        let currentRotation = getCurrentRotation(for: menuLevel)
        let itemRotation = Double(item.visualIndex) * anglePerItem - currentRotation
        let itemAngle = alignment.itemAngleForCarousel(rotation: itemRotation)
        let opacity = getItemOpacity(visualIndex: item.visualIndex, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)

        return (itemRotation, itemAngle, opacity)
    }

    // Unified initial position calculation
    private func getInitialPosition(for item: (item: RadialMenuItems, index: Int, visualIndex: Int), menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> CGPoint {
        let visibleItems = getVisibleItems(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
        let sortedVisibleItems = visibleItems
            .filter { shouldItemBeVisible(visualIndex: $0.visualIndex, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex) }
            .sorted { $0.index < $1.index }

        guard let currentItemSequence = sortedVisibleItems.firstIndex(where: { $0.index == item.index }) else {
            return getDefaultInitialPosition(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
        }

        if currentItemSequence == 0 {
            return getDefaultInitialPosition(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
        } else {
            let previousItem = sortedVisibleItems[currentItemSequence - 1]
            let (_, previousItemAngle, _) = calculateItemProperties(for: previousItem, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
            let previousRadius = getRadius(for: menuLevel)

            return CGPoint(
                x: previousRadius * 2 * cos(previousItemAngle * .pi / 180),
                y: previousRadius * 2 * sin(previousItemAngle * .pi / 180)
            )
        }
    }

    private func getDefaultInitialPosition(for menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> CGPoint {
        switch menuLevel {
        case .main:
            return CGPoint.zero
        case .sub:
            let fixedMainItemAngle = getFixedMainItemAngle(for: mainIndex)
            return CGPoint(x: radius * 2.5 * cos(fixedMainItemAngle * .pi / 180), y: radius * 2.5 * sin(fixedMainItemAngle * .pi / 180))
        case .subSub:
            let parentSubMenuAngle: Double = {
                if isScrollingEnabled(menuLevel: .sub, mainIndex: mainIndex) {
                    let subItemRotation = Double(subIndex) * anglePerItem - rotations.sub
                    return alignment.itemAngleForCarousel(rotation: subItemRotation)
                } else {
                    let staticSubItemRotation = Double(subIndex) * anglePerItem
                    return alignment.itemAngleForCarousel(rotation: staticSubItemRotation)
                }
            }()
            return CGPoint(x: subMenuRadius * cos(parentSubMenuAngle * .pi / 180), y: subMenuRadius * sin(parentSubMenuAngle * .pi / 180))
        }
    }

    private func getFixedMainItemAngle(for itemIndex: Int) -> Double {
        let baseVisualIndex = itemIndex
        let itemRotation = Double(baseVisualIndex) * anglePerItem
        return alignment.itemAngleForCarousel(rotation: itemRotation)
    }
}

// Drag Gesture Handling - Functions for handling drag gestures and momentum:
extension SSRadialMenu {
    private func createConditionalDragGesture(for menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> AnyGesture<DragGesture.Value>? {
        let shouldEnableDrag = {
            switch menuLevel {
            case .main:
                return isScrollingEnabled(menuLevel: .main) && showingSubMenuForIndex == nil
            case .sub:
                return isScrollingEnabled(menuLevel: .sub, mainIndex: mainIndex) && showingSubSubMenuForIndex == nil
            case .subSub:
                return isScrollingEnabled(menuLevel: .subSub, mainIndex: mainIndex, subIndex: subIndex)
            }
        }()

        guard shouldEnableDrag else { return nil }

        return AnyGesture(DragGesture()
            .onChanged { value in
                setDragging(for: menuLevel, value: true)
                let delta = alignment.calculateDragDelta(translation: value.translation)
                var newRotation = getStartAngle(for: menuLevel) + delta

                // If wrap is disabled, ensure rotation stays within valid limits
                if !wrapEnabled {
                    let itemCount = getItemCountForMenu(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
                    if itemCount > 0 {
                        // Calculate the maximum rotation to ensure the last item can only slide to the edge
                        let maxRotation = Double(itemCount - 1) * anglePerItem - (totalSpan / 2)
                        // Limit rotation to prevent scrolling past the first or last item
                        newRotation = min(max(0, newRotation), maxRotation)
                    }
                }

                updateRotation(for: menuLevel, value: newRotation)
                updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
            }
            .onEnded { value in
                setDragging(for: menuLevel, value: false)
                updateStartAngle(for: menuLevel, value: getCurrentRotation(for: menuLevel))
                handleDragMomentum(velocity: value.velocity.width, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
            })
    }

    // Unified momentum handling
    private func handleDragMomentum(velocity: CGFloat, menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) {
        guard abs(velocity) > Constants.PerformanceConstants.momentumVelocityThreshold else {
            updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
            return
        }

        let momentumRotation = alignment.calculateMomentumRotation(velocity: velocity)
        let currentRotation = getCurrentRotation(for: menuLevel)
        var newRotation = currentRotation + momentumRotation

        // If wrap is disabled, ensure rotation stays within valid limits
        if !wrapEnabled {
            let itemCount = getItemCountForMenu(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
            if itemCount > 0 {
                // Calculate the maximum rotation to ensure the last item can only slide to the edge
                let maxRotation = Double(itemCount - 1) * anglePerItem - (totalSpan / 2)
                // Limit rotation to prevent scrolling past the first or last item
                newRotation = min(max(0, newRotation), maxRotation)
            }
        }

        withAnimation(.easeOut(duration: AnimationConstants.momentumDuration)) {
            updateRotation(for: menuLevel, value: newRotation)
            updateStartAngle(for: menuLevel, value: newRotation)
        }

        // Use Timer instead of DispatchQueue for better performance
        Timer.scheduledTimer(withTimeInterval: AnimationConstants.momentumUpdateDelay, repeats: false) { _ in
            updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
        }
    }

    // Helper function to get the item count for the current menu level
    private func getItemCountForMenu(menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> Int {
        switch menuLevel {
        case .main:
            return menuItems.count
        case .sub:
            guard mainIndex < menuItems.count, let subItems = menuItems[mainIndex].subMenuItems else { return 0 }
            return subItems.count
        case .subSub:
            guard mainIndex < menuItems.count,
                  let subItems = menuItems[mainIndex].subMenuItems,
                  subIndex < subItems.count,
                  let subSubItems = subItems[subIndex].subMenuItems else { return 0 }
            return subSubItems.count
        }
    }
}

// State Management - Functions for managing state across menu levels
extension SSRadialMenu {
    private func setDragging(for menuLevel: MenuLevel, value: Bool) {
        switch menuLevel {
            case .main: isDragging.main = value
            case .sub: isDragging.sub = value
            case .subSub: isDragging.subSub = value
        }
    }

    private func updateRotation(for menuLevel: MenuLevel, value: Double) {
        switch menuLevel {
            case .main: rotations.main = value
            case .sub: rotations.sub = value
            case .subSub: rotations.subSub = value
        }
    }

    private func getStartAngle(for menuLevel: MenuLevel) -> Double {
        switch menuLevel {
            case .main: return startAngles.main
            case .sub: return startAngles.sub
            case .subSub: return startAngles.subSub
        }
    }

    private func updateStartAngle(for menuLevel: MenuLevel, value: Double) {
        switch menuLevel {
            case .main: startAngles.main = value
            case .sub: startAngles.sub = value
            case .subSub: startAngles.subSub = value
        }
    }

    // Menu control functions
    private func closeSubMenu() {
        showingSubMenuForIndex = nil
        subMenuAnimatedIndices.removeAll()
        rotations.sub = 0.0
        startAngles.sub = 0.0

        // Reset zoom effect when closing submenu, if enabled
        if zoomEffectEnabled {
            zoomedItemIndex = nil
        }
        closeSubSubMenu()
    }

    private func closeSubSubMenu() {
        showingSubSubMenuForIndex = nil
        subSubMenuAnimatedIndices.removeAll()
        rotations.subSub = 0.0
        startAngles.subSub = 0.0
    }

    private func resetAllScrollPositions() {
        rotations = (0, 0, 0)
        startAngles = (0, 0, 0)
    }
}

// Item Tap Handling - Functions for handling item taps.
extension SSRadialMenu {
    private func handleItemTap(menuLevel: MenuLevel, mainIndex: Int, subIndex: Int, itemIndex: Int, item: RadialMenuItems) {
        switch menuLevel {
        case .main:
            handleMainItemTap(index: itemIndex, item: item)
        case .sub:
            handleSubItemTap(mainIndex: mainIndex, subIndex: itemIndex, item: item)
        case .subSub:
            selectedItemName = item.name
            closeSubSubMenu()
        }
    }

    private func handleMainItemTap(index: Int, item: RadialMenuItems) {
        if let currentOpen = showingSubMenuForIndex {
            if currentOpen == index {
                closeSubMenu()
                zoomedItemIndex = nil // Reset zoom when closing submenu
                return
            }
            closeSubMenu()
        }

        // Apply zoom effect to the tapped item if enabled
        if zoomEffectEnabled && zoomEffectScale != 0 {
            zoomedItemIndex = index
        }

        // Execute the provided action, if available
        item.action?()
        if let subItems = menuItems[index].subMenuItems, !subItems.isEmpty {
            showingSubMenuForIndex = index

            // If wrap is disabled, ensure the rotation starts at 0
            if !wrapEnabled {
                rotations.sub = 0.0
                startAngles.sub = 0.0
            }

            startSequentialAnimation(for: .sub, itemCount: subItems.count)
        } else {
            selectedItemName = menuItems[index].name

            // For items without submenus, remove zoom effect after a delay if enabled
            if zoomEffectEnabled && zoomEffectScale != 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if self.zoomedItemIndex == index {
                            self.zoomedItemIndex = nil
                        }
                    }
                }
            }
        }
    }

    private func handleSubItemTap(mainIndex: Int, subIndex: Int, item: RadialMenuItems) {
        if let currentOpen = showingSubSubMenuForIndex {
            if currentOpen.mainIndex == mainIndex && currentOpen.subIndex == subIndex {
                closeSubSubMenu()
                return
            }
            closeSubSubMenu()
        }

        // Execute the provided action, if available
        item.action?()
        if let subSubItems = item.subMenuItems, !subSubItems.isEmpty {
            showingSubSubMenuForIndex = (mainIndex: mainIndex, subIndex: subIndex)

            // If wrap is disabled, ensure the rotation starts at 0
            if !wrapEnabled {
                rotations.subSub = 0.0
                startAngles.subSub = 0.0
            }

            startSequentialAnimation(for: .subSub, itemCount: subSubItems.count)
        } else {
            selectedItemName = item.name
        }
    }
}

// Animation Management - Functions for managing animations.
extension SSRadialMenu {
    private func startSequentialAnimation(for menuLevel: MenuLevel, itemCount: Int) {
        clearAnimatedIndices(for: menuLevel)

        let visibleItems = getVisibleItems(for: menuLevel, mainIndex: showingSubMenuForIndex ?? 0, subIndex: showingSubSubMenuForIndex?.subIndex ?? 0)
        let sortedItems = visibleItems
            .filter { shouldItemBeVisible(visualIndex: $0.visualIndex, menuLevel: menuLevel, mainIndex: showingSubMenuForIndex ?? 0, subIndex: showingSubSubMenuForIndex?.subIndex ?? 0) }
            .sorted { $0.index < $1.index }

        // Use Timer for batch animation instead of multiple DispatchQueue calls
        for (sequenceIndex, item) in sortedItems.enumerated() {
            let delay = Double(sequenceIndex) * AnimationConstants.itemSequenceDelay
            Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                withAnimation(.spring(response: AnimationConstants.springAnimationResponse, dampingFraction: AnimationConstants.springAnimationDamping)) {
                    self.addToAnimatedIndices(visualIndex: item.visualIndex, menuLevel: menuLevel)
                }
            }
        }
    }

    private func clearAnimatedIndices(for menuLevel: MenuLevel) {
        switch menuLevel {
        case .main: animatedIndices.removeAll()
        case .sub: subMenuAnimatedIndices.removeAll()
        case .subSub: subSubMenuAnimatedIndices.removeAll()
        }
    }

    private func addToAnimatedIndices(visualIndex: Int, menuLevel: MenuLevel) {
        switch menuLevel {
        case .main: animatedIndices.insert(visualIndex)
        case .sub: subMenuAnimatedIndices.insert(visualIndex)
        case .subSub: subSubMenuAnimatedIndices.insert(visualIndex)
        }
    }

    // Unified visibility animation updates
    private func updateVisibleItemsAnimation(for menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) {
        let visibleItems = getVisibleItems(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
        var newAnimatedIndices = Set<Int>()

        for item in visibleItems {
            if shouldItemBeVisible(visualIndex: item.visualIndex, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex) {
                newAnimatedIndices.insert(item.visualIndex)
            }
        }

        let currentAnimatedIndices = getCurrentAnimatedIndices(for: menuLevel)
        let currentDragging = getCurrentDragging(for: menuLevel)

        if currentDragging {
            // Silent updates during dragging
            for visualIndex in newAnimatedIndices {
                if !currentAnimatedIndices.contains(visualIndex) {
                    addToAnimatedIndices(visualIndex: visualIndex, menuLevel: menuLevel)
                }
            }

            let indicesToRemove = currentAnimatedIndices.subtracting(newAnimatedIndices)
            for visualIndex in indicesToRemove {
                removeFromAnimatedIndices(visualIndex: visualIndex, menuLevel: menuLevel)
            }
        } else {
            // Animated updates when not dragging
            for visualIndex in newAnimatedIndices {
                if !currentAnimatedIndices.contains(visualIndex) {
                    withAnimation(.easeIn(duration: AnimationConstants.fadeInDuration)) {
                        addToAnimatedIndices(visualIndex: visualIndex, menuLevel: menuLevel)
                    }
                }
            }

            let indicesToRemove = currentAnimatedIndices.subtracting(newAnimatedIndices)
            for visualIndex in indicesToRemove {
                withAnimation(.easeOut(duration: AnimationConstants.fadeOutDuration)) {
                    removeFromAnimatedIndices(visualIndex: visualIndex, menuLevel: menuLevel)
                }
            }
        }
    }

    private func removeFromAnimatedIndices(visualIndex: Int, menuLevel: MenuLevel) {
        switch menuLevel {
        case .main: animatedIndices.remove(visualIndex)
        case .sub: subMenuAnimatedIndices.remove(visualIndex)
        case .subSub: subSubMenuAnimatedIndices.remove(visualIndex)
        }
    }
}

// Menu Details & Card Detection - Functions for menu details and card detection
extension SSRadialMenu {
    private func updateMenuDetailsForCarousel() {
        let visibleItems = getVisibleItems(for: .main)
        var closestItem: (item: RadialMenuItems, index: Int, visualIndex: Int)?
        var smallestDistance: Double = Double.infinity

        for item in visibleItems {
            if shouldItemBeVisible(visualIndex: item.visualIndex, menuLevel: .main) {
                let itemRotation = Double(item.visualIndex) * anglePerItem - rotations.main
                let itemAngle = alignment.itemAngleForCarousel(rotation: itemRotation)

                if isCardNearTriangle(itemAngle) {
                    let distance = abs(itemRotation)
                    if distance < smallestDistance {
                        smallestDistance = distance
                        closestItem = item
                    }
                }
            }
        }

        if let item = closestItem {
            selectedItemName = item.item.name
        }
    }

    private func isCardNearTriangle(_ itemAngle: Double) -> Bool {
        let triangleAngle = AngleConstants.quarterCircle * 3  // 270 degrees
        let threshold: Double = AngleConstants.triangleDetectionThreshold
        let normalizedItemAngle = (itemAngle + AngleConstants.fullCircle).truncatingRemainder(dividingBy: AngleConstants.fullCircle)
        let normalizedTriangleAngle = (triangleAngle + AngleConstants.fullCircle).truncatingRemainder(dividingBy: AngleConstants.fullCircle)
        let angleDifference = abs(normalizedItemAngle - normalizedTriangleAngle)
        return angleDifference <= threshold || angleDifference >= (AngleConstants.fullCircle - threshold)
    }
}

// Menu Rotation Controls - Functions for rotating menus.
extension SSRadialMenu {
    private func rotateMenu(_ menuLevel: MenuLevel, direction: RotationDirection) {
        let rotationChange = direction == .next ? anglePerItem : -anglePerItem
        let currentRotation = getCurrentRotation(for: menuLevel)
        var newRotation = currentRotation + rotationChange

        // Get the appropriate indices based on menu level
        let mainIndex: Int
        let subIndex: Int

        switch menuLevel {
        case .main:
            mainIndex = 0
            subIndex = 0
        case .sub:
            mainIndex = showingSubMenuForIndex ?? 0
            subIndex = 0
        case .subSub:
            mainIndex = showingSubMenuForIndex ?? 0
            subIndex = showingSubSubMenuForIndex?.subIndex ?? 0
        }

        // If wrap is disabled, limit the rotation
        if !wrapEnabled {
            let itemCount = getItemCountForMenu(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)

            // Calculate rotation limits
            if itemCount > 0 {
                let maxRotation = Double(itemCount - 1) * anglePerItem - (totalSpan / 2)
                // Prevent scrolling past boundaries
                newRotation = min(max(0, newRotation), maxRotation)

                // If we're already at a boundary, don't animate if trying to go beyond
                if (direction == .previous && currentRotation <= 0) ||
                   (direction == .next && currentRotation >= maxRotation) {
                    return
                }
            }
        }

        withAnimation(.easeInOut(duration: AnimationConstants.menuAnimationDuration)) {
            updateRotation(for: menuLevel, value: newRotation)
            updateStartAngle(for: menuLevel, value: newRotation)
        }

        updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
    }
}
