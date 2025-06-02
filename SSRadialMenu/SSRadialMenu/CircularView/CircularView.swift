//
//  CircularView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 02/12/24.
import SwiftUI

struct ContentView: View {
    var body: some View {
        FinalView(alignment: .bottomLeading)
    }
}

#Preview {
    ContentView()
}

struct FinalView: View {
    var alignment: AlignmentType = .bottomTrailing
    @State private var angle: Double = 0.0
    @State private var startAngle: Double = 0.0
    @State private var nameofPizza: String = "Cheese Pizza"
    @State private var priceofPizza: String = "150 $"
    @State private var animatedIndices: Set<Int> = []
    @State private var showingSubMenuForIndex: Int? = nil // Tracks which item's submenu is showing
    @State private var subMenuAnimatedIndices: Set<Int> = [] // Tracks animated submenu items
    @State private var showingSubSubMenuForIndex: (mainIndex: Int, subIndex: Int)? = nil // Tracks which submenu item's sub-submenu is showing
    @State private var subSubMenuAnimatedIndices: Set<Int> = [] // Tracks animated sub-submenu items
    let radius: CGFloat = 115 // Increased radius for better spacing between items
    let subMenuRadius: CGFloat = 180 // Larger radius for submenus with better spacing
    let subSubMenuRadius: CGFloat = 240 // Even larger radius for sub-submenus
    
    // Enhanced carousel properties
    let maxVisibleItems: Int = 6 // Reduced from 8 to 6 for better spacing
    let totalSpan: Double = 160.0 // Increased span for better spacing between items
    @State private var showPizzaCards: Bool = false
    
    // Independent rotation states for each menu level
    @State private var continuousRotation: Double = 0.0 // Main menu rotation
    @State private var subMenuRotation: Double = 0.0 // Submenu rotation
    @State private var subSubMenuRotation: Double = 0.0 // Sub-submenu rotation
    
    // Independent dragging states for each menu level
    @State private var isDragging: Bool = false
    @State private var isSubMenuDragging: Bool = false
    @State private var isSubSubMenuDragging: Bool = false
    
    // Start angles for each menu level
    @State private var subMenuStartAngle: Double = 0.0
    @State private var subSubMenuStartAngle: Double = 0.0
    
    // Computed properties for smooth carousel
    var anglePerItem: Double {
        totalSpan / Double(maxVisibleItems - 1)
    }
    
    var itemsPerFullRotation: Double {
        360.0 / anglePerItem
    }
    
    // MARK: - Conditional Scrolling Properties
    var isMainMenuScrollingEnabled: Bool {
        pizzas.count > 4
    }
    
    func isSubMenuScrollingEnabled(for mainIndex: Int) -> Bool {
        guard mainIndex < pizzas.count,
              let subMenuItems = pizzas[mainIndex].subMenuItems else {
            return false
        }
        return subMenuItems.count > 4
    }
    
    func isSubSubMenuScrollingEnabled(for mainIndex: Int, subIndex: Int) -> Bool {
        guard mainIndex < pizzas.count,
              let subMenuItems = pizzas[mainIndex].subMenuItems,
              subIndex < subMenuItems.count,
              let subSubMenuItems = subMenuItems[subIndex].subMenuItems else {
            return false
        }
        return subSubMenuItems.count > 4
    }
    
    // Enhanced totalSpan for static mode - expands to show all items when ≤4
    var effectiveTotalSpan: Double {
        if !isMainMenuScrollingEnabled {
            // For ≤4 items, expand span to accommodate all items
            return min(300.0, Double(pizzas.count - 1) * anglePerItem)
        }
        return totalSpan
    }
    
    // Helper function to calculate effective span for submenu static mode
    func getEffectiveSubMenuSpan(for itemCount: Int) -> Double {
        if itemCount <= 4 {
            return min(300.0, Double(itemCount - 1) * anglePerItem)
        }
        return totalSpan
    }
    
    // Helper function to calculate effective span for sub-submenu static mode
    func getEffectiveSubSubMenuSpan(for itemCount: Int) -> Double {
        if itemCount <= 4 {
            return min(300.0, Double(itemCount - 1) * anglePerItem)
        }
        return totalSpan
    }
    
    
    // Enhanced function to get visible items for smooth carousel with infinite scrolling
    func getVisibleItemsForCarousel() -> [(pizza: Pizza, index: Int, visualIndex: Int)] {
        var result: [(pizza: Pizza, index: Int, visualIndex: Int)] = []
        
        if !isMainMenuScrollingEnabled {
            // Static mode: show all items in their natural order starting from 0
            for i in 0..<pizzas.count {
                result.append((pizza: pizzas[i], index: i, visualIndex: i))
            }
            return result
        }
        
        // Scrollable mode: use original carousel logic with infinite wrapping
        // Calculate the floating point offset based on continuous rotation
        let floatingOffset = continuousRotation / anglePerItem
        
        // Buffer for smooth scrolling
        let bufferItems = 2
        let startIndex = Int(floor(floatingOffset)) - bufferItems
        let endIndex = startIndex + maxVisibleItems + (bufferItems * 2)
        
        for i in startIndex...endIndex {
            // Proper modulo handling for negative numbers to ensure infinite wrapping
            let actualIndex = modulo(i, pizzas.count)
            let visualIndex = i
            result.append((pizza: pizzas[actualIndex], index: actualIndex, visualIndex: visualIndex))
        }
        
        return result
    }
    
    // Helper function for proper modulo operation that handles negative numbers
    func modulo(_ a: Int, _ b: Int) -> Int {
        let remainder = a % b
        return remainder >= 0 ? remainder : remainder + b
    }
    
