//
//  CircularView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 02/12/24.
import SwiftUI

// MARK: - High-performance radial menu with multi-level navigation and smooth animations
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
    let scrollThresholdItemCount: Int
    let scrollingBehavior: ScrollingBehavior
    let spinWheelSpeed: SpinWheelSpeed

    // Selection tracking closures
    let onMainMenuSelection: ((RadialMenuItems) -> Void)?
    let onSubMenuSelection: ((RadialMenuItems) -> Void)?
    let onSubSubMenuSelection: ((RadialMenuItems) -> Void)?

    /// Creates a radial menu with customization options
    init(menuItems: [RadialMenuItems],
         alignment: AlignmentType = .bottomTrailing,
         expandMenuIcon: String? = nil,
         expandMenuImage: String? = nil,
         collapseMenuIcon: String? = nil,
         collapseMenuImage: String? = nil,
         mainCardSize: CGFloat = 55.0,
         spinsItemsDuringDrag: Bool = true,
         wrapEnabled: Bool = true,
         zoomEffectEnabled: Bool = true,
         zoomEffectScale: CGFloat? = nil,
         zoomOpacityReduction: Double = 0.3,
         scrollThresholdItemCount: Int = PerformanceConstants.scrollThresholdItemCount,
         scrollingBehavior: ScrollingBehavior = .simple,
         spinWheelSpeed: SpinWheelSpeed = .normal,
         onMainMenuSelection: ((RadialMenuItems) -> Void)? = nil,
         onSubMenuSelection: ((RadialMenuItems) -> Void)? = nil,
         onSubSubMenuSelection: ((RadialMenuItems) -> Void)? = nil
    ) {
        self.menuItems = menuItems
        self.alignment = alignment
        self.expandMenuIcon = expandMenuIcon
        self.collapseMenuIcon = collapseMenuIcon
        self.expandMenuImage = expandMenuImage
        self.collapseMenuImage = collapseMenuImage
        self.mainCardSize = mainCardSize
        self.spinsItemsDuringDrag = spinsItemsDuringDrag
        self.wrapEnabled = wrapEnabled
        self.zoomEffectEnabled = zoomEffectEnabled
        self.zoomEffectScale = zoomEffectScale
        self.zoomOpacityReduction = zoomOpacityReduction
        self.scrollThresholdItemCount = scrollThresholdItemCount
        self.scrollingBehavior = scrollingBehavior
        self.spinWheelSpeed = spinWheelSpeed
        self.onMainMenuSelection = onMainMenuSelection
        self.onSubMenuSelection = onSubMenuSelection
        self.onSubSubMenuSelection = onSubSubMenuSelection
    }

    // MARK: - Optimised State Management
    /// Animation and interaction state for menu levels, It groups all the animation and interaction state variables for each menu level (main, sub, sub-sub) into a single, organized structure instead of having scattered individual @State variables.
    private struct MenuState {
        var rotation: Double = 0, startAngle: Double = 0
        var isDragging: Bool = false, scaleEffect: CGFloat = 1.0
        var animatedIndices: Set<Int> = [], momentumVelocity: Double = 0
        var isMomentumActive: Bool = false

        /// Resets all state to defaults
        mutating func reset() {
            (rotation, startAngle, isDragging, scaleEffect) = (0, 0, false, 1.0)
            animatedIndices.removeAll()
            stopMomentum()
        }

        /// Stops momentum without affecting other properties
        mutating func stopMomentum() {
            (momentumVelocity, isMomentumActive) = (0, false)
        }
    }

    /// Performance cache for computed values, The radial menu frequently needs to calculate which menu items are visible and their positions. Since these calculations involve complex trigonometry and array operations, caching the results dramatically improves performance.
    private struct ComputationCache {
        var lastMenuLevel: MenuLevel?, lastMainIndex: Int?, lastSubIndex: Int?
        var cachedVisibleItems: [(item: RadialMenuItems, index: Int, visualIndex: Int)] = []
        var cacheValidation: String = ""

        /// Invalidates cache forcing fresh computation
        mutating func invalidate() {
            (lastMenuLevel, lastMainIndex, lastSubIndex, cacheValidation) = (nil, nil, nil, "")
            cachedVisibleItems.removeAll()
        }

        /// Checks if cached data is valid for parameters
        func isValid(for menuLevel: MenuLevel, mainIndex: Int, subIndex: Int, rotation: Double) -> Bool {
            let currentValidation = "\(menuLevel)-\(mainIndex)-\(subIndex)-\(Int(rotation))"
            return lastMenuLevel == menuLevel && lastMainIndex == mainIndex && 
                   lastSubIndex == subIndex && cacheValidation == currentValidation
        }

        /// Updates cache with fresh computation results
        mutating func update(for menuLevel: MenuLevel, mainIndex: Int, subIndex: Int, rotation: Double, items: [(item: RadialMenuItems, index: Int, visualIndex: Int)]) {
            (lastMenuLevel, lastMainIndex, lastSubIndex) = (menuLevel, mainIndex, subIndex)
            cacheValidation = "\(menuLevel)-\(mainIndex)-\(subIndex)-\(Int(rotation))"
            cachedVisibleItems = items
        }
    }

    // Core UI State
    @State private var selectedItemName: String = "Default Item"
    @State private var showMenuCards: Bool = false
    @State private var showingSubMenuForIndex: Int? = nil
    @State private var showingSubSubMenuForIndex: (mainIndex: Int, subIndex: Int)? = nil
    @State private var zoomedItemIndex: Int? = nil // Track which main item is zoomed

    // Selection tracking for each layer
    @State private var selectedMainMenuItem: RadialMenuItems? = nil
    @State private var selectedSubMenuItem: RadialMenuItems? = nil
    @State private var selectedSubSubMenuItem: RadialMenuItems? = nil

    // Optimized state management using consolidated structures
    @State private var mainMenuState = MenuState()
    @State private var subMenuState = MenuState()
    @State private var subSubMenuState = MenuState()
    @State private var computationCache = ComputationCache()
    
    // DisplayLink-based momentum animation coordinator
    @StateObject private var momentumCoordinator = MomentumAnimationCoordinator()

    // Constants - Pre-computed for better performance
    private let radius: CGFloat = LayoutConstants.primaryRadius
    private let subMenuRadius: CGFloat = LayoutConstants.subMenuRadius
    private let subSubMenuRadius: CGFloat = LayoutConstants.subSubMenuRadius
    private let maxVisibleItems: Int = LayoutConstants.maxVisibleItems
    private let totalSpan: Double = AngleConstants.totalSpan

    // Pre-computed constants for performance
    private let subCardSizeMultiplier: CGFloat = 0.82
    private let subSubCardSizeMultiplier: CGFloat = 0.64
    private let halfCircle: Double = AngleConstants.halfCircle
    private let fullCircle: Double = AngleConstants.fullCircle
    private let visibilityBufferMultiplier: Double = VisualConstants.visibilityBufferMultiplier

    /// Angular spacing between menu items
    var anglePerItem: Double { totalSpan / Double(maxVisibleItems - 1) }

    /// Currently selected main menu item
    var currentSelectedMainItem: RadialMenuItems? { selectedMainMenuItem }
    
    /// Currently selected sub menu item
    var currentSelectedSubItem: RadialMenuItems? { selectedSubMenuItem }
    
    /// Currently selected sub-sub menu item
    var currentSelectedSubSubItem: RadialMenuItems? { selectedSubSubMenuItem }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)

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

