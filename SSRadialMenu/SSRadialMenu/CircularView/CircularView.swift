//
//  CircularView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 02/12/24.
import SwiftUI

struct SSRadialMenu: View {
    let menuItems: [RadialMenuItems]
    var alignment: AlignmentType = .bottomTrailing
    
    init(menuItems: [RadialMenuItems], alignment: AlignmentType = .bottomTrailing) {
        self.menuItems = menuItems
        self.alignment = alignment
    }
    
    // Core UI State
    @State private var nameofPizza: String = "Cheese Pizza"
    @State private var priceofPizza: String = "150 $"
    @State private var showPizzaCards: Bool = false
    @State private var showingSubMenuForIndex: Int? = nil
    @State private var showingSubSubMenuForIndex: (mainIndex: Int, subIndex: Int)? = nil
    
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
    
    // Unified scrolling check
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
    
    // Unified span calculation
    private func getEffectiveSpan(itemCount: Int, isScrollable: Bool) -> Double {
        return isScrollable ? totalSpan : min(AngleConstants.totalSpan, Double(itemCount - 1) * anglePerItem)
    }
    
    // Unified function to get visible items for any menu level
    private func getVisibleItems(for menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> [(pizza: RadialMenuItems, index: Int, visualIndex: Int)] {
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
        
        var result: [(pizza: RadialMenuItems, index: Int, visualIndex: Int)] = []
        
        if !isScrollable {
            for i in 0..<items.count {
                result.append((pizza: items[i], index: i, visualIndex: i))
            }
            return result
        }
        
        let floatingOffset = currentRotation / anglePerItem
        let bufferItems = Constants.PerformanceConstants.bufferItemCount
        let startIndex = Int(floor(floatingOffset)) - bufferItems
        let endIndex = startIndex + maxVisibleItems + (bufferItems * Constants.PerformanceConstants.bufferItemCount)

        for i in startIndex...endIndex {
            let actualIndex = modulo(i, items.count)
            result.append((pizza: items[actualIndex], index: actualIndex, visualIndex: i))
        }
        
        return result
    }
    
    
    private func modulo(_ a: Int, _ b: Int) -> Int {
        let remainder = a % b
        return remainder >= 0 ? remainder : remainder + b
    }
    
    // Unified visibility and opacity calculations
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

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            
            DebugInfoView(
                showPizzaCards: showPizzaCards,
                continuousRotation: rotations.main,
                pizzaCount: menuItems.count,
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
                    if showPizzaCards {
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
                let (itemRotation, itemAngle, opacity) = calculateItemProperties(for: item, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
                
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
                    
                    let finalOpacity = currentAnimatedIndices.contains(item.visualIndex) ? min(progressiveOpacity, opacity) : 0.0
                    
                    PizzaCard(
                        pizza: item.pizza,
                        itemNumber: menuLevel == .main ? item.index + 1 : nil,
                        hierarchicalIndex: getHierarchicalIndex(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex, itemIndex: item.index),
                        cardSize: getCardSize(for: menuLevel)
                    )
                    .rotationEffect(.degrees(-itemAngle))
                    .offset(x: currentPosition.x, y: currentPosition.y)
                    .scaleEffect(currentAnimatedIndices.contains(item.visualIndex) ? currentScaleEffect : VisualConstants.scaleEffectMinimal)
                    .opacity(finalOpacity)
                    .animation(currentDragging ? .none : .spring(response: AnimationConstants.springResponseSlow, dampingFraction: AnimationConstants.springAnimationDamping), value: currentAnimatedIndices)
                    .animation(currentDragging ? .none : .linear(duration: AnimationConstants.fadeOutDuration), value: getCurrentRotation(for: menuLevel))
                    .animation(currentDragging ? .none : .spring(response: AnimationConstants.springAnimationResponse, dampingFraction: AnimationConstants.springAnimationDamping), value: currentScaleEffect)
                    .onTapGesture {
                        handleItemTap(menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex, itemIndex: item.index, item: item.pizza)
                    }
                    .onChange(of: itemAngle) { _ in
                        if menuLevel == .main && isCardNearTriangle(itemAngle) {
                            nameofPizza = item.pizza.name
                            priceofPizza = item.pizza.pizzaPrice
                        }
                    }
                }
            }
        }
        .gesture(createConditionalDragGesture(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex))
    }
    