    // Function to calculate if an item should be visible based on its angle
    func shouldItemBeVisible(visualIndex: Int) -> Bool {
        if !isMainMenuScrollingEnabled {
            // Static mode: all items are visible
            return true
        }
        
        // Scrollable mode: use original visibility logic
        let itemRotation = Double(visualIndex) * anglePerItem - continuousRotation
        let normalizedRotation = ((itemRotation + 180).truncatingRemainder(dividingBy: 360)) - 180
        
        // Use original visibility threshold for scrollable items
        let visibilityThreshold = (totalSpan / 2) + (anglePerItem * 0.8)
        return abs(normalizedRotation) <= visibilityThreshold
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            
            // Debug info at the top
            debugInfoView
            
            GeometryReader { geometry in
                let size = geometry.size
                ZStack {
                    // Enhanced carousel items
                    if showPizzaCards {
                        carouselItemsView
                    }
                    
                    // Submenu items (second layer)
                    if showingSubMenuForIndex != nil {
                        subMenuItemsView
                    }
                    
                    // Sub-submenu items (third layer)
                    if showingSubSubMenuForIndex != nil {
                        subSubMenuItemsView
                    }
                    
                    // Main FAB button
                    mainFabButton
                }
                .frame(width: size.width, height: size.height, alignment: alignment.toAlignment)
                .padding(.top, -20)
            }
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var debugInfoView: some View {
        VStack {
            if showPizzaCards {
                VStack(spacing: 4) {
                    HStack {
                        Text("Rotation: \(String(format: "%.1f", continuousRotation))°")
                            .foregroundColor(.white)
                            .font(.caption)
                        Text("| Items: \(pizzas.count)")
                            .foregroundColor(.gray)
                            .font(.caption)
                        Text("| Scroll: \(isMainMenuScrollingEnabled ? "ON" : "OFF")")
                            .foregroundColor(isMainMenuScrollingEnabled ? .green : .red)
                            .font(.caption)
                    }
                    
                    // Show infinite scrolling position only if scrolling is enabled
                    if isMainMenuScrollingEnabled {
                        let currentPosition = continuousRotation / anglePerItem
                        HStack {
                            Text("Position: \(String(format: "%.1f", currentPosition))")
                                .foregroundColor(.cyan)
                                .font(.caption2)
                            Text("| Visible: \(animatedIndices.count)")
                                .foregroundColor(.orange)
                                .font(.caption2)
                        }
                    } else {
                        HStack {
                            Text("Static Mode: All \(pizzas.count) items visible")
                                .foregroundColor(.yellow)
                                .font(.caption2)
                        }
                    }
                    
                    // Show submenu debug info when a submenu is open
                    if let selectedIndex = showingSubMenuForIndex,
                       let subMenuItems = pizzas[selectedIndex].subMenuItems {
                        Divider()
                            .background(Color.gray)
                            .frame(width: 200)
                            .padding(.vertical, 4)
                        
                        HStack {
                            Text("Submenu: \(String(format: "%.1f", subMenuRotation))°")
                                .foregroundColor(.white)
                                .font(.caption)
                            Text("| Items: \(subMenuItems.count)")
                                .foregroundColor(.gray)
                                .font(.caption)
                            Text("| Scroll: \(isSubMenuScrollingEnabled(for: selectedIndex) ? "ON" : "OFF")")
                                .foregroundColor(isSubMenuScrollingEnabled(for: selectedIndex) ? .green : .red)
                                .font(.caption)
                        }
                        
                        // Show submenu controls if scrolling is enabled
                        if isSubMenuScrollingEnabled(for: selectedIndex) {
                            HStack(spacing: 20) {
                                Button("◀") {
                                    rotateSubMenuToPreviousItem()
                                }
                                .foregroundColor(.white)
                                .font(.title3)
                                
                                Button("▶") {
                                    rotateSubMenuToNextItem()
                                }
                                .foregroundColor(.white)
                                .font(.title3)
                            }
                            .padding(.top, 2)
                        }
                    }
                }
                .padding(.top, 50)
                
                // Test controls for infinite scrolling - only show if scrolling is enabled
                if isMainMenuScrollingEnabled {
                    HStack(spacing: 20) {
                        Button("◀") {
                            rotateToPreviousItem()
                        }
                        .foregroundColor(.white)
                        .font(.title2)
                        
                        Button("▶") {
                            rotateToNextItem()
                        }
                        .foregroundColor(.white)
                        .font(.title2)
                    }
                    .padding(.top, 5)
                }
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    private var carouselItemsView: some View {
        let visibleItems = getVisibleItemsForCarousel()
        
        ZStack {
            ForEach(Array(visibleItems.enumerated()), id: \.element.index) { _, item in
                let (itemRotation, itemAngle, opacity) = calculateItemProperties(for: item)
                
                // Only show item if it's visible
                if shouldItemBeVisible(visualIndex: item.visualIndex) {
                    // Additional safety check: only render items with meaningful opacity
                    if opacity > 0.05 {
                        // Calculate initial position for chaining animation
                        let initialPosition = getInitialPositionForChaining(itemIndex: item.index)
                        
                        PizzaCard(pizza: item.pizza, itemNumber: item.index + 1)
                            .rotationEffect(.degrees(-itemAngle))
                            .offset(
                                x: animatedIndices.contains(item.visualIndex) ? radius * cos(itemAngle * .pi / 180) : initialPosition.x,
                                y: animatedIndices.contains(item.visualIndex) ? radius * sin(itemAngle * .pi / 180) : initialPosition.y
                            )
                            .scaleEffect(animatedIndices.contains(item.visualIndex) ? 1 : 0.1)
                            .opacity(opacity)
                            .animation(isDragging ? .none : .spring(response: 0.5, dampingFraction: 0.7), value: animatedIndices)
                            .animation(isDragging ? .none : .linear(duration: 0.15), value: continuousRotation)
                            .onTapGesture {
                                handlePizzaCardTap(index: item.index)
                            }
                            .onChange(of: itemAngle) { _, _ in
                                if isCardNearTriangle(itemAngle) {
                                    nameofPizza = item.pizza.pizza
                                    priceofPizza = item.pizza.pizzaPrice
                                }
                            }
                    }
                }
            }
        }
        .gesture(isMainMenuScrollingEnabled && showingSubMenuForIndex == nil ? mainMenuDragGesture : nil) // Conditional drag gesture - disabled when submenus are open
    }
    
    // Helper function to calculate item properties
    private func calculateItemProperties(for item: (pizza: Pizza, index: Int, visualIndex: Int)) -> (rotation: Double, angle: Double, opacity: Double) {
        if !isMainMenuScrollingEnabled {
            // Static mode: use simple sequential positioning starting from base angle
            let staticItemRotation = Double(item.index) * anglePerItem
            let staticItemAngle = alignment.itemAngleForCarousel(rotation: staticItemRotation)
            return (staticItemRotation, staticItemAngle, 1.0)
        }
        
        // Scrollable mode: use original carousel positioning logic
        let itemRotation = Double(item.visualIndex) * anglePerItem - continuousRotation
        let itemAngle = alignment.itemAngleForCarousel(rotation: itemRotation)
        let opacity = getItemOpacity(visualIndex: item.visualIndex)
        
        return (itemRotation, itemAngle, opacity)
    }
    
    @ViewBuilder
    private var subMenuItemsView: some View {
        if let selectedIndex = showingSubMenuForIndex,
           let subMenuItems = pizzas[selectedIndex].subMenuItems {
            
            ZStack {
                // Use carousel-style approach for submenu items
                let visibleSubMenuItems = getVisibleItemsForSubMenu(selectedIndex: selectedIndex, subMenuItems: subMenuItems)
                
                ForEach(Array(visibleSubMenuItems.enumerated()), id: \.element.index) { _, item in
                    let (itemRotation, subPizzaAngle, opacity) = calculateSubMenuItemProperties(
                        for: item,
                        selectedIndex: selectedIndex
                    )
                    
                    // Only show item if it's visible
                    if shouldSubMenuItemBeVisible(visualIndex: item.visualIndex, selectedIndex: selectedIndex) {
                        // Additional safety check: only render items with meaningful opacity
                        if opacity > 0.05 {
                            // Use fixed main item angle for consistent anchoring
                            let fixedMainItemAngle = getFixedMainItemAngle(for: selectedIndex)
                            
                            // Calculate start position for animation
                            let startPosition = CGPoint(
                                x: radius * cos(fixedMainItemAngle * .pi / 180),
                                y: radius * sin(fixedMainItemAngle * .pi / 180)
                            )
                            
                            // Calculate positions for smooth animation
                            let animatedPosition = CGPoint(
                                x: subMenuRadius * cos(subPizzaAngle * .pi / 180),
                                y: subMenuRadius * sin(subPizzaAngle * .pi / 180)
                            )

                            // Create hierarchical index for submenu items
                            let hierarchicalIndex = "\(selectedIndex + 1).\(item.index + 1)"

                            PizzaCard(pizza: item.pizza, hierarchicalIndex: hierarchicalIndex, cardSize: 45) // Smaller size for submenu items
                                .rotationEffect(.degrees(-subPizzaAngle))
                                .offset(
                                    x: subMenuAnimatedIndices.contains(item.visualIndex) ? animatedPosition.x : startPosition.x,
                                    y: subMenuAnimatedIndices.contains(item.visualIndex) ? animatedPosition.y : startPosition.y
                                )
                                .scaleEffect(subMenuAnimatedIndices.contains(item.visualIndex) ? 1 : 0.1)
                                .opacity(opacity)
                                .animation(isSubMenuDragging ? .none : .spring(response: 0.5, dampingFraction: 0.6), value: subMenuAnimatedIndices)
                                .animation(isSubMenuDragging ? .none : .linear(duration: 0.15), value: subMenuRotation)
                                .onTapGesture {
                                    handleSubMenuItemTap(mainIndex: selectedIndex, subIndex: item.index, subMenuItem: item.pizza)
                                }
                        }
                    }
                }
            }
            .gesture(isSubMenuScrollingEnabled(for: selectedIndex) && showingSubSubMenuForIndex == nil ? subMenuDragGesture : nil) // Conditional drag gesture - disabled when sub-submenus are open
        }
    }
    
    @ViewBuilder
    private var subSubMenuItemsView: some View {
        if let (mainIndex, subIndex) = showingSubSubMenuForIndex,
           let subMenuItems = pizzas[mainIndex].subMenuItems,
           subIndex < subMenuItems.count,
           let subSubMenuItems = subMenuItems[subIndex].subMenuItems {
            
            ZStack {
                ForEach(subSubMenuItems.indices, id: \.self) { subSubIndex in
                    let subSubPizzaAngle = calculateSubSubMenuAngle(
                        mainIndex: mainIndex,
                        subIndex: subIndex,
                        subSubIndex: subSubIndex,
                        subSubMenuItems: subSubMenuItems
                    )
                    
                    // Calculate parent submenu item's angle using the same simple pattern
                    let parentSubMenuAngle: Double = {
                        if isSubMenuScrollingEnabled(for: mainIndex) {
                            // If parent submenu is scrollable, use current submenu rotation
                            let subItemRotation = Double(subIndex) * anglePerItem - subMenuRotation
                            return alignment.itemAngleForCarousel(rotation: subItemRotation)
                        } else {
                            // If parent submenu is static, use simple sequential positioning
                            let staticSubItemRotation = Double(subIndex) * anglePerItem
                            return alignment.itemAngleForCarousel(rotation: staticSubItemRotation)
                        }
                    }()
                    
                    // Calculate positions - start from parent submenu item's position
                    let parentSubMenuFixedPosition = CGPoint(
                        x: subMenuRadius * cos(parentSubMenuAngle * .pi / 180),
                        y: subMenuRadius * sin(parentSubMenuAngle * .pi / 180)
                    )
                    
                    let animatedPosition = CGPoint(
                        x: subSubMenuRadius * cos(subSubPizzaAngle * .pi / 180),
                        y: subSubMenuRadius * sin(subSubPizzaAngle * .pi / 180)
                    )

                    // Create hierarchical index (full three-level hierarchy)
                    let hierarchicalIndex = "\(mainIndex + 1).\(subIndex + 1).\(subSubIndex + 1)"
                    
                    PizzaCard(pizza: subSubMenuItems[subSubIndex], hierarchicalIndex: hierarchicalIndex, cardSize: 35) // Even smaller size for sub-submenu items
                        .rotationEffect(.degrees(-subSubPizzaAngle))
                        .offset(
                            x: subSubMenuAnimatedIndices.contains(subSubIndex) ? animatedPosition.x : parentSubMenuFixedPosition.x,
                            y: subSubMenuAnimatedIndices.contains(subSubIndex) ? animatedPosition.y : parentSubMenuFixedPosition.y
                        )
                        .scaleEffect(subSubMenuAnimatedIndices.contains(subSubIndex) ? 1 : 0.1)
                        .opacity(subSubMenuAnimatedIndices.contains(subSubIndex) ? 1 : 0.3)
                        .animation(isSubSubMenuDragging ? .none : .spring(response: 0.5, dampingFraction: 0.6), value: subSubMenuAnimatedIndices)
                        .animation(isSubSubMenuDragging ? .none : .linear(duration: 0.15), value: subSubMenuRotation)
                        .onTapGesture {
                            nameofPizza = subSubMenuItems[subSubIndex].pizza
                            priceofPizza = subSubMenuItems[subSubIndex].pizzaPrice
                            // Close sub-submenu after selection
                            closeSubSubMenu()
                        }
                }
            }
            .gesture(isSubSubMenuScrollingEnabled(for: mainIndex, subIndex: subIndex) ? subSubMenuDragGesture : nil) // Conditional drag gesture
        }
    }
    
    // Helper function to calculate sub-submenu angle
    private func calculateSubSubMenuAngle(mainIndex: Int, subIndex: Int, subSubIndex: Int, subSubMenuItems: [Pizza]) -> Double {
        // Calculate sub-submenu positioning using the same simple pattern as main menu
        if isSubSubMenuScrollingEnabled(for: mainIndex, subIndex: subIndex) {
            // Scrollable mode: use the exact same pattern as main menu items
            let itemRotation = Double(subSubIndex) * anglePerItem - subSubMenuRotation
            return alignment.itemAngleForCarousel(rotation: itemRotation)
        } else {
            // Static mode: use simple sequential positioning like main menu
            let staticItemRotation = Double(subSubIndex) * anglePerItem
            return alignment.itemAngleForCarousel(rotation: staticItemRotation)
        }
    }
    
    @ViewBuilder
    private var mainFabButton: some View {
        Button(action: {
            if showingSubMenuForIndex != nil {
                closeSubMenu()
            }

            showPizzaCards.toggle()
            if showPizzaCards {
                // Reset all scroll positions to zero for consistent starting point
                resetAllScrollPositions()
                startEnhancedSequentialAnimation()
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
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                }
                
                let translation = value.translation
                
                // Direct linear mapping: drag distance directly controls rotation
                // Positive translation.width (drag right) = positive rotation (scroll right)
                // Negative translation.width (drag left) = negative rotation (scroll left)
                let rotationSensitivity: Double = 1.5 // Adjusted for more natural feel
                let delta = Double(translation.width) * rotationSensitivity
                
                continuousRotation = startAngle + delta
                
                // Update visible items silently during drag for seamless continuous scrolling
                updateVisibleItemsAnimation()
            }
            .onEnded { value in
                isDragging = false
                startAngle = continuousRotation
                
                // Add momentum/inertia for natural wheel feel
                let velocity = value.velocity.width
                
                if abs(velocity) > 100 { // Only add momentum for fast swipes
                    // Direct linear momentum: velocity directly affects rotation
                    let momentumRotation = Double(velocity) * 0.002 // Adjusted for linear mapping
                    
                    withAnimation(.easeOut(duration: 0.6)) { // Shorter duration for snappier feel
                        continuousRotation += momentumRotation
                        startAngle = continuousRotation
                    }
                    
                    // Update after momentum animation with shorter delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        updatePizzaDetailsForCarousel()
                        updateVisibleItemsAnimation()
                    }
                } else {
                    updatePizzaDetailsForCarousel()
                    updateVisibleItemsAnimation()
                }
            }
    }
    
    // Independent drag gesture for main menu
    private var mainMenuDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                }
                
                let translation = value.translation
                let rotationSensitivity: Double = 1.5
                let delta = Double(translation.width) * rotationSensitivity
                
                continuousRotation = startAngle + delta
                updateVisibleItemsAnimation()
            }
            .onEnded { value in
                isDragging = false
                startAngle = continuousRotation
                
                let velocity = value.velocity.width
                
                if abs(velocity) > 100 {
                    let momentumRotation = Double(velocity) * 0.002
                    
                    withAnimation(.easeOut(duration: 0.6)) {
                        continuousRotation += momentumRotation
                        startAngle = continuousRotation
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        updatePizzaDetailsForCarousel()
                        updateVisibleItemsAnimation()
                    }
                } else {
                    updatePizzaDetailsForCarousel()
                    updateVisibleItemsAnimation()
                }
            }
    }
    
    // Independent drag gesture for submenu with carousel-style scrolling
    private var subMenuDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if !isSubMenuDragging {
                    isSubMenuDragging = true
                }
                
                let translation = value.translation
                let rotationSensitivity: Double = 1.5
                let delta = Double(translation.width) * rotationSensitivity
                
                subMenuRotation = subMenuStartAngle + delta
                
                // Update visible items silently during drag for seamless continuous scrolling
                if let selectedIndex = showingSubMenuForIndex {
                    updateVisibleSubMenuItemsAnimation(for: selectedIndex)
                }
            }
            .onEnded { value in
                isSubMenuDragging = false
                subMenuStartAngle = subMenuRotation
                
                let velocity = value.velocity.width
                
                if abs(velocity) > 100 {
                    let momentumRotation = Double(velocity) * 0.002
                    
                    withAnimation(.easeOut(duration: 0.6)) {
                        subMenuRotation += momentumRotation
                        subMenuStartAngle = subMenuRotation
                    }
                    
                    // Update after momentum animation with shorter delay
                    if let selectedIndex = showingSubMenuForIndex {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            updateVisibleSubMenuItemsAnimation(for: selectedIndex)
                        }
                    }
                } else if let selectedIndex = showingSubMenuForIndex {
                    updateVisibleSubMenuItemsAnimation(for: selectedIndex)
                }
            }
    }
    
    // Independent drag gesture for sub-submenu
    private var subSubMenuDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if !isSubSubMenuDragging {
                    isSubSubMenuDragging = true
                }
                
                let translation = value.translation
                let rotationSensitivity: Double = 1.5
                let delta = Double(translation.width) * rotationSensitivity
                
                subSubMenuRotation = subSubMenuStartAngle + delta
            }
            .onEnded { value in
                isSubSubMenuDragging = false
                subSubMenuStartAngle = subSubMenuRotation
                
                let velocity = value.velocity.width
                
                if abs(velocity) > 100 {
                    let momentumRotation = Double(velocity) * 0.002
                    
                    withAnimation(.easeOut(duration: 0.6)) {
                        subSubMenuRotation += momentumRotation
                        subSubMenuStartAngle = subSubMenuRotation
                    }
                }
            }
    }

    // Enhanced helper functions for carousel with improved infinite scrolling
    func getItemOpacity(visualIndex: Int) -> Double {
        if !isMainMenuScrollingEnabled {
            // Static mode: all items have full opacity
            return 1.0
        }
        
        // Scrollable mode: existing opacity logic
        let itemRotation = Double(visualIndex) * anglePerItem - continuousRotation
        let normalizedRotation = ((itemRotation + 180).truncatingRemainder(dividingBy: 360)) - 180
        let coreDistance = totalSpan / 2 // Core visible area
        let bufferDistance = coreDistance + (anglePerItem * 0.8) // Extended area with increased buffer
        let distance = abs(normalizedRotation)
        
        // Full opacity for items in the core circular area
        if distance <= coreDistance {
            return 1.0
        }
        // Stronger fade for items in the buffer zone to prevent them from appearing outside the boundary
        else if distance <= bufferDistance {
            let fadeDistance = distance - coreDistance
            let fadeRange = bufferDistance - coreDistance
            let fadeRatio = fadeDistance / fadeRange
            
            // Even stronger fade to ensure edge items are barely visible and don't appear outside boundary
            return max(0.0, 1.0 - (fadeRatio * 0.9)) // Fade from 100% to 10% opacity
        } else {
            return 0.0 // Completely hidden for items outside the buffer
        }
    }
    
    func getMainItemAngle(for itemIndex: Int) -> Double {
        let visibleItems = getVisibleItemsForCarousel()
        for item in visibleItems {
            if item.index == itemIndex {
                let itemRotation = Double(item.visualIndex) * anglePerItem - continuousRotation
                return alignment.itemAngleForCarousel(rotation: itemRotation)
            }
        }
        return 0.0
    }
    
    // New function to get fixed base angle for main menu items (for anchoring submenus)
    func getFixedMainItemAngle(for itemIndex: Int) -> Double {
        // Calculate the fixed base angle without considering main menu's current rotation
        // This ensures submenus stay anchored to their parent's original position
        let baseVisualIndex = itemIndex // Use the actual index as visual index for fixed positioning
        let itemRotation = Double(baseVisualIndex) * anglePerItem
        return alignment.itemAngleForCarousel(rotation: itemRotation)
    }
    
    func startEnhancedSequentialAnimation() {
        animatedIndices.removeAll()
        let visibleItems = getVisibleItemsForCarousel()
        
        // Sort visible items by their actual pizza index for proper chaining sequence
        let sortedVisibleItems = visibleItems
            .filter { shouldItemBeVisible(visualIndex: $0.visualIndex) }
            .sorted { $0.index < $1.index }
        
        // Create staggered chaining animation where each item appears from the previous one
        for (sequenceIndex, item) in sortedVisibleItems.enumerated() {
            let animationDelay = Double(sequenceIndex) * 0.30 // Increased delay for better chaining effect
            
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
//                withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3)) {
                    animatedIndices.insert(item.visualIndex)
//                }
            }
        }
    }
    
    func updatePizzaDetailsForCarousel() {
        // Find the item closest to the reference position (triangle)
        let visibleItems = getVisibleItemsForCarousel()
        var closestItem: (pizza: Pizza, index: Int, visualIndex: Int)?
        var smallestDistance: Double = Double.infinity
        
        for item in visibleItems {
            if shouldItemBeVisible(visualIndex: item.visualIndex) {
                let itemRotation = Double(item.visualIndex) * anglePerItem - continuousRotation
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
            nameofPizza = item.pizza.pizza
            priceofPizza = item.pizza.pizzaPrice
        }
    }
    
    // Function to update animation state for items entering/leaving visibility during continuous scrolling
    func updateVisibleItemsAnimation() {
        let visibleItems = getVisibleItemsForCarousel()
        var newAnimatedIndices = Set<Int>()
        
        for item in visibleItems {
            if shouldItemBeVisible(visualIndex: item.visualIndex) {
                newAnimatedIndices.insert(item.visualIndex)
            }
        }
        
        // During dragging, update items silently without animation for seamless transitions
        if isDragging {
            // Silently add newly visible items without animation
            for visualIndex in newAnimatedIndices {
                if !animatedIndices.contains(visualIndex) {
                    animatedIndices.insert(visualIndex)
                }
            }
            
            // Silently remove items that are no longer visible without animation
            let indicesToRemove = animatedIndices.subtracting(newAnimatedIndices)
            for visualIndex in indicesToRemove {
                animatedIndices.remove(visualIndex)
            }
        } else {
            // When not dragging, use subtle animations for entering/exiting items
            for visualIndex in newAnimatedIndices {
                if !animatedIndices.contains(visualIndex) {
                    withAnimation(.easeIn(duration: 0.2)) {
                        animatedIndices.insert(visualIndex)
                    }
                }
            }
            
            // Remove items that are no longer visible
            let indicesToRemove = animatedIndices.subtracting(newAnimatedIndices)
            for visualIndex in indicesToRemove {
                withAnimation(.easeOut(duration: 0.15)) {
                    animatedIndices.remove(visualIndex)
                }
            }
        }
    }

    // Function to handle pizza card tap
    func handlePizzaCardTap(index: Int) {
        // If there's already an open submenu
        if let currentOpenSubmenu = showingSubMenuForIndex {
            // If the same item is tapped again, close the submenu
            if currentOpenSubmenu == index {
                closeSubMenu()
                return
            }
            // If a different item is tapped, close the current submenu
            closeSubMenu()
        }

        // Only open a submenu if the item has submenu items
        if let subItems = pizzas[index].subMenuItems, !subItems.isEmpty {
            // Reset main menu drag state when opening submenu
            isDragging = false
            
            showingSubMenuForIndex = index
            startSubMenuSequentialAnimation(itemCount: subItems.count)
        } else {
            // For items without submenus, just update the selected pizza details
            nameofPizza = pizzas[index].pizza
            priceofPizza = pizzas[index].pizzaPrice
        }
    }
    
    // Function to handle submenu item tap
    func handleSubMenuItemTap(mainIndex: Int, subIndex: Int, subMenuItem: Pizza) {
        // If there's already an open sub-submenu
        if let currentOpenSubSubMenu = showingSubSubMenuForIndex {
            // If the same submenu item is tapped again, close the sub-submenu
            if currentOpenSubSubMenu.mainIndex == mainIndex && currentOpenSubSubMenu.subIndex == subIndex {
                closeSubSubMenu()
                return
            }
            // If a different submenu item is tapped, close the current sub-submenu
            closeSubSubMenu()
        }

        // Only open a sub-submenu if the submenu item has sub-submenu items
        if let subSubItems = subMenuItem.subMenuItems, !subSubItems.isEmpty {
            showingSubSubMenuForIndex = (mainIndex: mainIndex, subIndex: subIndex)
            startSubSubMenuSequentialAnimation(itemCount: subSubItems.count)
        } else {
            // For submenu items without sub-submenus, just update the selected pizza details
            nameofPizza = subMenuItem.pizza
            priceofPizza = subMenuItem.pizzaPrice
        }
    }
    
    // Function to reset all scroll positions to zero for consistent menu opening
    func resetAllScrollPositions() {
        // Reset main menu scroll position
        continuousRotation = 0.0
        startAngle = 0.0
        
        // Reset submenu scroll position
        subMenuRotation = 0.0
        subMenuStartAngle = 0.0
        
        // Reset sub-submenu scroll position
        subSubMenuRotation = 0.0
        subSubMenuStartAngle = 0.0
    }

    // Function to update animation state for submenu items entering/leaving visibility during continuous scrolling
    func updateVisibleSubMenuItemsAnimation(for selectedIndex: Int) {
        guard let subMenuItems = pizzas[selectedIndex].subMenuItems else { return }
        
        let visibleItems = getVisibleItemsForSubMenu(selectedIndex: selectedIndex, subMenuItems: subMenuItems)
        var newAnimatedIndices = Set<Int>()
        
        for item in visibleItems {
            if shouldSubMenuItemBeVisible(visualIndex: item.visualIndex, selectedIndex: selectedIndex) {
                newAnimatedIndices.insert(item.visualIndex)
            }
        }
        
        // During dragging, update items silently without animation for seamless transitions
        if isSubMenuDragging {
            // Silently add newly visible items without animation
            for visualIndex in newAnimatedIndices {
                if !subMenuAnimatedIndices.contains(visualIndex) {
                    subMenuAnimatedIndices.insert(visualIndex)
                }
            }
            
            // Silently remove items that are no longer visible without animation
            let indicesToRemove = subMenuAnimatedIndices.subtracting(newAnimatedIndices)
            for visualIndex in indicesToRemove {
                subMenuAnimatedIndices.remove(visualIndex)
            }
        } else {
            // When not dragging, use subtle animations for entering/exiting items
            for visualIndex in newAnimatedIndices {
                if !subMenuAnimatedIndices.contains(visualIndex) {
                    withAnimation(.easeIn(duration: 0.2)) {
                        subMenuAnimatedIndices.insert(visualIndex)
                    }
                }
            }
            
            // Remove items that are no longer visible
            let indicesToRemove = subMenuAnimatedIndices.subtracting(newAnimatedIndices)
            for visualIndex in indicesToRemove {
                withAnimation(.easeOut(duration: 0.15)) {
                    subMenuAnimatedIndices.remove(visualIndex)
                }
            }
        }
    }
    
    func closeSubMenu() {
        showingSubMenuForIndex = nil
        subMenuAnimatedIndices.removeAll()
        // Reset submenu rotation when closing
        subMenuRotation = 0.0
        subMenuStartAngle = 0.0
        // Also close any open sub-submenus
        closeSubSubMenu()
    }
    
    func closeSubSubMenu() {
        showingSubSubMenuForIndex = nil
        subSubMenuAnimatedIndices.removeAll()
        // Reset sub-submenu rotation when closing
        subSubMenuRotation = 0.0
        subSubMenuStartAngle = 0.0
    }

    // Legacy functions enhanced for continuous infinite scrolling
    func startSequentialAnimation() {
        startEnhancedSequentialAnimation()
    }
    
    func rotateToNextItem() {
        withAnimation(.easeInOut(duration: 0.3)) {
            continuousRotation += anglePerItem
            startAngle = continuousRotation
        }
        updatePizzaDetailsForCarousel()
        updateVisibleItemsAnimation()
    }
    
    func rotateToPreviousItem() {
        withAnimation(.easeInOut(duration: 0.3)) {
            continuousRotation -= anglePerItem
            startAngle = continuousRotation
        }
        updatePizzaDetailsForCarousel()
        updateVisibleItemsAnimation()
    }
    
    // Functions for submenu navigation
    func rotateSubMenuToNextItem() {
        withAnimation(.easeInOut(duration: 0.3)) {
            subMenuRotation += anglePerItem
            subMenuStartAngle = subMenuRotation
        }
        
        // Update visible submenu items
        if let selectedIndex = showingSubMenuForIndex {
            updateVisibleSubMenuItemsAnimation(for: selectedIndex)
        }
    }
    
    func rotateSubMenuToPreviousItem() {
        withAnimation(.easeInOut(duration: 0.3)) {
            subMenuRotation -= anglePerItem
            subMenuStartAngle = subMenuRotation
        }
        
        // Update visible submenu items
        if let selectedIndex = showingSubMenuForIndex {
            updateVisibleSubMenuItemsAnimation(for: selectedIndex)
        }
    }
    
    func restartAnimation() {
        animatedIndices.removeAll()
        startEnhancedSequentialAnimation()
    }
    
    func getVisualIndex(for actualIndex: Int) -> Int {
        let visibleItems = getVisibleItemsForCarousel()
        for item in visibleItems {
            if item.index == actualIndex {
                return item.visualIndex
            }
        }
        return 0
    }

    // Function to calculate initial position for chaining animation
    func getInitialPositionForChaining(itemIndex: Int) -> CGPoint {
        let visibleItems = getVisibleItemsForCarousel()
        let sortedVisibleItems = visibleItems
            .filter { shouldItemBeVisible(visualIndex: $0.visualIndex) }
            .sorted { $0.index < $1.index }
        
        // Find the current item's position in the sorted sequence
        guard let currentItemSequence = sortedVisibleItems.firstIndex(where: { $0.index == itemIndex }) else {
            return CGPoint.zero // Default to center if item not found
        }
        
        if currentItemSequence == 0 {
            // First item comes from the center (star button position)
            return CGPoint.zero
        } else {
            // Subsequent items come from the previous item's final position
            let previousItem = sortedVisibleItems[currentItemSequence - 1]
            let previousItemRotation = Double(previousItem.visualIndex) * anglePerItem - continuousRotation
            let previousItemAngle = alignment.itemAngleForCarousel(rotation: previousItemRotation)
            
            return CGPoint(
                x: radius * cos(previousItemAngle * .pi / 180),
                y: radius * sin(previousItemAngle * .pi / 180)
            )
        }
    }

    // Enhanced function to get visible items for submenu carousel with infinite scrolling
    func getVisibleItemsForSubMenu(selectedIndex: Int, subMenuItems: [Pizza]) -> [(pizza: Pizza, index: Int, visualIndex: Int)] {
        var result: [(pizza: Pizza, index: Int, visualIndex: Int)] = []
        
        if !isSubMenuScrollingEnabled(for: selectedIndex) {
            // Static mode: show all items in their natural order starting from 0
            for i in 0..<subMenuItems.count {
                result.append((pizza: subMenuItems[i], index: i, visualIndex: i))
            }
            return result
        }
        
        // Scrollable mode: use carousel logic with infinite wrapping
        // Calculate the floating point offset based on continuous rotation
        let floatingOffset = subMenuRotation / anglePerItem
        
        // Buffer for smooth scrolling
        let bufferItems = 2
        let startIndex = Int(floor(floatingOffset)) - bufferItems
        let endIndex = startIndex + maxVisibleItems + (bufferItems * 2)
        
        for i in startIndex...endIndex {
            // Proper modulo handling for negative numbers to ensure infinite wrapping
            let actualIndex = modulo(i, subMenuItems.count)
            let visualIndex = i
            result.append((pizza: subMenuItems[actualIndex], index: actualIndex, visualIndex: visualIndex))
        }
        
        return result
    }
    
    // Helper function to calculate submenu item properties
    private func calculateSubMenuItemProperties(for item: (pizza: Pizza, index: Int, visualIndex: Int), selectedIndex: Int) -> (rotation: Double, angle: Double, opacity: Double) {
        if !isSubMenuScrollingEnabled(for: selectedIndex) {
            // Static mode: use simple sequential positioning like main menu
            let staticItemRotation = Double(item.index) * anglePerItem
            let staticItemAngle = alignment.itemAngleForCarousel(rotation: staticItemRotation)
            return (staticItemRotation, staticItemAngle, 1.0)
        }
        
        // Scrollable mode: use the exact same pattern as main menu items
        let itemRotation = Double(item.visualIndex) * anglePerItem - subMenuRotation
        let itemAngle = alignment.itemAngleForCarousel(rotation: itemRotation)
        let opacity = getSubMenuItemOpacity(visualIndex: item.visualIndex, selectedIndex: selectedIndex)
        
        return (itemRotation, itemAngle, opacity)
    }
    
    // Function to calculate if a submenu item should be visible based on its angle
    func shouldSubMenuItemBeVisible(visualIndex: Int, selectedIndex: Int) -> Bool {
        if !isSubMenuScrollingEnabled(for: selectedIndex) {
            // Static mode: all items are visible
            return true
        }
        
        // Scrollable mode: use visibility logic similar to main menu
        let itemRotation = Double(visualIndex) * anglePerItem - subMenuRotation
        let normalizedRotation = ((itemRotation + 180).truncatingRemainder(dividingBy: 360)) - 180
        
        // Use visibility threshold for scrollable items
        let visibilityThreshold = (totalSpan / 2) + (anglePerItem * 0.8)
        return abs(normalizedRotation) <= visibilityThreshold
    }
    
    // Helper function for submenu item opacity
    func getSubMenuItemOpacity(visualIndex: Int, selectedIndex: Int) -> Double {
        if !isSubMenuScrollingEnabled(for: selectedIndex) {
            // Static mode: all items have full opacity
            return 1.0
        }
        
        // Scrollable mode: opacity logic similar to main menu
        let itemRotation = Double(visualIndex) * anglePerItem - subMenuRotation
        let normalizedRotation = ((itemRotation + 180).truncatingRemainder(dividingBy: 360)) - 180
        let coreDistance = totalSpan / 2 // Core visible area
        let bufferDistance = coreDistance + (anglePerItem * 0.8) // Extended area with buffer
        let distance = abs(normalizedRotation)
        
        // Full opacity for items in the core circular area
        if distance <= coreDistance {
            return 1.0
        }
        // Fade for items in the buffer zone
        else if distance <= bufferDistance {
            let fadeDistance = distance - coreDistance
            let fadeRange = bufferDistance - coreDistance
            let fadeRatio = fadeDistance / fadeRange
            
            return max(0.0, 1.0 - (fadeRatio * 0.9)) // Fade from 100% to 10% opacity
        } else {
            return 0.0 // Completely hidden for items outside the buffer
        }
    }
    
    func startSubMenuSequentialAnimation(itemCount: Int) {
        subMenuAnimatedIndices.removeAll() // Reset animation state
        
        // Get visible submenu items
        if let selectedIndex = showingSubMenuForIndex,
           let subMenuItems = pizzas[selectedIndex].subMenuItems {
            
            let visibleItems = getVisibleItemsForSubMenu(selectedIndex: selectedIndex, subMenuItems: subMenuItems)
            
            // Sort visible items by their actual index for proper chaining sequence
            let sortedVisibleItems = visibleItems
                .filter { shouldSubMenuItemBeVisible(visualIndex: $0.visualIndex, selectedIndex: selectedIndex) }
                .sorted { $0.index < $1.index }
            
            // Create staggered chaining animation
            for (sequenceIndex, item) in sortedVisibleItems.enumerated() {
                let animationDelay = Double(sequenceIndex) * 0.1 // Delay for chaining effect
                
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
                    withAnimation(.easeIn) {
                        _ = subMenuAnimatedIndices.insert(item.visualIndex) // Animate each submenu item one by one
                    }
                }
            }
        } else {
            // Fallback to original animation if no visible items
            for index in 0..<itemCount {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                    withAnimation(.easeIn) {
                        _ = subMenuAnimatedIndices.insert(index) // Animate each submenu item one by one
                    }
                }
            }
        }
    }
    
    func startSubSubMenuSequentialAnimation(itemCount: Int) {
        subSubMenuAnimatedIndices.removeAll() // Reset animation state
        for index in 0..<itemCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                withAnimation(.easeIn) {
                    _ = subSubMenuAnimatedIndices.insert(index) // Animate each sub-submenu item one by one
                }
            }
        }
    }

    @ViewBuilder
    func PizzaCard(pizza: Pizza, itemNumber: Int? = nil, hierarchicalIndex: String? = nil, cardSize: CGFloat = 55) -> some View {
        ZStack {
            Image(pizza.pizzaImage)
                .resizable()
                .frame(width: cardSize, height: cardSize)
                .clipShape(Circle())
                .padding(cardSize * 0.07) // Dynamic padding based on card size
            
            // Add digit overlay to show item number or hierarchical index
            let displayText: String = {
                if let hierarchicalIndex = hierarchicalIndex {
                    return hierarchicalIndex
                } else if let itemNumber = itemNumber {
                    return "\(itemNumber)"
                } else {
                    return "\((pizzas.firstIndex(where: { $0.id == pizza.id }) ?? 0) + 1)"
                }
            }()
            
            // Calculate dynamic sizes based on card size and menu level
            let fontSize: CGFloat = {
                if hierarchicalIndex != nil {
                    let levelCount = hierarchicalIndex!.components(separatedBy: ".").count
                    switch levelCount {
                    case 2: return cardSize * 0.20 // Submenu items: smaller font
                    case 3: return cardSize * 0.18 // Sub-submenu items: even smaller font
                    default: return cardSize * 0.25 // Default
                    }
                } else {
                    return cardSize * 0.25 // Main menu items: larger font
                }
            }()
            
            let badgeSize: CGFloat = {
                if hierarchicalIndex != nil {
                    let levelCount = hierarchicalIndex!.components(separatedBy: ".").count
                    switch levelCount {
                    case 2: return cardSize * 0.55 // Submenu badge
                    case 3: return cardSize * 0.60 // Sub-submenu badge (slightly larger to accommodate longer text)
                    default: return cardSize * 0.50
                    }
                } else {
                    return cardSize * 0.40 // Main menu badge
                }
            }()
            
            let offsetMultiplier: CGFloat = cardSize / 55.0 // Scale offset based on card size
            
            Text(displayText)
                .font(.bold(.system(size: fontSize))())
                .foregroundColor(.white)
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.8))
                        .frame(width: badgeSize, height: badgeSize)
                )
                .offset(x: 18 * offsetMultiplier, y: -18 * offsetMultiplier)
        }
    }

    func updatePizzaDetails() {
        updatePizzaDetailsForCarousel()
    }

    func isCardNearTriangle(_ pizzaAngle: Double) -> Bool {
        let triangleAngle = 270.0
        let threshold: Double = 30.0
        let normalizedPizzaAngle = (pizzaAngle + 360.0).truncatingRemainder(dividingBy: 360.0)
        let normalizedTriangleAngle = (triangleAngle + 360.0).truncatingRemainder(dividingBy: 360.0)
        let angleDifference = abs(normalizedPizzaAngle - normalizedTriangleAngle)
        return angleDifference <= threshold || angleDifference >= (360.0 - threshold)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let point1 = CGPoint(x: rect.midX, y: rect.minY)
        let point2 = CGPoint(x: rect.minX, y: rect.maxY)
        let point3 = CGPoint(x: rect.maxX, y: rect.maxY)

        path.move(to: point1)
        path.addLine(to: point2)
        path.addLine(to: point3)
        path.closeSubpath()

        return path
    }
}