// MARK: - Menu View Creation - UI-related view building functions
extension SSRadialMenu {
    /// Creates main FAB button with expand/collapse functionality
    @ViewBuilder
    private var mainFabButton: some View {
        Button(action: {
            if showingSubMenuForIndex != nil { closeSubMenu() }
            showMenuCards.toggle()
            if showMenuCards {
                resetAllScrollPositions()
                startSequentialAnimation(for: .main, itemCount: menuItems.count)
            } else {
                mainMenuState.animatedIndices.removeAll()
                (selectedMainMenuItem, selectedSubMenuItem, selectedSubSubMenuItem) = (nil, nil, nil)
                if zoomEffectEnabled { zoomedItemIndex = nil }
            }
        }, label: {
            ZStack {
                createFabIcon(isCollapse: true)
                createFabIcon(isCollapse: false)
            }
        })
        .frame(width: 80, height: 80)
        .clipShape(Circle())
    }
    
    /// Creates individual FAB icons with state transitions
    @ViewBuilder
    private func createFabIcon(isCollapse: Bool) -> some View {
        let (icon, image) = isCollapse ? (collapseMenuIcon, collapseMenuImage) : (expandMenuIcon, expandMenuImage)
        let hasAlternative = isCollapse ? (collapseMenuIcon != nil || collapseMenuImage != nil) : false
        let shouldShow = isCollapse ? showMenuCards : (!showMenuCards || !hasAlternative)
        let opacity = isCollapse ? (showMenuCards ? 1.0 : 0.0) : (shouldShow ? 1.0 : 0.0)
        let scale = isCollapse ? (showMenuCards ? 1.0 : 0.3) : (shouldShow ? 1.0 : 0.3)
        
        Group {
            if let icon = icon {
                Image(systemName: icon).resizable().frame(width: 50, height: 50)
            } else if let image = image {
                Image(image).resizable().aspectRatio(contentMode: .fill).frame(width: 50, height: 50).clipShape(Circle())
            }
        }
        .opacity(opacity)
        .scaleEffect(scale)
    }