    // Helper functions for unified menu system
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
            case .main: return LayoutConstants.cardSizeMain
            case .sub: return LayoutConstants.cardSizeSub
            case .subSub: return LayoutConstants.cardSizeSubSub
        }
    }
    
    private func getHierarchicalIndex(menuLevel: MenuLevel, mainIndex: Int, subIndex: Int, itemIndex: Int) -> String? {
        switch menuLevel {
            case .main: return nil
            case .sub: return "\(mainIndex + 1).\(itemIndex + 1)"
            case .subSub: return "\(mainIndex + 1).\(subIndex + 1).\(itemIndex + 1)"
        }
    }
    
    // Unified item properties calculation
    private func calculateItemProperties(for item: (pizza: RadialMenuItems, index: Int, visualIndex: Int), menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> (rotation: Double, angle: Double, opacity: Double) {
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
    
    // Progressive opacity calculation
    private func calculateProgressiveOpacity(startPosition: CGPoint, endPosition: CGPoint, currentPosition: CGPoint, isAnimated: Bool) -> Double {
        guard isAnimated else { return 0.0 }
        let totalDistance = hypot(endPosition.x - startPosition.x, endPosition.y - startPosition.y)
        guard totalDistance > 1.0 else { return 1.0 }
        let currentDistance = hypot(currentPosition.x - startPosition.x, currentPosition.y - startPosition.y)
        return min(currentDistance / totalDistance, 1.0)
    }
    
    // Unified initial position calculation
    private func getInitialPosition(for item: (pizza: RadialMenuItems, index: Int, visualIndex: Int), menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> CGPoint {
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
                x: previousRadius * cos(previousItemAngle * .pi / 180),
                y: previousRadius * sin(previousItemAngle * .pi / 180)
            )
        }
    }
    
    private func getDefaultInitialPosition(for menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) -> CGPoint {
        switch menuLevel {
        case .main:
            return CGPoint.zero
        case .sub:
            let fixedMainItemAngle = getFixedMainItemAngle(for: mainIndex)
            return CGPoint(x: radius * cos(fixedMainItemAngle * .pi / 180), y: radius * sin(fixedMainItemAngle * .pi / 180))
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
    
    // Unified drag gesture creation
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
                updateRotation(for: menuLevel, value: getStartAngle(for: menuLevel) + delta)
                updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
            }
            .onEnded { value in
                setDragging(for: menuLevel, value: false)
                updateStartAngle(for: menuLevel, value: getCurrentRotation(for: menuLevel))
                handleDragMomentum(velocity: value.velocity.width, menuLevel: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
            })
    }
    
    // Unified state management
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
    
    // Unified item tap handling
    private func handleItemTap(menuLevel: MenuLevel, mainIndex: Int, subIndex: Int, itemIndex: Int, item: RadialMenuItems) {
        switch menuLevel {
        case .main:
            handleMainItemTap(index: itemIndex)
        case .sub:
            handleSubItemTap(mainIndex: mainIndex, subIndex: itemIndex, item: item)
        case .subSub:
            nameofPizza = item.name
            priceofPizza = item.pizzaPrice
            closeSubSubMenu()
        }
    }
    
    private func handleMainItemTap(index: Int) {
        if let currentOpen = showingSubMenuForIndex {
            if currentOpen == index {
                closeSubMenu()
                return
            }
            closeSubMenu()
        }
        
        if let subItems = menuItems[index].subMenuItems, !subItems.isEmpty {
            showingSubMenuForIndex = index
            startSequentialAnimation(for: .sub, itemCount: subItems.count)
        } else {
            nameofPizza = menuItems[index].name
            priceofPizza = menuItems[index].pizzaPrice
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
        
        if let subSubItems = item.subMenuItems, !subSubItems.isEmpty {
            showingSubSubMenuForIndex = (mainIndex: mainIndex, subIndex: subIndex)
            startSequentialAnimation(for: .subSub, itemCount: subSubItems.count)
        } else {
            nameofPizza = item.name
            priceofPizza = item.pizzaPrice
        }
    }
    
    // FAB Button
    @ViewBuilder
    private var mainFabButton: some View {
        Button(action: {
            if showingSubMenuForIndex != nil {
                closeSubMenu()
            }
            showPizzaCards.toggle()
            if showPizzaCards {
                resetAllScrollPositions()
                startSequentialAnimation(for: .main, itemCount: menuItems.count)
            } else {
                animatedIndices.removeAll()
            }
        }, label: {
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.yellow)
                .clipShape(Circle())
        })
        .frame(width: 80, height: 80)
        .clipShape(Circle())
    }
    
    // Unified momentum handling
    private func handleDragMomentum(velocity: CGFloat, menuLevel: MenuLevel, mainIndex: Int = 0, subIndex: Int = 0) {
        guard abs(velocity) > Constants.PerformanceConstants.momentumVelocityThreshold else {
            updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
            return
        }
        
        let momentumRotation = alignment.calculateMomentumRotation(velocity: velocity)
        let currentRotation = getCurrentRotation(for: menuLevel)
        let newRotation = currentRotation + momentumRotation
        
        withAnimation(.easeOut(duration: AnimationConstants.momentumDuration)) {
            updateRotation(for: menuLevel, value: newRotation)
            updateStartAngle(for: menuLevel, value: newRotation)
        }
        
        // Use Timer instead of DispatchQueue for better performance
        Timer.scheduledTimer(withTimeInterval: AnimationConstants.momentumUpdateDelay, repeats: false) { _ in
            updateVisibleItemsAnimation(for: menuLevel, mainIndex: mainIndex, subIndex: subIndex)
        }
    }
    
    // Unified animation management
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

    
    // Menu control functions
    private func closeSubMenu() {
        showingSubMenuForIndex = nil
        subMenuAnimatedIndices.removeAll()
        rotations.sub = 0.0
        startAngles.sub = 0.0
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
    
    // Unified rotation controls
    private func rotateMenu(_ menuLevel: MenuLevel, direction: RotationDirection) {
        let rotationChange = direction == .next ? anglePerItem : -anglePerItem
        
        withAnimation(.easeInOut(duration: AnimationConstants.menuAnimationDuration)) {
            let currentRotation = getCurrentRotation(for: menuLevel)
            let newRotation = currentRotation + rotationChange
            updateRotation(for: menuLevel, value: newRotation)
            updateStartAngle(for: menuLevel, value: newRotation)
        }
        
        updateVisibleItemsAnimation(for: menuLevel, 
                                   mainIndex: showingSubMenuForIndex ?? 0, 
                                   subIndex: showingSubSubMenuForIndex?.subIndex ?? 0)
    }
    
    // Pizza details update
    private func updatePizzaDetailsForCarousel() {
        let visibleItems = getVisibleItems(for: .main)
        var closestItem: (pizza: RadialMenuItems, index: Int, visualIndex: Int)?
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
            nameofPizza = item.pizza.name
            priceofPizza = item.pizza.pizzaPrice
        }
    }
    
    private func isCardNearTriangle(_ pizzaAngle: Double) -> Bool {
        let triangleAngle = AngleConstants.quarterCircle * 3  // 270 degrees
        let threshold: Double = AngleConstants.triangleDetectionThreshold
        let normalizedPizzaAngle = (pizzaAngle + AngleConstants.fullCircle).truncatingRemainder(dividingBy: AngleConstants.fullCircle)
        let normalizedTriangleAngle = (triangleAngle + AngleConstants.fullCircle).truncatingRemainder(dividingBy: AngleConstants.fullCircle)
        let angleDifference = abs(normalizedPizzaAngle - normalizedTriangleAngle)
        return angleDifference <= threshold || angleDifference >= (AngleConstants.fullCircle - threshold)
    }
    
    // PizzaCard component (consolidated)
    @ViewBuilder
    func PizzaCard(pizza: RadialMenuItems, itemNumber: Int? = nil, hierarchicalIndex: String? = nil, cardSize: CGFloat = 55) -> some View {
        ZStack {
            Image(pizza.icon)
                .resizable()
                .frame(width: cardSize, height: cardSize)
                .clipShape(Circle())
                .padding(cardSize * 0.07)
            
            let displayText: String = {
                if let hierarchicalIndex = hierarchicalIndex {
                    return hierarchicalIndex
                } else if let itemNumber = itemNumber {
                    return "\(itemNumber)"
                } else {
                    return "\((menuItems.firstIndex(where: { $0.id == pizza.id }) ?? 0) + 1)"
                }
            }()
            
            let fontSize: CGFloat = {
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
            }()
            
            let badgeSize: CGFloat = {
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
            }()
            
            let offsetMultiplier: CGFloat = cardSize / LayoutConstants.cardSizeMain
            
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

// Supporting enums
enum MenuLevel {
    case main, sub, subSub
}

enum RotationDirection {
    case next, previous
}