struct Pizza : Identifiable {
    var id : UUID = .init()
    var pizza : String
    var pizzaImage : String
    var pizzaPrice : String
    var subMenuItems: [Pizza]?
}

var pizzas : [Pizza] = {
    var basePizzas: [Pizza] = [
        .init(pizza: "Panner Pizza", pizzaImage: "pizza1", pizzaPrice: "200 $", subMenuItems: [
               Pizza(pizza: "Sub Panner Pizza 1", pizzaImage: "pizza1", pizzaPrice: "200 $", subMenuItems: [
                   Pizza(pizza: "Sub-Sub Panner 1A", pizzaImage: "pizza1", pizzaPrice: "205 $"),
                   Pizza(pizza: "Sub-Sub Panner 1B", pizzaImage: "pizza1", pizzaPrice: "215 $")
               ]),
               Pizza(pizza: "Sub Panner Pizza 2", pizzaImage: "pizza1", pizzaPrice: "210 $", subMenuItems: [
                   Pizza(pizza: "Sub-Sub Panner 2A", pizzaImage: "pizza1", pizzaPrice: "225 $"),
                   Pizza(pizza: "Sub-Sub Panner 2B", pizzaImage: "pizza1", pizzaPrice: "235 $"),
                   Pizza(pizza: "Sub-Sub Panner 2C", pizzaImage: "pizza1", pizzaPrice: "245 $")
               ]),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $")
           ]),
        .init(pizza: "Cheese Pizza", pizzaImage: "pizza2",pizzaPrice: "150 $", subMenuItems: nil),
        .init(pizza: "Italian Pizza", pizzaImage: "pizza3",pizzaPrice: "300 $", subMenuItems: [
               Pizza(pizza: "Sub Italian 1", pizzaImage: "pizza3", pizzaPrice: "310 $", subMenuItems: [
                   Pizza(pizza: "Sub-Sub Italian 1A", pizzaImage: "pizza3", pizzaPrice: "315 $"),
                   Pizza(pizza: "Sub-Sub Italian 1B", pizzaImage: "pizza3", pizzaPrice: "325 $")
               ]),
               Pizza(pizza: "Sub Italian 2", pizzaImage: "pizza3", pizzaPrice: "320 $")
           ]),
        .init(pizza: "Margherita Pizza", pizzaImage: "pizza4",pizzaPrice: "180 $", subMenuItems: nil),
        .init(pizza: "Pepperoni Pizza", pizzaImage: "pizza5",pizzaPrice: "220 $", subMenuItems: nil),
        .init(pizza: "Veggie Pizza", pizzaImage: "pizza6",pizzaPrice: "190 $", subMenuItems: nil),
        .init(pizza: "BBQ Pizza", pizzaImage: "pizza7",pizzaPrice: "250 $", subMenuItems: nil),
        .init(pizza: "Hawaiian Pizza", pizzaImage: "pizza8",pizzaPrice: "210 $", subMenuItems: nil),
        .init(pizza: "Meat Lovers", pizzaImage: "pizza1",pizzaPrice: "280 $", subMenuItems: nil),
        .init(pizza: "Four Cheese", pizzaImage: "pizza2",pizzaPrice: "200 $", subMenuItems: nil),
        .init(pizza: "Spicy Jalapeno", pizzaImage: "pizza3",pizzaPrice: "230 $", subMenuItems: nil),
        .init(pizza: "Mushroom Delight", pizzaImage: "pizza4",pizzaPrice: "170 $", subMenuItems: nil),
        .init(pizza: "Seafood Special", pizzaImage: "pizza5",pizzaPrice: "320 $", subMenuItems: nil)
    ]
    
    // Generate additional pizzas to test carousel with 50+ items
    var allPizzas = basePizzas
    let pizzaTypes = ["Supreme", "Mediterranean", "Buffalo Chicken", "White Sauce", "Pesto", "Ranch", "Taco", "Breakfast"]
    let pizzaImages = ["pizza1", "pizza2", "pizza3", "pizza4", "pizza5", "pizza6", "pizza7", "pizza8"]
    
    for i in 14...60 {
        let typeIndex = (i - 14) % pizzaTypes.count
        let imageIndex = (i - 14) % pizzaImages.count
        let price = 150 + (i * 10)
        
        allPizzas.append(.init(
            pizza: "\(pizzaTypes[typeIndex]) Pizza \(i)",
            pizzaImage: pizzaImages[imageIndex],
            pizzaPrice: "\(price) $",
            subMenuItems: nil
        ))
    }
    
    return allPizzas
}()

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
    func itemAngle(index: Int, angle: Double, anglePerPizza: Double) -> Double {
        switch self {
        case .topLeading:
            -(anglePerPizza * Double(index) + 100 + angle - 190.0).truncatingRemainder(dividingBy: 360.0)
        case .topTrailing:
            (anglePerPizza * Double(index) + 280 + angle - 190.0).truncatingRemainder(dividingBy: 360.0)
        case .bottomLeading:
            (anglePerPizza * Double(index) + 100 + angle - 190.0).truncatingRemainder(dividingBy: 360.0)
        case .bottomTrailing:
            -(anglePerPizza * Double(index) + 280 + angle - 190.0).truncatingRemainder(dividingBy: 360.0)
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
}