    /// Creates radial menu view for specific level with visual effects
    @ViewBuilder
    private func createMenuView(for menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> some View {
        let visibleItems = getVisibleItems(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
        let currentAnimatedIndices = animatingItemIndices(for: menuLevel)
        let currentRadius = getRadius(for: menuLevel)
        let currentDragging = isMenuBeingDragged(for: menuLevel)
        let currentScaleEffect = menuScaleEffect(for: menuLevel)

        ZStack {
            ForEach(Array(visibleItems.enumerated()), id: \.element.visualIndex) { _, item in
                let (_, itemAngle, opacity) = calculateItemProperties(for: item, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)

                if shouldItemBeVisible(visualIndex: item.visualIndex, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex) && opacity > Constants.PerformanceConstants.minimumVisibleOpacity {
                    let initialPosition = getInitialPosition(for: item, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
                    let finalPosition = CGPoint(
                        x: currentRadius * cos(itemAngle * .pi / 180),
                        y: currentRadius * sin(itemAngle * .pi / 180)
                    )

                    // For fast speed momentum, always use final position to maintain consistent radius
                    let isFastMomentum = getMomentumActive(for: menuLevel) && scrollingBehavior == .spinWheel && (spinWheelSpeed == .fast)
                    
                    let currentPosition = CGPoint(
                        x: (currentAnimatedIndices.contains(item.visualIndex) || isFastMomentum) ? finalPosition.x : initialPosition.x,
                        y: (currentAnimatedIndices.contains(item.visualIndex) || isFastMomentum) ? finalPosition.y : initialPosition.y
                    )

                    let progressiveOpacity = calculateProgressiveOpacity(
                        startPosition: initialPosition,
                        endPosition: finalPosition,
                        currentPosition: currentPosition,
                        isAnimated: currentAnimatedIndices.contains(item.visualIndex)
                    )

                    let baseOpacity = (currentAnimatedIndices.contains(item.visualIndex) || isFastMomentum) ? min(progressiveOpacity, opacity) : 0.0

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
                    .animation((currentDragging || isFastMomentum) ? .none : .spring(response: AnimationConstants.springResponseSlow, dampingFraction: AnimationConstants.springAnimationDamping), value: currentAnimatedIndices)
                    .animation((currentDragging || isFastMomentum) ? .none : .linear(duration: AnimationConstants.fadeOutDuration), value: menuRotation(for: menuLevel))
                    .animation((currentDragging || isFastMomentum) ? .none : .spring(response: AnimationConstants.springAnimationResponse, dampingFraction: AnimationConstants.springAnimationDamping), value: currentScaleEffect)
                    .animation(zoomEffectEnabled && zoomEffectScale != 0 ?
                              .spring(response: 0.3, dampingFraction: 0.6) : .none, value: zoomedItemIndex)
                    .onTapGesture {
                        handleItemTap(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex, itemIndex: item.index, item: item.item)
                    }
                    .onChange(of: itemAngle) {
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

// MARK: - MenuCard Component - Optimized card view builder
extension SSRadialMenu {
    /// Creates menu cards with icons, images, and badges
    func MenuCard(item: RadialMenuItems, itemNumber: Int? = nil, hierarchicalIndex: String? = nil, cardSize: CGFloat = 55) -> some View {
        ZStack {
            if let imageName = item.image {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cardSize, height: cardSize)
                    .clipShape(Circle())
                    .padding(cardSize * 0.07)
            } else if let systemIcon = item.icon {
                Image(systemName: systemIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: cardSize * 0.6, height: cardSize * 0.6)
                    .foregroundColor(.white)
                    .padding(cardSize * 0.07)
            }

            // Optimized badge rendering
            if let badgeText = item.badgeText, !badgeText.isEmpty {
                let (fontSize, badgeSize) = calculateBadgeMetrics(cardSize: cardSize, hierarchicalIndex: hierarchicalIndex)
                
                Text(badgeText)
                    .font(.bold(.system(size: fontSize))())
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(VisualConstants.opacityBackground))
                            .frame(width: badgeSize, height: badgeSize)
                    )
                    .offset(x: VisualConstants.badgeOffset * (cardSize / mainCardSize), 
                           y: -VisualConstants.badgeOffset * (cardSize / mainCardSize))
            }
        }
    }
    
    /// Calculates badge sizing based on hierarchy level
    private func calculateBadgeMetrics(cardSize: CGFloat, hierarchicalIndex: String?) -> (fontSize: CGFloat, badgeSize: CGFloat) {
        let levelCount = hierarchicalIndex?.components(separatedBy: ".").count ?? 1
        
        let fontMultiplier: CGFloat
        let sizeMultiplier: CGFloat
        
        switch levelCount {
        case 2: (fontMultiplier, sizeMultiplier) = (VisualConstants.fontSizeMedium, VisualConstants.badgeSizeLarge)
        case 3: (fontMultiplier, sizeMultiplier) = (VisualConstants.fontSizeSmall, VisualConstants.badgeSizeExtraLarge)
        default: (fontMultiplier, sizeMultiplier) = hierarchicalIndex != nil ? 
                    (VisualConstants.fontSizeLarge, VisualConstants.badgeSizeMedium) : 
                    (VisualConstants.fontSizeLarge, VisualConstants.badgeSizeSmall)
        }
        
        return (cardSize * fontMultiplier, cardSize * sizeMultiplier)
    }
}

// MARK: - Menu Configuration & Scrolling - Functions related to menu setup and scrolling behavior
extension SSRadialMenu {
    /// Determines if scrolling should be enabled for menu level
    private func isScrollingEnabled(menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> Bool {
        switch menuLevel {
        case .main:
            return menuItems.count > scrollThresholdItemCount
        case .sub:
            guard mainIndex < menuItems.count,
                  let subItems = menuItems[mainIndex].subMenuItems else { return false }
            return subItems.count > scrollThresholdItemCount
        case .subSub:
            guard mainIndex < menuItems.count,
                  let subItems = menuItems[mainIndex].subMenuItems,
                  subIndex < subItems.count,
                  let subSubItems = subItems[subIndex].subMenuItems else { return false }
            return subSubItems.count > scrollThresholdItemCount
        }
    }

    /// Calculates effective angular span for menu items
    private func getEffectiveSpan(itemCount: Int, isScrollable: Bool) -> Double {
        return isScrollable ? totalSpan : min(AngleConstants.totalSpan, Double(itemCount - 1) * anglePerItem)
    }

    /// Gets visible items with caching for performance, Calculates which menu items are currently visible based on rotation, handles scrolling logic, and optimises performance through caching.
    private func getVisibleItems(for menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> [(item: RadialMenuItems, index: Int, visualIndex: Int)] {
        let currentRotation = viewportRotation(for: menuLevel)

        // Check cache validity
        if computationCache.isValid(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex, rotation: currentRotation) {
            return computationCache.cachedVisibleItems
        }

        // Cache menu data to avoid repeated calculations
        let menuData: (items: [RadialMenuItems], isScrollable: Bool) = {
            switch menuLevel {
            case .main:
                return (menuItems, isScrollingEnabled(menuLevel: .main))
            case .sub:
                guard let subItems = menuItems[mainIndex].subMenuItems else { return ([], false) }
                return (subItems, isScrollingEnabled(menuLevel: .sub, mainIndex: mainIndex))
            case .subSub:
                guard let subItems = menuItems[mainIndex].subMenuItems,
                      let subSubItems = subItems[subIndex].subMenuItems else { return ([], false) }
                return (subSubItems, isScrollingEnabled(menuLevel: .subSub, mainIndex: mainIndex, subIndex: subIndex))
            }
        }()

        var result: [(item: RadialMenuItems, index: Int, visualIndex: Int)] = []

        if !menuData.isScrollable {
            // Pre-allocate array with known size for better performance
            result.reserveCapacity(menuData.items.count)
            for i in 0..<menuData.items.count {
                result.append((item: menuData.items[i], index: i, visualIndex: i))
            }
        } else {
            let floatingOffset = currentRotation / anglePerItem
            let bufferItems = Constants.PerformanceConstants.bufferItemCount
            let startIndex = Int(floor(floatingOffset)) - bufferItems
            let endIndex = startIndex + maxVisibleItems + (bufferItems * Constants.PerformanceConstants.bufferItemCount)

            // Pre-allocate array for better performance
            result.reserveCapacity(endIndex - startIndex + 1)

            if wrapEnabled {
                // With wrap enabled, we use modulo to wrap around the indices
                for i in startIndex...endIndex {
                    let actualIndex = modulo(i, menuData.items.count)
                    result.append((item: menuData.items[actualIndex], index: actualIndex, visualIndex: i))
                }
            } else {
                // Without wrap, we filter to only valid indices within the range
                for i in startIndex...endIndex {
                    if i >= 0 && i < menuData.items.count {
                        result.append((item: menuData.items[i], index: i, visualIndex: i))
                    }
                }
            }
        }

        // Update cache
        computationCache.update(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex, rotation: currentRotation, items: result)

        return result
    }

    /// Proper modulo operation for negative numbers
    private func modulo(_ a: Int, _ b: Int) -> Int {
        // This function should only be called when wrapEnabled is true
        // Proper modulo operation that handles negative numbers correctly
        let remainder = a % b
        return remainder >= 0 ? remainder : remainder + b
    }
}

// MARK: - Visibility & Opacity Calculations - Optimised functions with consolidated calculations
extension SSRadialMenu {
    // MARK: - Menu State Accessors
    /// High-frequency state accessors for animation and interaction properties
    /// These functions provide centralized access to menu state properties during animations
    
    /// Retrieves the current rotation angle for the specified menu level
    private func menuRotation(for menuLevel: MenuLevel) -> Double {
        return getMenuState(for: menuLevel).rotation
    }
    
    /// Gets the rotation angle for viewport calculations (cached for performance)
    private func viewportRotation(for menuLevel: MenuLevel) -> Double {
        return menuRotation(for: menuLevel)
    }
    
    /// Retrieves the set of currently animating menu item indices
    private func animatingItemIndices(for menuLevel: MenuLevel) -> Set<Int> {
        return getMenuState(for: menuLevel).animatedIndices
    }
    
    /// Checks if the menu level is currently being dragged by user interaction
    private func isMenuBeingDragged(for menuLevel: MenuLevel) -> Bool {
        return getMenuState(for: menuLevel).isDragging
    }
    
    /// Gets the current scale effect applied to the menu level
    private func menuScaleEffect(for menuLevel: MenuLevel) -> CGFloat {
        return getMenuState(for: menuLevel).scaleEffect
    }

    /// Determines if item should be visible based on angular position in viewport
    private func shouldItemBeVisible(visualIndex: Int, menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> Bool {
        guard isScrollingEnabled(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex) else { return true }
        
        let itemRotation = Double(visualIndex) * anglePerItem - viewportRotation(for: menuLevel)
        let normalizedRotation = ((itemRotation + halfCircle).truncatingRemainder(dividingBy: fullCircle)) - halfCircle
        return abs(normalizedRotation) <= (totalSpan / 2) + (anglePerItem * visibilityBufferMultiplier)
    }

    /// Calculates opacity for smooth fade effects at viewport edges
    private func getItemOpacity(visualIndex: Int, menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> Double {
        guard isScrollingEnabled(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex) else { return 1.0 }
        
        let itemRotation = Double(visualIndex) * anglePerItem - viewportRotation(for: menuLevel)
        let normalizedRotation = ((itemRotation + halfCircle).truncatingRemainder(dividingBy: fullCircle)) - halfCircle
        let distance = abs(normalizedRotation)
        let coreDistance = totalSpan / 2
        let bufferDistance = coreDistance + (anglePerItem * visibilityBufferMultiplier)
        
        return distance <= coreDistance ? VisualConstants.opacityFull :
               distance <= bufferDistance ? max(VisualConstants.opacityHidden, VisualConstants.opacityFull - ((distance - coreDistance) / (bufferDistance - coreDistance) * VisualConstants.fadeMultiplier)) :
               VisualConstants.opacityHidden
    }

    /// Calculates progressive opacity during entrance animations
    private func calculateProgressiveOpacity(startPosition: CGPoint, endPosition: CGPoint, currentPosition: CGPoint, isAnimated: Bool) -> Double {
        guard isAnimated else { return 0.0 }
        let totalDistance = hypot(endPosition.x - startPosition.x, endPosition.y - startPosition.y)
        guard totalDistance > 1.0 else { return 1.0 }
        return min(hypot(currentPosition.x - startPosition.x, currentPosition.y - startPosition.y) / totalDistance, 1.0)
    }
}

// MARK: - Menu Level Helper Functions - Optimized helper functions with consolidated accessors
extension SSRadialMenu {
    // MARK: - Optimized State Access
    /// Gets MenuState for specified menu level
    private func getMenuState(for menuLevel: MenuLevel) -> MenuState {
        switch menuLevel {
        case .main: return mainMenuState
        case .sub: return subMenuState
        case .subSub: return subSubMenuState
        }
    }

    /// Updates MenuState for specified level using closure
    private func updateMenuState(for menuLevel: MenuLevel, _ updateBlock: (inout MenuState) -> Void) {
        switch menuLevel {
        case .main: updateBlock(&mainMenuState)
        case .sub: updateBlock(&subMenuState)
        case .subSub: updateBlock(&subSubMenuState)
        }
    }

    // Consolidated helper methods using computed properties for better performance
    /// Determines if zoom effect should be applied to item
    private func shouldApplyZoomEffect(menuLevel: MenuLevel, itemIndex: Int) -> Bool {
        zoomEffectEnabled && zoomEffectScale != 0 && menuLevel == .main && zoomedItemIndex == itemIndex
    }

    /// Gets zoom scale factor for selected items
    private func getZoomScale() -> CGFloat { zoomEffectScale ?? VisualConstants.scaleEffectZoomed }

    /// Gets circular radius for specified menu level
    private func getRadius(for menuLevel: MenuLevel) -> CGFloat {
        switch menuLevel {
        case .main: return radius
        case .sub: return subMenuRadius
        case .subSub: return subSubMenuRadius
        }
    }

    /// Gets card size for specified menu level
    private func getCardSize(for menuLevel: MenuLevel) -> CGFloat {
        switch menuLevel {
        case .main: return mainCardSize
        case .sub: return mainCardSize * subCardSizeMultiplier
        case .subSub: return mainCardSize * subSubCardSizeMultiplier
        }
    }

    /// Generates hierarchical index string for sub-menu items
    private func getHierarchicalIndex(menuLevel: MenuLevel, mainIndex: Int, subIndex: Int, itemIndex: Int) -> String? {
        switch menuLevel {
        case .main: return nil
        case .sub: return "\(mainIndex + 1).\(itemIndex + 1)"
        case .subSub: return "\(mainIndex + 1).\(subIndex + 1).\(itemIndex + 1)"
        }
    }
}

// MARK: - Item Properties & Position Calculations - Functions for calculating item properties and positions
extension SSRadialMenu {
    /// Calculates rotation, angle, and opacity properties for menu item
    private func calculateItemProperties(for item: (item: RadialMenuItems, index: Int, visualIndex: Int), menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> (rotation: Double, angle: Double, opacity: Double) {
        if !isScrollingEnabled(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex) {
            let staticItemRotation = Double(item.index) * anglePerItem
            let staticItemAngle = alignment.itemAngleForCarousel(rotation: staticItemRotation)
            return (staticItemRotation, staticItemAngle, 1.0)
        }

        let currentRotation = menuRotation(for: menuLevel)
        let itemRotation = Double(item.visualIndex) * anglePerItem - currentRotation
        let itemAngle = alignment.itemAngleForCarousel(rotation: itemRotation)
        let opacity = getItemOpacity(visualIndex: item.visualIndex, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)

        return (itemRotation, itemAngle, opacity)
    }

    /// Calculates initial position for items during entrance animations. Used during scrolling, when items need to appear/disappear with directional flow. 
    private func getInitialPosition(for item: (item: RadialMenuItems, index: Int, visualIndex: Int), menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> CGPoint {
        // Check if we're in momentum mode (spinWheel with active momentum)
        let isMomentumActive = getMomentumActive(for: menuLevel)
        let isSpinWheelMode = scrollingBehavior == .spinWheel
        
        // For momentum/spinWheel mode, items should appear directly at their final position with exact radius
        if isMomentumActive && isSpinWheelMode {
            let currentRotation = menuRotation(for: menuLevel)
            let itemRotation = Double(item.visualIndex) * anglePerItem - currentRotation
            let itemAngle = alignment.itemAngleForCarousel(rotation: itemRotation)
            let itemRadius = getRadius(for: menuLevel) // Use exact radius, no modifications
            
            return CGPoint(
                x: itemRadius * cos(itemAngle * .pi / 180),
                y: itemRadius * sin(itemAngle * .pi / 180)
            )
        }
        
        // For non-momentum scenarios, calculate natural entry position
        let currentRotation = menuRotation(for: menuLevel)
        let itemRotation = Double(item.visualIndex) * anglePerItem - currentRotation
        let itemAngle = alignment.itemAngleForCarousel(rotation: itemRotation)
        let itemRadius = getRadius(for: menuLevel)
        
        // Calculate where the item is coming from in the circular flow
        let isScrollingEnabled = isScrollingEnabled(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
        
        if !isScrollingEnabled {
            // For non-scrolling menus, items appear from center
            return CGPoint.zero
        }
        
        // Calculate entry position from outside the visible area but on the circular path
        let visibilityThreshold = (totalSpan / 2) + (anglePerItem * visibilityBufferMultiplier)
        let normalizedRotation = ((itemRotation + halfCircle).truncatingRemainder(dividingBy: fullCircle)) - halfCircle
        
        // Determine if item is entering from left or right side of the visible area
        let isEnteringFromLeft = normalizedRotation < -visibilityThreshold
        let isEnteringFromRight = normalizedRotation > visibilityThreshold
        
        // For fast speed momentum, always use exact radius to prevent radius changes
        if isSpinWheelMode && (spinWheelSpeed == .fast) {
            // During fast spinning, maintain consistent radius for all items
            return CGPoint(
                x: itemRadius * cos(itemAngle * .pi / 180),
                y: itemRadius * sin(itemAngle * .pi / 180)
            )
        }
        
        if isEnteringFromLeft || isEnteringFromRight {
            // Item is entering from outside, position it just outside the visible area
            let entryRadius = itemRadius * 1.2 // Slightly outside for smooth entry
            let entryAngleOffset = isEnteringFromLeft ? -(visibilityThreshold + anglePerItem * 0.5) : (visibilityThreshold + anglePerItem * 0.5)
            let entryAngle = alignment.itemAngleForCarousel(rotation: entryAngleOffset)
            
            return CGPoint(
                x: entryRadius * cos(entryAngle * .pi / 180),
                y: entryRadius * sin(entryAngle * .pi / 180)
            )
        } else {
            // Item is already in view, use its natural position
            return CGPoint(
                x: itemRadius * 2.1 * cos(itemAngle * .pi / 180),
                y: itemRadius * 2.1 * sin(itemAngle * .pi / 180)
            )
        }
    }

    /**
     * Provides default initial positions for menu levels when specific item positioning isn't needed.
     * Used for Menu opening/closing, fallback scenarios, non-scrolling contexts
     *
     * - Parameters:
     *   - menuLevel: Which menu level to get default position for
     *   - mainIndex: Index for sub-menu context
     *   - subIndex: Index for sub-sub-menu context
     * - Returns: Default CGPoint for the menu level
     */
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
                    let subItemRotation = Double(subIndex) * anglePerItem - menuRotation(for: .sub)
                    return alignment.itemAngleForCarousel(rotation: subItemRotation)
                } else {
                    let staticSubItemRotation = Double(subIndex) * anglePerItem
                    return alignment.itemAngleForCarousel(rotation: staticSubItemRotation)
                }
            }()
            return CGPoint(x: subMenuRadius * cos(parentSubMenuAngle * .pi / 180), y: subMenuRadius * sin(parentSubMenuAngle * .pi / 180))
        }
    }

    /**
     * Calculates the fixed angle for a main menu item.
     * Used for consistent positioning of sub-menu anchor points.
     * 
     * - Parameter itemIndex: Index of the main menu item
     * - Returns: Angle in degrees for the item's position
     */
    private func getFixedMainItemAngle(for itemIndex: Int) -> Double {
        let baseVisualIndex = itemIndex
        let itemRotation = Double(baseVisualIndex) * anglePerItem
        return alignment.itemAngleForCarousel(rotation: itemRotation)
    }
}

// MARK: - Drag Gesture Handling - Functions for handling drag gestures and momentum
extension SSRadialMenu {
    /**
     * Creates a conditional drag gesture for menu levels that support scrolling.
     * 
     * The gesture is only enabled when:
     * - The menu level has enough items to require scrolling
     * - No child menus are currently open (prevents conflicting gestures)
     * 
     * Features:
     * - Immediate momentum cancellation when user starts dragging
     * - Speed-sensitive drag calculations for spin wheel behavior
     * - Boundary clamping when wrap is disabled
     * - Smooth momentum continuation on gesture end
     * 
     * - Parameters:
     *   - menuLevel: Which menu level to create gesture for
     *   - mainIndex: Context index for sub-menu gestures
     *   - subIndex: Context index for sub-sub-menu gestures
     * - Returns: Optional AnyGesture that handles the drag interactions
     */
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
                // Immediately stop any active momentum when user starts dragging
                if getMomentumActive(for: menuLevel) {
                    stopMomentum(for: menuLevel)
                }

                setDragging(for: menuLevel, value: true)

                // Apply speed-based drag sensitivity for spin wheel movement
                let baseSensitivity = scrollingBehavior == .spinWheel ? 1.2 * spinWheelSpeed.speedMultiplier : 1.2
                let delta = alignment.calculateDragDelta(translation: value.translation, sensitivity: baseSensitivity)
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
                updateStartAngle(for: menuLevel, value: menuRotation(for: menuLevel))

                // Much more controlled momentum handling for very smooth gestures
                let velocity = value.velocity.width
                if abs(velocity) > 0.1 { // Extremely low threshold for highly controlled momentum
                    handleDragMomentum(velocity: velocity, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
                } else {
                    // For very slow drags, provide reduced momentum in spin wheel mode for more controlled regular scrolling
                    if scrollingBehavior == .spinWheel {
                        let minimumMomentum = (velocity > 0 ? 35.0 : -35.0) * spinWheelSpeed.speedMultiplier // Apply speed multiplier for minimum momentum
                        handleDragMomentum(velocity: minimumMomentum, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
                    } else {
                        updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
                    }
                }
            })
    }

    /// Processes drag momentum for appropriate animation response
    private func handleDragMomentum(velocity: CGFloat, menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) {
        guard abs(velocity) > 0.1 else {
            updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
            return
        }

        stopMomentum(for: menuLevel)
        
        let itemCount = getItemCountForMenu(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
        let calculateClampedRotation = { (rotation: Double) -> Double in
            guard !self.wrapEnabled && itemCount > 0 else { return rotation }
            let maxRotation = Double(itemCount - 1) * self.anglePerItem - (self.totalSpan / 2)
            return min(max(0, rotation), maxRotation)
        }

        switch scrollingBehavior {
        case .simple:
            applySimpleMomentum(velocity: velocity, menuLevel: menuLevel, calculateClampedRotation: calculateClampedRotation)
        case .spinWheel:
            let isFlick = abs(velocity) > Constants.PerformanceConstants.flickVelocityThreshold
            if isFlick {
                let clampedVelocity = max(-spinWheelSpeed.maxVelocity, min(spinWheelSpeed.maxVelocity, alignment.calculateMomentumRotation(velocity: velocity, factor: spinWheelSpeed.velocityMultiplier)))
                startContinuousMomentum(velocity: clampedVelocity, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
            } else {
                applyControlledMomentum(velocity: velocity, menuLevel: menuLevel, calculateClampedRotation: calculateClampedRotation)
            }
        }
    }
    
    /// Applies simple momentum animation with smooth easing
    private func applySimpleMomentum(velocity: CGFloat, menuLevel: MenuLevel, calculateClampedRotation: (Double) -> Double) {
        let momentumRotation = alignment.calculateMomentumRotation(velocity: velocity, factor: 0.001 * spinWheelSpeed.speedMultiplier)
        let newRotation = calculateClampedRotation(menuRotation(for: menuLevel) + momentumRotation)
        
        withAnimation(.easeOut(duration: AnimationConstants.momentumDuration)) {
            updateRotation(for: menuLevel, value: newRotation)
            updateStartAngle(for: menuLevel, value: newRotation)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.momentumUpdateDelay) {
            self.updateVisibleItemsAnimation(for: menuLevel, mainIndex: 0, subIndex: 0)
        }
    }
    
    /// Applies controlled momentum with spring animation
    private func applyControlledMomentum(velocity: CGFloat, menuLevel: MenuLevel, calculateClampedRotation: (Double) -> Double) {
        let momentumRotation = alignment.calculateMomentumRotation(velocity: velocity, factor: 0.004 * spinWheelSpeed.speedMultiplier)
        let newRotation = calculateClampedRotation(menuRotation(for: menuLevel) + momentumRotation)
        
        withAnimation(.spring(response: 1.0, dampingFraction: 0.85, blendDuration: 0)) {
            updateRotation(for: menuLevel, value: newRotation)
            updateStartAngle(for: menuLevel, value: newRotation)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.updateVisibleItemsAnimation(for: menuLevel, mainIndex: 0, subIndex: 0)
        }
    }
}

// MARK: - State Management - Optimized functions for managing state across menu levels
extension SSRadialMenu {
    /// Updates MenuState property using KeyPath for type safety
    private func updateMenuProperty<T>(for menuLevel: MenuLevel, keyPath: WritableKeyPath<MenuState, T>, value: T) {
        updateMenuState(for: menuLevel) { state in
            state[keyPath: keyPath] = value
        }
    }
    
    /// Gets MenuState property using KeyPath for type safety
    private func getMenuProperty<T>(for menuLevel: MenuLevel, keyPath: KeyPath<MenuState, T>) -> T {
        return getMenuState(for: menuLevel)[keyPath: keyPath]
    }

    /// Sets dragging state for menu level
    private func setDragging(for menuLevel: MenuLevel, value: Bool) {
        updateMenuProperty(for: menuLevel, keyPath: \.isDragging, value: value)
    }

    /// Updates rotation angle and invalidates computation cache
    private func updateRotation(for menuLevel: MenuLevel, value: Double) {
        updateMenuProperty(for: menuLevel, keyPath: \.rotation, value: value)
        computationCache.invalidate()
    }

    /// Gets starting angle for drag calculations
    private func getStartAngle(for menuLevel: MenuLevel) -> Double {
        getMenuProperty(for: menuLevel, keyPath: \.startAngle)
    }

    /**
     * Updates the starting angle after drag operations complete.
     * Sets new baseline for future drag calculations.
     */
    private func updateStartAngle(for menuLevel: MenuLevel, value: Double) {
        updateMenuProperty(for: menuLevel, keyPath: \.startAngle, value: value)
    }

    /**
     * Updates momentum velocity for continuous spinning animations.
     * Used by the DisplayLink-based momentum system.
     */
    private func updateMomentumVelocity(for menuLevel: MenuLevel, velocity: Double) {
        updateMenuProperty(for: menuLevel, keyPath: \.momentumVelocity, value: velocity)
    }

    /**
     * Gets current momentum velocity for frame-based updates.
     * Used in momentum decay calculations.
     */
    private func getMomentumVelocity(for menuLevel: MenuLevel) -> Double {
        getMenuProperty(for: menuLevel, keyPath: \.momentumVelocity)
    }

    /**
     * Sets whether momentum animation is currently active.
     * Controls DisplayLink activation and momentum-specific behaviors.
     */
    private func setMomentumActive(for menuLevel: MenuLevel, value: Bool) {
        updateMenuProperty(for: menuLevel, keyPath: \.isMomentumActive, value: value)
    }

    /**
     * Gets whether momentum animation is currently active.
     * Used for conditional logic in positioning and animation systems.
     */
    private func getMomentumActive(for menuLevel: MenuLevel) -> Bool {
        getMenuProperty(for: menuLevel, keyPath: \.isMomentumActive)
    }

    // Unified menu control functions
    /**
     * Closes a menu level and all its child levels.
     * Handles cascade closing, state cleanup, and zoom effect reset.
     * 
     * - Parameter level: Menu level to close (.main, .sub, .subSub)
     */
    private func closeMenu(level: MenuLevel) {
        stopMomentum(for: level)
        
        switch level {
        case .main:
            mainMenuState.reset()
        case .sub:
            showingSubMenuForIndex = nil
            subMenuState.reset()
            selectedSubMenuItem = nil
            selectedSubSubMenuItem = nil
            if zoomEffectEnabled { zoomedItemIndex = nil }
            closeMenu(level: .subSub)
        case .subSub:
            showingSubSubMenuForIndex = nil
            subSubMenuState.reset()
            selectedSubSubMenuItem = nil
        }
    }
    
    /// Closes sub-menu level
    private func closeSubMenu() { closeMenu(level: .sub) }
    
    /// Closes sub-sub-menu level
    private func closeSubSubMenu() { closeMenu(level: .subSub) }

    /// Resets scroll positions for all menu levels
    private func resetAllScrollPositions() {
        [MenuLevel.main, .sub, .subSub].forEach { level in
            stopMomentum(for: level)
            switch level {
            case .main: mainMenuState.reset()
            case .sub: subMenuState.reset()
            case .subSub: subSubMenuState.reset()
            }
        }
    }

    /// Initiates continuous momentum animation for spin wheel behavior
    private func startContinuousMomentum(velocity: Double, menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) {
        let enhancedVelocity = velocity * 2.0 * spinWheelSpeed.speedMultiplier
        updateMomentumVelocity(for: menuLevel, velocity: enhancedVelocity)
        setMomentumActive(for: menuLevel, value: true)
        updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)

        momentumCoordinator.startMomentumAnimation {
            self.updateMomentumFrame(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
        }
    }

    /// Updates momentum animation on each display frame
    private func updateMomentumFrame(menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) {
        let currentVelocity = getMomentumVelocity(for: menuLevel)
        
        guard abs(currentVelocity) >= AnimationConstants.momentumMinimumVelocity else {
            stopMomentum(for: menuLevel)
            updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
            return
        }

        let currentRotation = menuRotation(for: menuLevel)
        var newRotation = currentRotation + (currentVelocity * AnimationConstants.momentumSmoothness * spinWheelSpeed.speedMultiplier)

        // Consolidated boundary checking and momentum stopping
        if !wrapEnabled {
            let itemCount = getItemCountForMenu(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
            if itemCount > 0 {
                let maxRotation = Double(itemCount - 1) * anglePerItem - (totalSpan / 2)
                let clampedRotation = min(max(0, newRotation), maxRotation)
                
                if clampedRotation != newRotation {
                    updateRotation(for: menuLevel, value: clampedRotation)
                    updateStartAngle(for: menuLevel, value: clampedRotation)
                    stopMomentum(for: menuLevel)
                    updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
                    return
                }
                newRotation = clampedRotation
            }
        }

        // Apply rotation and velocity decay in one go
        updateRotation(for: menuLevel, value: newRotation)
        updateStartAngle(for: menuLevel, value: newRotation)
        updateMomentumVelocity(for: menuLevel, velocity: currentVelocity * AnimationConstants.momentumDecayRate)
        updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
    }

    /// Stops momentum animation and cleans up state
    private func stopMomentum(for menuLevel: MenuLevel) {
        updateMenuState(for: menuLevel) { state in state.stopMomentum() }
        momentumCoordinator.stopMomentumAnimation()
    }

    /// Gets total number of items for menu level
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

// MARK: - Item Tap Handling - Optimized functions for handling item taps
extension SSRadialMenu {
    /// Routes item tap events to appropriate handlers
    private func handleItemTap(menuLevel: MenuLevel, mainIndex: Int, subIndex: Int, itemIndex: Int, item: RadialMenuItems) {
        switch menuLevel {
        case .main: handleMainItemTap(index: itemIndex, item: item)
        case .sub: handleSubItemTap(mainIndex: mainIndex, subIndex: itemIndex, item: item)
        case .subSub: handleSubSubItemTap(item: item)
        }
    }

    /// Executes item selection with callback notification
    private func executeItemSelection(item: RadialMenuItems, menuLevel: MenuLevel) {
        // Update selection tracking
        switch menuLevel {
        case .main:
            (selectedMainMenuItem, selectedSubMenuItem, selectedSubSubMenuItem) = (item, nil, nil)
            onMainMenuSelection?(item)
        case .sub:
            (selectedSubMenuItem, selectedSubSubMenuItem) = (item, nil)
            onSubMenuSelection?(item)
        case .subSub:
            selectedSubSubMenuItem = item
            onSubSubMenuSelection?(item)
        }
        
        // Execute action and update name
        item.action?()
        selectedItemName = item.name
    }

    /**
     * Handles tap events on main menu items.
     * 
     * Manages:
     * - Sub-menu opening/closing logic
     * - Zoom effect application
     * - Selection tracking and callbacks
     * - Animation state transitions
     * 
     * - Parameters:
     *   - index: Index of the tapped main menu item
     *   - item: The RadialMenuItems object that was tapped
     */
    private func handleMainItemTap(index: Int, item: RadialMenuItems) {
        // Handle existing submenu closure
        if let currentOpen = showingSubMenuForIndex {
            if currentOpen == index { return closeSubMenu() }
            closeSubMenu()
        }

        executeItemSelection(item: item, menuLevel: .main)

        // Apply zoom effect if enabled
        if zoomEffectEnabled && zoomEffectScale != 0 { zoomedItemIndex = index }

        // Handle submenu or zoom cleanup
        if let subItems = menuItems[index].subMenuItems, !subItems.isEmpty {
            showingSubMenuForIndex = index
            if !wrapEnabled { updateRotation(for: .sub, value: 0.0); updateStartAngle(for: .sub, value: 0.0) }
            startSequentialAnimation(for: .sub, itemCount: subItems.count)
        } else if zoomEffectEnabled && zoomEffectScale != 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    if self.zoomedItemIndex == index { self.zoomedItemIndex = nil }
                }
            }
        }
    }

    /**
     * Handles tap events on sub-menu items.
     * 
     * Manages sub-sub-menu opening/closing and proper state cleanup.
     * 
     * - Parameters:
     *   - mainIndex: Index of the parent main menu item
     *   - subIndex: Index of the tapped sub menu item
     *   - item: The RadialMenuItems object that was tapped
     */
    private func handleSubItemTap(mainIndex: Int, subIndex: Int, item: RadialMenuItems) {
        // Handle existing sub-submenu closure
        if let currentOpen = showingSubSubMenuForIndex {
            if currentOpen.mainIndex == mainIndex && currentOpen.subIndex == subIndex { return closeSubSubMenu() }
            closeSubSubMenu()
        }

        executeItemSelection(item: item, menuLevel: .sub)

        // Handle sub-submenu
        if let subSubItems = item.subMenuItems, !subSubItems.isEmpty {
            showingSubSubMenuForIndex = (mainIndex: mainIndex, subIndex: subIndex)
            if !wrapEnabled { updateRotation(for: .subSub, value: 0.0); updateStartAngle(for: .subSub, value: 0.0) }
            startSequentialAnimation(for: .subSub, itemCount: subSubItems.count)
        }
    }

    /// Handles tap events on sub-sub-menu items
    private func handleSubSubItemTap(item: RadialMenuItems) {
        executeItemSelection(item: item, menuLevel: .subSub)
        closeSubSubMenu()
    }
}

// MARK: - Animation Management - Optimised functions for managing animations
extension SSRadialMenu {
    /// Starts sequential entrance animation for menu items
    private func startSequentialAnimation(for menuLevel: MenuLevel, itemCount: Int) {
        updateMenuProperty(for: menuLevel, keyPath: \.animatedIndices, value: Set<Int>())
        
        let (mainIdx, subIdx) = (showingSubMenuForIndex ?? 0, showingSubSubMenuForIndex?.subIndex ?? 0)
        let sortedItems = getVisibleItems(for: menuLevel, mainIndex: mainIdx, subIndex: subIdx)
            .filter { shouldItemBeVisible(visualIndex: $0.visualIndex, menuLevel: menuLevel, mainIndex: mainIdx, subIndex: subIdx) && $0.visualIndex >= 0 }
            .sorted { $0.index < $1.index }

        sortedItems.enumerated().forEach { sequenceIndex, item in
            let delay = sequenceIndex < 5 ? Double(sequenceIndex) * AnimationConstants.itemSequenceDelay : 0.01
            let animation: Animation? = sequenceIndex < 5 ? .spring(response: AnimationConstants.springAnimationResponse, dampingFraction: AnimationConstants.springAnimationDamping) : nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if let animation = animation {
                    withAnimation(animation) { self.modifyAnimatedIndices(visualIndex: item.visualIndex, menuLevel: menuLevel, operation: .insert) }
                } else {
                    self.modifyAnimatedIndices(visualIndex: item.visualIndex, menuLevel: menuLevel, operation: .insert)
                }
            }
        }
    }

    /// Operations for animated indices set
    private enum AnimationOperation { case insert, remove }
    
    /// Safely modifies animated indices set for menu level
    private func modifyAnimatedIndices(visualIndex: Int, menuLevel: MenuLevel, operation: AnimationOperation) {
        updateMenuState(for: menuLevel) { state in
            switch operation {
            case .insert: state.animatedIndices.insert(visualIndex)
            case .remove: state.animatedIndices.remove(visualIndex)
            }
        }
    }

    /// Updates which items should be animated based on visibility
    private func updateVisibleItemsAnimation(for menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) {
        let newAnimatedIndices = Set(getVisibleItems(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
            .filter { shouldItemBeVisible(visualIndex: $0.visualIndex, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex) }
            .map { $0.visualIndex })
        
        let currentAnimatedIndices = animatingItemIndices(for: menuLevel)
        let isSilentUpdate = isMenuBeingDragged(for: menuLevel) || (getMomentumActive(for: menuLevel) && scrollingBehavior == .spinWheel)
        
        let (toAdd, toRemove) = (newAnimatedIndices.subtracting(currentAnimatedIndices), currentAnimatedIndices.subtracting(newAnimatedIndices))
        
        [toAdd, toRemove].enumerated().forEach { operationIndex, indices in
            let operation: AnimationOperation = operationIndex == 0 ? .insert : .remove
            let animation: Animation? = isSilentUpdate ? nil : (operation == .insert ? .easeIn(duration: AnimationConstants.fadeInDuration) : .easeOut(duration: AnimationConstants.fadeOutDuration))
            
            indices.forEach { visualIndex in
                if let animation = animation {
                    withAnimation(animation) { self.modifyAnimatedIndices(visualIndex: visualIndex, menuLevel: menuLevel, operation: operation) }
                } else {
                    self.modifyAnimatedIndices(visualIndex: visualIndex, menuLevel: menuLevel, operation: operation)
                }
            }
        }
    }
}

// MARK: - Menu Details & Card Detection - Optimised functions for menu details and card detection
extension SSRadialMenu {
    /// Updates selected item name based on closest card to indicator
    private func updateMenuDetailsForCarousel() {
        let currentRotation = viewportRotation(for: .main)
        let closestItem = getVisibleItems(for: .main)
            .filter { shouldItemBeVisible(visualIndex: $0.visualIndex, menuLevel: .main) }
            .compactMap { item -> (item: RadialMenuItems, distance: Double)? in
                let itemRotation = Double(item.visualIndex) * anglePerItem - currentRotation
                let itemAngle = alignment.itemAngleForCarousel(rotation: itemRotation)
                return isCardNearTriangle(itemAngle) ? (item.item, abs(itemRotation)) : nil
            }
            .min { $0.distance < $1.distance }

        if let item = closestItem { selectedItemName = item.item.name }
    }

    /// Determines if card is positioned near selection indicator
    private func isCardNearTriangle(_ itemAngle: Double) -> Bool {
        let triangleAngle = AngleConstants.quarterCircle * 3
        let threshold = AngleConstants.triangleDetectionThreshold
        let normalizedDifference = abs(((itemAngle + AngleConstants.fullCircle).truncatingRemainder(dividingBy: AngleConstants.fullCircle)) - 
                                     ((triangleAngle + AngleConstants.fullCircle).truncatingRemainder(dividingBy: AngleConstants.fullCircle)))
        return normalizedDifference <= threshold || normalizedDifference >= (AngleConstants.fullCircle - threshold)
    }
}

// MARK: - Menu Rotation Controls - Optimised functions for rotating menus
extension SSRadialMenu {
    /// Rotates menu level by one item position in specified direction
    private func rotateMenu(_ menuLevel: MenuLevel, direction: RotationDirection) {
        let rotationChange = direction == .next ? anglePerItem : -anglePerItem
        let currentRotation = menuRotation(for: menuLevel)
        var newRotation = currentRotation + rotationChange

        let (mainIndex, subIndex) = menuLevel == .main ? (0, 0) : 
                                   menuLevel == .sub ? (showingSubMenuForIndex ?? 0, 0) : 
                                   (showingSubMenuForIndex ?? 0, showingSubSubMenuForIndex?.subIndex ?? 0)

        // Apply boundary constraints if wrap is disabled
        if !wrapEnabled {
            let itemCount = getItemCountForMenu(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
            if itemCount > 0 {
                let maxRotation = Double(itemCount - 1) * anglePerItem - (totalSpan / 2)
                let clampedRotation = min(max(0, newRotation), maxRotation)
                
                // Don't animate if already at boundary
                guard clampedRotation != currentRotation else { return }
                newRotation = clampedRotation
            }
        }

        withAnimation(.easeInOut(duration: AnimationConstants.menuAnimationDuration)) {
            updateRotation(for: menuLevel, value: newRotation)
            updateStartAngle(for: menuLevel, value: newRotation)
        }

        updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
    }
}

// MARK: - DisplayLink-based Animation Coordinator

/// Manages DisplayLink-based momentum animations for smooth scrolling
class MomentumAnimationCoordinator: ObservableObject {
    private var displayLink: CADisplayLink?
    private var momentumUpdateCallback: (() -> Void)?

    /// Starts 60fps momentum animation
    func startMomentumAnimation(callback: @escaping () -> Void) {
        stopMomentumAnimation()
        momentumUpdateCallback = callback

        displayLink = CADisplayLink(target: self, selector: #selector(updateMomentum))
        displayLink?.add(to: .main, forMode: .common)
    }

    /// Stops momentum animation and cleans up resources
    func stopMomentumAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        momentumUpdateCallback = nil
    }

    /// DisplayLink callback for frame updates
    @objc private func updateMomentum() {
        momentumUpdateCallback?()
    }

    /// Cleanup on deallocation
    deinit {
        stopMomentumAnimation()
    }
}
