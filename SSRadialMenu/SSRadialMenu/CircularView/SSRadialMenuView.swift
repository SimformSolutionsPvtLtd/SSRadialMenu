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
    let scrollThresholdItemCount: Int
    let scrollingBehavior: ScrollingBehavior

    // Selection tracking closures
    let onMainMenuSelection: ((RadialMenuItems) -> Void)?
    let onSubMenuSelection: ((RadialMenuItems) -> Void)?
    let onSubSubMenuSelection: ((RadialMenuItems) -> Void)?

    // Initializer for icon-based FAB buttons (SF Symbols)
    init(menuItems: [RadialMenuItems],
         alignment: AlignmentType = .bottomTrailing,
         expandMenuIcon: String,
         collapseMenuIcon: String? = nil,
         mainCardSize: CGFloat = 55.0,
         spinsItemsDuringDrag: Bool = true,
         wrapEnabled: Bool = true,
         zoomEffectEnabled: Bool = true,
         zoomEffectScale: CGFloat? = nil,
         zoomOpacityReduction: Double = 0.3,
         scrollThresholdItemCount: Int = PerformanceConstants.scrollThresholdItemCount,
         scrollingBehavior: ScrollingBehavior = .simple,
         onMainMenuSelection: ((RadialMenuItems) -> Void)? = nil,
         onSubMenuSelection: ((RadialMenuItems) -> Void)? = nil,
         onSubSubMenuSelection: ((RadialMenuItems) -> Void)? = nil
    ) {
        self.init(
            menuItems: menuItems,
            alignment: alignment,
            expandMenuIcon: expandMenuIcon,
            collapseMenuIcon: collapseMenuIcon,
            expandMenuImage: nil,
            collapseMenuImage: nil,
            mainCardSize: mainCardSize,
            spinsItemsDuringDrag: spinsItemsDuringDrag,
            wrapEnabled: wrapEnabled,
            zoomEffectEnabled: zoomEffectEnabled,
            zoomEffectScale: zoomEffectScale,
            zoomOpacityReduction: zoomOpacityReduction,
            scrollThresholdItemCount: scrollThresholdItemCount,
            scrollingBehavior: scrollingBehavior,
            onMainMenuSelection: onMainMenuSelection,
            onSubMenuSelection: onSubMenuSelection,
            onSubSubMenuSelection: onSubSubMenuSelection
        )
    }

    // Initializer for image-based FAB buttons (asset images)
    init(menuItems: [RadialMenuItems],
         alignment: AlignmentType = .bottomTrailing,
         expandMenuImage: String,
         collapseMenuImage: String? = nil,
         mainCardSize: CGFloat = 55.0,
         spinsItemsDuringDrag: Bool = true,
         wrapEnabled: Bool = true,
         zoomEffectEnabled: Bool = true,
         zoomEffectScale: CGFloat? = nil,
         zoomOpacityReduction: Double = 0.3,
         scrollThresholdItemCount: Int = PerformanceConstants.scrollThresholdItemCount,
         scrollingBehavior: ScrollingBehavior = .simple,
         onMainMenuSelection: ((RadialMenuItems) -> Void)? = nil,
         onSubMenuSelection: ((RadialMenuItems) -> Void)? = nil,
         onSubSubMenuSelection: ((RadialMenuItems) -> Void)? = nil
    ) {
        self.init(
            menuItems: menuItems,
            alignment: alignment,
            expandMenuIcon: nil,
            collapseMenuIcon: nil,
            expandMenuImage: expandMenuImage,
            collapseMenuImage: collapseMenuImage,
            mainCardSize: mainCardSize,
            spinsItemsDuringDrag: spinsItemsDuringDrag,
            wrapEnabled: wrapEnabled,
            zoomEffectEnabled: zoomEffectEnabled,
            zoomEffectScale: zoomEffectScale,
            zoomOpacityReduction: zoomOpacityReduction,
            scrollThresholdItemCount: scrollThresholdItemCount,
            scrollingBehavior: scrollingBehavior,
            onMainMenuSelection: onMainMenuSelection,
            onSubMenuSelection: onSubMenuSelection,
            onSubSubMenuSelection: onSubSubMenuSelection
        )
    }

    // Private designated initializer to eliminate code duplication
    private init(menuItems: [RadialMenuItems],
                alignment: AlignmentType,
                expandMenuIcon: String?,
                collapseMenuIcon: String?,
                expandMenuImage: String?,
                collapseMenuImage: String?,
                mainCardSize: CGFloat,
                spinsItemsDuringDrag: Bool,
                wrapEnabled: Bool,
                zoomEffectEnabled: Bool,
                zoomEffectScale: CGFloat?,
                zoomOpacityReduction: Double,
                scrollThresholdItemCount: Int,
                scrollingBehavior: ScrollingBehavior,
                onMainMenuSelection: ((RadialMenuItems) -> Void)?,
                onSubMenuSelection: ((RadialMenuItems) -> Void)?,
                onSubSubMenuSelection: ((RadialMenuItems) -> Void)?) {
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
        self.onMainMenuSelection = onMainMenuSelection
        self.onSubMenuSelection = onSubMenuSelection
        self.onSubSubMenuSelection = onSubSubMenuSelection
    }

    // MARK: - Optimized State Management

    /// Consolidated state for all menu levels to reduce tuple overhead
    private struct MenuState {
        var rotation: Double = 0
        var startAngle: Double = 0
        var isDragging: Bool = false
        var scaleEffect: CGFloat = 1.0
        var animatedIndices: Set<Int> = []
        var momentumVelocity: Double = 0
        var momentumTimer: Timer? = nil
        var isMomentumActive: Bool = false

        mutating func reset() {
            rotation = 0
            startAngle = 0
            isDragging = false
            scaleEffect = 1.0
            animatedIndices.removeAll()
            stopMomentum()
        }

        mutating func stopMomentum() {
            momentumTimer?.invalidate()
            momentumTimer = nil
            momentumVelocity = 0
            isMomentumActive = false
        }
    }

    /// Cache for frequently computed values to improve performance
    private struct ComputationCache {
        var lastMenuLevel: MenuLevel?
        var lastMainIndex: Int?
        var lastSubIndex: Int?
        var cachedVisibleItems: [(item: RadialMenuItems, index: Int, visualIndex: Int)] = []
        var cacheValidation: String = ""

        mutating func invalidate() {
            lastMenuLevel = nil
            lastMainIndex = nil
            lastSubIndex = nil
            cachedVisibleItems.removeAll()
            cacheValidation = ""
        }

        func isValid(for menuLevel: MenuLevel, mainIndex: Int, subIndex: Int, rotation: Double) -> Bool {
            let currentValidation = "\(menuLevel)-\(mainIndex)-\(subIndex)-\(Int(rotation))"
            return lastMenuLevel == menuLevel &&
                   lastMainIndex == mainIndex &&
                   lastSubIndex == subIndex &&
                   cacheValidation == currentValidation
        }

        mutating func update(for menuLevel: MenuLevel, mainIndex: Int, subIndex: Int, rotation: Double, items: [(item: RadialMenuItems, index: Int, visualIndex: Int)]) {
            lastMenuLevel = menuLevel
            lastMainIndex = mainIndex
            lastSubIndex = subIndex
            cachedVisibleItems = items
            cacheValidation = "\(menuLevel)-\(mainIndex)-\(subIndex)-\(Int(rotation))"
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

    // Computed properties
    var anglePerItem: Double { totalSpan / Double(maxVisibleItems - 1) }

    // Public access to selected items
    var currentSelectedMainItem: RadialMenuItems? { selectedMainMenuItem }
    var currentSelectedSubItem: RadialMenuItems? { selectedSubMenuItem }
    var currentSelectedSubSubItem: RadialMenuItems? { selectedSubSubMenuItem }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)

            /**
                DebugInfoView(
                    showMenuCards: showMenuCards,
                    continuousRotation: mainMenuState.rotation,
                    itemCount: menuItems.count,
                    isMainMenuScrollingEnabled: isScrollingEnabled(menuLevel: .main),
                    anglePerItem: anglePerItem,
                    animatedIndicesCount: mainMenuState.animatedIndices.count,
                    showingSubMenuForIndex: showingSubMenuForIndex,
                    subMenuRotation: subMenuState.rotation,
                    subMenuItemsCount: showingSubMenuForIndex != nil ? (menuItems[showingSubMenuForIndex!].subMenuItems?.count ?? 0) : 0,
                    isSubMenuScrollingEnabled: { index in isScrollingEnabled(menuLevel: .sub, mainIndex: index) },
                    rotateSubMenuToPreviousItem: { rotateMenu(.sub, direction: .previous) },
                    rotateSubMenuToNextItem: { rotateMenu(.sub, direction: .next) },
                    rotateToPreviousItem: { rotateMenu(.main, direction: .previous) },
                    rotateToNextItem: { rotateMenu(.main, direction: .next) }
                )
            */

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
                mainMenuState.animatedIndices.removeAll()
                // Reset all selections when closing the menu
                selectedMainMenuItem = nil
                selectedSubMenuItem = nil
                selectedSubSubMenuItem = nil
                // Reset zoom effect when closing the menu, if enabled
                if zoomEffectEnabled {
                    zoomedItemIndex = nil
                }
            }
        }, label: {
            ZStack {
                // Collapse button (shown when menu is expanded)
                if let collapseMenuIcon = collapseMenuIcon {
                    // SF Symbol collapse icon
                    Image(systemName: collapseMenuIcon)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .opacity(showMenuCards ? 1.0 : 0.0)
                        .scaleEffect(showMenuCards ? 1.0 : 0.3)
                } else if let collapseMenuImage = collapseMenuImage {
                    // Asset image collapse icon
                    Image(collapseMenuImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .opacity(showMenuCards ? 1.0 : 0.0)
                        .scaleEffect(showMenuCards ? 1.0 : 0.3)
                }

                // Expand button (shown when menu is collapsed)
                if let expandMenuIcon = expandMenuIcon {
                    // SF Symbol expand icon
                    Image(systemName: expandMenuIcon)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .opacity((showMenuCards && (collapseMenuIcon != nil || collapseMenuImage != nil)) ? 0.0 : 1.0)
                        .scaleEffect((showMenuCards && (collapseMenuIcon != nil || collapseMenuImage != nil)) ? 0.3 : 1.0)
                } else if let expandMenuImage = expandMenuImage {
                    // Asset image expand icon
                    Image(expandMenuImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .opacity((showMenuCards && (collapseMenuIcon != nil || collapseMenuImage != nil)) ? 0.0 : 1.0)
                        .scaleEffect((showMenuCards && (collapseMenuIcon != nil || collapseMenuImage != nil)) ? 0.3 : 1.0)
                }
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
            ForEach(Array(visibleItems.enumerated()), id: \.element.visualIndex) { _, item in
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

    private func getEffectiveSpan(itemCount: Int, isScrollable: Bool) -> Double {
        return isScrollable ? totalSpan : min(AngleConstants.totalSpan, Double(itemCount - 1) * anglePerItem)
    }

    private func getVisibleItems(for menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> [(item: RadialMenuItems, index: Int, visualIndex: Int)] {
        let currentRotation = getCachedRotation(for: menuLevel)

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

    private func modulo(_ a: Int, _ b: Int) -> Int {
        // This function should only be called when wrapEnabled is true
        // Proper modulo operation that handles negative numbers correctly
        let remainder = a % b
        return remainder >= 0 ? remainder : remainder + b
    }
}

// Visibility & Opacity Calculations - Optimized functions for item visibility and opacity
extension SSRadialMenu {

    // Cache for computed rotation values to avoid repeated calculations
    @inline(__always)
    private func getCachedRotation(for menuLevel: MenuLevel) -> Double {
        return getCurrentRotation(for: menuLevel)
    }

    @inline(__always)
    private func getCurrentRotation(for menuLevel: MenuLevel) -> Double {
        return getMenuState(for: menuLevel).rotation
    }

    @inline(__always)
    private func getCurrentAnimatedIndices(for menuLevel: MenuLevel) -> Set<Int> {
        return getMenuState(for: menuLevel).animatedIndices
    }

    @inline(__always)
    private func getCurrentDragging(for menuLevel: MenuLevel) -> Bool {
        return getMenuState(for: menuLevel).isDragging
    }

    @inline(__always)
    private func getCurrentScaleEffect(for menuLevel: MenuLevel) -> CGFloat {
        return getMenuState(for: menuLevel).scaleEffect
    }

    private func shouldItemBeVisible(visualIndex: Int, menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> Bool {
        if !isScrollingEnabled(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex) {
            return true
        }

        let currentRotation = getCachedRotation(for: menuLevel)
        let itemRotation = Double(visualIndex) * anglePerItem - currentRotation
        let normalizedRotation = ((itemRotation + halfCircle).truncatingRemainder(dividingBy: fullCircle)) - halfCircle
        let visibilityThreshold = (totalSpan / 2) + (anglePerItem * visibilityBufferMultiplier)
        return abs(normalizedRotation) <= visibilityThreshold
    }

    private func getItemOpacity(visualIndex: Int, menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> Double {
        if !isScrollingEnabled(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex) {
            return 1.0
        }

        let currentRotation = getCachedRotation(for: menuLevel)
        let itemRotation = Double(visualIndex) * anglePerItem - currentRotation
        let normalizedRotation = ((itemRotation + halfCircle).truncatingRemainder(dividingBy: fullCircle)) - halfCircle
        let coreDistance = totalSpan / 2
        let bufferDistance = coreDistance + (anglePerItem * visibilityBufferMultiplier)
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

// Menu Level Helper Functions - Optimized helper functions for different menu levels.
extension SSRadialMenu {

    // MARK: - Optimized State Access

    private func getMenuState(for menuLevel: MenuLevel) -> MenuState {
        switch menuLevel {
        case .main: return mainMenuState
        case .sub: return subMenuState
        case .subSub: return subSubMenuState
        }
    }

    private func updateMenuState(for menuLevel: MenuLevel, _ updateBlock: (inout MenuState) -> Void) {
        switch menuLevel {
        case .main: updateBlock(&mainMenuState)
        case .sub: updateBlock(&subMenuState)
        case .subSub: updateBlock(&subSubMenuState)
        }
    }

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

    @inline(__always)
    private func getRadius(for menuLevel: MenuLevel) -> CGFloat {
        switch menuLevel {
        case .main: return radius
        case .sub: return subMenuRadius
        case .subSub: return subSubMenuRadius
        }
    }

    @inline(__always)
    private func getCardSize(for menuLevel: MenuLevel) -> CGFloat {
        switch menuLevel {
        case .main: return mainCardSize
        case .sub: return mainCardSize * subCardSizeMultiplier
        case .subSub: return mainCardSize * subSubCardSizeMultiplier
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

    // Unified initial position calculation for smooth circular flow
    private func getInitialPosition(for item: (item: RadialMenuItems, index: Int, visualIndex: Int), menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> CGPoint {
        // Check if we're in momentum mode (spinWheel with active momentum)
        let isMomentumActive = getMomentumActive(for: menuLevel)
        let isSpinWheelMode = scrollingBehavior == .spinWheel
        
        // For momentum/spinWheel mode, items should appear directly at their final position
        if isMomentumActive && isSpinWheelMode {
            let currentRotation = getCurrentRotation(for: menuLevel)
            let itemRotation = Double(item.visualIndex) * anglePerItem - currentRotation
            let itemAngle = alignment.itemAngleForCarousel(rotation: itemRotation)
            let itemRadius = getRadius(for: menuLevel)
            
            return CGPoint(
                x: itemRadius * cos(itemAngle * .pi / 180),
                y: itemRadius * sin(itemAngle * .pi / 180)
            )
        }
        
        // For non-momentum scenarios, calculate natural entry position
        let currentRotation = getCurrentRotation(for: menuLevel)
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
                x: itemRadius * 2 * cos(itemAngle * .pi / 180),
                y: itemRadius * 2 * sin(itemAngle * .pi / 180)
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
                    let subItemRotation = Double(subIndex) * anglePerItem - getCurrentRotation(for: .sub)
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
                // Immediately stop any active momentum when user starts dragging
                if getMomentumActive(for: menuLevel) {
                    stopMomentum(for: menuLevel)
                }

                setDragging(for: menuLevel, value: true)

                // Slower drag sensitivity for very controlled regular spin wheel movement
                let delta = alignment.calculateDragDelta(translation: value.translation, sensitivity: 1.2)
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

                // Much more controlled momentum handling for very smooth gestures
                let velocity = value.velocity.width
                if abs(velocity) > 0.1 { // Extremely low threshold for highly controlled momentum
                    handleDragMomentum(velocity: velocity, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
                } else {
                    // For very slow drags, provide reduced momentum in spin wheel mode for more controlled regular scrolling
                    if scrollingBehavior == .spinWheel {
                        let minimumMomentum = velocity > 0 ? 35.0 : -35.0 // Reduced minimum momentum for slower regular movement
                        handleDragMomentum(velocity: minimumMomentum, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
                    } else {
                        updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
                    }
                }
            })
    }

    // Controlled momentum handling for smooth response
    private func handleDragMomentum(velocity: CGFloat, menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) {
                // Much lower threshold for highly controlled momentum triggering
        guard abs(velocity) > 0.1 else {
            updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
            return
        }

        // Stop any existing momentum for this menu level
        stopMomentum(for: menuLevel)

        // Use different behavior based on scrollingBehavior setting
        switch scrollingBehavior {
        case .simple:
            // Simple momentum behavior with extremely slow movement
            let momentumRotation = alignment.calculateMomentumRotation(velocity: velocity, factor: 0.001) // Even slower factor for simple mode
            let currentRotation = getCurrentRotation(for: menuLevel)
            var newRotation = currentRotation + momentumRotation

            // If wrap is disabled, ensure rotation stays within valid limits
            if !wrapEnabled {
                let itemCount = getItemCountForMenu(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
                if itemCount > 0 {
                    let maxRotation = Double(itemCount - 1) * anglePerItem - (totalSpan / 2)
                    newRotation = min(max(0, newRotation), maxRotation)
                }
            }

            withAnimation(.easeOut(duration: AnimationConstants.momentumDuration)) {
                updateRotation(for: menuLevel, value: newRotation)
                updateStartAngle(for: menuLevel, value: newRotation)
            }

            Timer.scheduledTimer(withTimeInterval: AnimationConstants.momentumUpdateDelay, repeats: false) { _ in
                updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
            }

        case .spinWheel:
            // Enhanced momentum behavior with continuous spinning
            // Calculate initial momentum velocity based on drag velocity
            let initialVelocity = alignment.calculateMomentumRotation(velocity: velocity, factor: Constants.PerformanceConstants.momentumVelocityMultiplier)

            // Clamp velocity to reasonable limits
            let clampedVelocity = max(-Constants.PerformanceConstants.maximumMomentumVelocity,
                                     min(Constants.PerformanceConstants.maximumMomentumVelocity, initialVelocity))

            // Check if this is a flick gesture (high velocity) or regular drag
            let isFlick = abs(velocity) > Constants.PerformanceConstants.flickVelocityThreshold

            if isFlick {
                // Start continuous momentum for flick gestures
                startContinuousMomentum(velocity: clampedVelocity, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
            } else {
                // For regular drags in spinWheel mode, create momentum with much slower responsiveness for very controlled movement
                let momentumRotation = alignment.calculateMomentumRotation(velocity: velocity, factor: 0.004) // Much slower factor for very controlled regular scrolling
                let currentRotation = getCurrentRotation(for: menuLevel)
                var newRotation = currentRotation + momentumRotation

                // If wrap is disabled, ensure rotation stays within valid limits
                if !wrapEnabled {
                    let itemCount = getItemCountForMenu(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
                    if itemCount > 0 {
                        let maxRotation = Double(itemCount - 1) * anglePerItem - (totalSpan / 2)
                        newRotation = min(max(0, newRotation), maxRotation)
                    }
                }

                // Use very controlled spring-like animation for precise regular drags
                withAnimation(.spring(response: 1.0, dampingFraction: 0.85, blendDuration: 0)) {
                    updateRotation(for: menuLevel, value: newRotation)
                    updateStartAngle(for: menuLevel, value: newRotation)
                }

                Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { _ in
                    updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
                }
            }
        }
    }
    }

// State Management - Optimized functions for managing state across menu levels
extension SSRadialMenu {
    private func setDragging(for menuLevel: MenuLevel, value: Bool) {
        updateMenuState(for: menuLevel) { state in
            state.isDragging = value
        }
    }

    private func updateRotation(for menuLevel: MenuLevel, value: Double) {
        updateMenuState(for: menuLevel) { state in
            state.rotation = value
        }
        // Invalidate cache when rotation changes
        computationCache.invalidate()
    }

    private func getStartAngle(for menuLevel: MenuLevel) -> Double {
        return getMenuState(for: menuLevel).startAngle
    }

    private func updateStartAngle(for menuLevel: MenuLevel, value: Double) {
        updateMenuState(for: menuLevel) { state in
            state.startAngle = value
        }
    }

    // Helper functions for momentum state management
    private func updateMomentumVelocity(for menuLevel: MenuLevel, velocity: Double) {
        updateMenuState(for: menuLevel) { state in
            state.momentumVelocity = velocity
        }
    }

    private func getMomentumVelocity(for menuLevel: MenuLevel) -> Double {
        return getMenuState(for: menuLevel).momentumVelocity
    }

    private func updateMomentumTimer(for menuLevel: MenuLevel, timer: Timer?) {
        updateMenuState(for: menuLevel) { state in
            state.momentumTimer = timer
        }
    }

    private func getMomentumTimer(for menuLevel: MenuLevel) -> Timer? {
        return getMenuState(for: menuLevel).momentumTimer
    }

    private func setMomentumActive(for menuLevel: MenuLevel, value: Bool) {
        updateMenuState(for: menuLevel) { state in
            state.isMomentumActive = value
        }
    }

    private func getMomentumActive(for menuLevel: MenuLevel) -> Bool {
        return getMenuState(for: menuLevel).isMomentumActive
    }

    // Menu control functions
    private func closeSubMenu() {
        // Stop momentum when closing submenu
        stopMomentum(for: .sub)

        showingSubMenuForIndex = nil
        subMenuState.reset()

        // Reset sub-level selections when closing submenu
        selectedSubMenuItem = nil
        selectedSubSubMenuItem = nil

        // Reset zoom effect when closing submenu, if enabled
        if zoomEffectEnabled {
            zoomedItemIndex = nil
        }
        closeSubSubMenu()
    }

    private func closeSubSubMenu() {
        // Stop momentum when closing sub-submenu
        stopMomentum(for: .subSub)

        showingSubSubMenuForIndex = nil
        subSubMenuState.reset()

        // Reset sub-sub level selection when closing sub-submenu
        selectedSubSubMenuItem = nil
    }

    private func resetAllScrollPositions() {
        // Stop all momentum when resetting positions
        stopMomentum(for: .main)
        stopMomentum(for: .sub)
        stopMomentum(for: .subSub)

        mainMenuState.reset()
        subMenuState.reset()
        subSubMenuState.reset()
    }

    // MARK: - Momentum Functions

    // Start continuous momentum animation for spin wheel effect with spring-like behavior
    private func startContinuousMomentum(velocity: Double, menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) {
        // Enhance velocity for better spring effect on long flicks
        let enhancedVelocity = velocity * 2.0 // Increased amplification for faster initial velocity
        
        // Set initial momentum velocity
        updateMomentumVelocity(for: menuLevel, velocity: enhancedVelocity)
        setMomentumActive(for: menuLevel, value: true)

        // Immediately update visible items to ensure they're aware of momentum mode
        updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)

        // Create and start the momentum timer with faster frame rate for smoother spinning
        let timer = Timer.scheduledTimer(withTimeInterval: AnimationConstants.momentumFrameRate, repeats: true) { timer in
            self.updateMomentumFrame(timer: timer, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
        }

        // Store the timer
        updateMomentumTimer(for: menuLevel, timer: timer)
    }

    // Update momentum on each frame with improved responsiveness
    private func updateMomentumFrame(timer: Timer, menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) {
        let currentVelocity = getMomentumVelocity(for: menuLevel)

        // Check if velocity is too low to continue
        if abs(currentVelocity) < AnimationConstants.momentumMinimumVelocity {
            stopMomentum(for: menuLevel)
            updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
            return
        }

        // Update rotation based on current velocity with improved smoothness
        let currentRotation = getCurrentRotation(for: menuLevel)
        var newRotation = currentRotation + (currentVelocity * AnimationConstants.momentumSmoothness)

        // If wrap is disabled, ensure rotation stays within valid limits and stop momentum at edges
        if !wrapEnabled {
            let itemCount = getItemCountForMenu(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
            if itemCount > 0 {
                let maxRotation = Double(itemCount - 1) * anglePerItem - (totalSpan / 2)
                let clampedRotation = min(max(0, newRotation), maxRotation)

                // If we hit the boundary, stop momentum
                if clampedRotation != newRotation {
                    newRotation = clampedRotation
                    stopMomentum(for: menuLevel)
                    updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
                    return
                }
            }
        }

        // Apply the rotation update directly for smoothest performance
        updateRotation(for: menuLevel, value: newRotation)
        updateStartAngle(for: menuLevel, value: newRotation)

        // Apply decay to velocity for gradual slowdown
        let decayedVelocity = currentVelocity * AnimationConstants.momentumDecayRate
        updateMomentumVelocity(for: menuLevel, velocity: decayedVelocity)

        // Update visible items on every frame during momentum for smooth item appearance
        // This ensures new items appearing during fast momentum are positioned correctly
        updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
    }

    // Stop momentum animation
    private func stopMomentum(for menuLevel: MenuLevel) {
        updateMenuState(for: menuLevel) { state in
            state.stopMomentum()
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

// Item Tap Handling - Functions for handling item taps.
extension SSRadialMenu {
    private func handleItemTap(menuLevel: MenuLevel, mainIndex: Int, subIndex: Int, itemIndex: Int, item: RadialMenuItems) {
        switch menuLevel {
        case .main:
            handleMainItemTap(index: itemIndex, item: item)
        case .sub:
            handleSubItemTap(mainIndex: mainIndex, subIndex: itemIndex, item: item)
        case .subSub:
            handleSubSubItemTap(item: item)
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

        // Track selection for main menu
        selectedMainMenuItem = item
        // Reset sub-level selections when selecting a new main item
        selectedSubMenuItem = nil
        selectedSubSubMenuItem = nil

        // Apply zoom effect to the tapped item if enabled
        if zoomEffectEnabled && zoomEffectScale != 0 {
            zoomedItemIndex = index
        }

        // Execute the provided action, if available
        item.action?()

        // Call the selection closure
        onMainMenuSelection?(item)

        if let subItems = menuItems[index].subMenuItems, !subItems.isEmpty {
            showingSubMenuForIndex = index

            // If wrap is disabled, ensure the rotation starts at 0
            if !wrapEnabled {
                updateRotation(for: .sub, value: 0.0)
                updateStartAngle(for: .sub, value: 0.0)
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

        // Track selection for sub menu
        selectedSubMenuItem = item
        // Reset sub-sub level selection when selecting a new sub item
        selectedSubSubMenuItem = nil

        // Execute the provided action, if available
        item.action?()

        // Call the selection closure
        onSubMenuSelection?(item)

        if let subSubItems = item.subMenuItems, !subSubItems.isEmpty {
            showingSubSubMenuForIndex = (mainIndex: mainIndex, subIndex: subIndex)

            // If wrap is disabled, ensure the rotation starts at 0
            if !wrapEnabled {
                updateRotation(for: .subSub, value: 0.0)
                updateStartAngle(for: .subSub, value: 0.0)
            }

            startSequentialAnimation(for: .subSub, itemCount: subSubItems.count)
        } else {
            selectedItemName = item.name
        }
    }

    private func handleSubSubItemTap(item: RadialMenuItems) {
        // Track selection for sub-sub menu
        selectedSubSubMenuItem = item

        // Execute the provided action, if available
        item.action?()

        // Call the selection closure
        onSubSubMenuSelection?(item)

        selectedItemName = item.name
        closeSubSubMenu()
    }
}

// Animation Management - Functions for managing animations.
extension SSRadialMenu {
    private func startSequentialAnimation(for menuLevel: MenuLevel, itemCount: Int) {
        clearAnimatedIndices(for: menuLevel)

        let visibleItems = getVisibleItems(for: menuLevel, mainIndex: showingSubMenuForIndex ?? 0, subIndex: showingSubSubMenuForIndex?.subIndex ?? 0)
        let sortedItems = visibleItems
            .filter { shouldItemBeVisible(visualIndex: $0.visualIndex, menuLevel: menuLevel, mainIndex: showingSubMenuForIndex ?? 0, subIndex: showingSubSubMenuForIndex?.subIndex ?? 0) }
            .filter { $0.visualIndex >= 0 } // Filter out items with negative visual indices to prevent items appearing before 0th index
            .sorted { $0.index < $1.index } // Sort by actual index to ensure proper order (0, 1, 2, 3, 4...)

        // Only animate items from 0th to 4th index (5 items total: 0, 1, 2, 3, 4)
        let maxAnimatedItems = 5

        for (sequenceIndex, item) in sortedItems.enumerated() {
            if sequenceIndex < maxAnimatedItems {
                // Items from 0th to 4th index (indices 0, 1, 2, 3, 4) get sequential pop-out animation
                let delay = Double(sequenceIndex) * AnimationConstants.itemSequenceDelay
                Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                    withAnimation(.spring(response: AnimationConstants.springAnimationResponse, dampingFraction: AnimationConstants.springAnimationDamping)) {
                        self.addToAnimatedIndices(visualIndex: item.visualIndex, menuLevel: menuLevel)
                    }
                }
            } else {
                // Items beyond the 4th index appear immediately without animation
                Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { _ in
                    self.addToAnimatedIndices(visualIndex: item.visualIndex, menuLevel: menuLevel)
                }
            }
        }
    }

    private func clearAnimatedIndices(for menuLevel: MenuLevel) {
        updateMenuState(for: menuLevel) { state in
            state.animatedIndices.removeAll()
        }
    }

    private func addToAnimatedIndices(visualIndex: Int, menuLevel: MenuLevel) {
        updateMenuState(for: menuLevel) { state in
            state.animatedIndices.insert(visualIndex)
        }
    }

    // Unified visibility animation updates with momentum handling
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
        let isMomentumActive = getMomentumActive(for: menuLevel)
        let isSpinWheelMode = scrollingBehavior == .spinWheel

        if currentDragging || (isMomentumActive && isSpinWheelMode) {
            // Silent updates during dragging or momentum for instant appearance
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
            // Animated updates when not dragging and not in momentum
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
        updateMenuState(for: menuLevel) { state in
            state.animatedIndices.remove(visualIndex)
        }
    }
}

// Menu Details & Card Detection - Optimized functions for menu details and card detection
extension SSRadialMenu {
    private func updateMenuDetailsForCarousel() {
        let visibleItems = getVisibleItems(for: .main)
        let currentRotation = getCachedRotation(for: .main)
        var closestItem: (item: RadialMenuItems, index: Int, visualIndex: Int)?
        var smallestDistance: Double = Double.infinity

        for item in visibleItems {
            if shouldItemBeVisible(visualIndex: item.visualIndex, menuLevel: .main) {
                let itemRotation = Double(item.visualIndex) * anglePerItem - currentRotation
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
