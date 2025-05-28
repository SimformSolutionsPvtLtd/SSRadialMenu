//
//  CircularView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 02/12/24.
import SwiftUI

struct ContentView: View {
    var body: some View {
        FinalView(alignment: .bottomTrailing)
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
    let radius: CGFloat = 115 // Increased radius for better spacing between items
    let subMenuRadius: CGFloat = 180 // Larger radius for submenus with better spacing
    
    // Enhanced carousel properties
    let maxVisibleItems: Int = 6 // Reduced from 8 to 6 for better spacing
    let totalSpan: Double = 160.0 // Increased span for better spacing between items
    @State private var showPizzaCards: Bool = false
    @State private var continuousRotation: Double = 0.0 // Continuous rotation value
    @State private var isDragging: Bool = false
    
    // Computed properties for smooth carousel
    var anglePerItem: Double {
        totalSpan / Double(maxVisibleItems - 1)
    }
    
    var itemsPerFullRotation: Double {
        360.0 / anglePerItem
    }
    
    
    // Enhanced function to get visible items for smooth carousel with infinite scrolling
    func getVisibleItemsForCarousel() -> [(pizza: Pizza, index: Int, visualIndex: Int)] {
        var result: [(pizza: Pizza, index: Int, visualIndex: Int)] = []
        
        // Calculate the floating point offset based on continuous rotation
        let floatingOffset = continuousRotation / anglePerItem
        
        // Buffer for smooth scrolling with improved spacing
        let bufferItems = 2 // Reduced buffer to minimize overlapping while maintaining smooth scrolling
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
    
    // Function to calculate if an item should be visible based on its angle - enhanced for infinite scrolling
    func shouldItemBeVisible(visualIndex: Int) -> Bool {
        let itemRotation = Double(visualIndex) * anglePerItem - continuousRotation
        let normalizedRotation = ((itemRotation + 180).truncatingRemainder(dividingBy: 360)) - 180
        
        // Expanded visibility threshold for smoother, seamless transitions during dragging
        let visibilityThreshold = (totalSpan / 2) + (anglePerItem * 1.2) // Increased from 0.7 to 1.2 for smoother buffer
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
                    
                    // Main FAB button
                    mainFabButton
                }
                .frame(width: size.width, height: size.height, alignment: alignment.toAlignment)
                .padding(.top, -20)
                .gesture(dragGesture)
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
                    }
                    
                    // Show infinite scrolling position
                    let currentPosition = continuousRotation / anglePerItem
                    HStack {
                        Text("Position: \(String(format: "%.1f", currentPosition))")
                            .foregroundColor(.cyan)
                            .font(.caption2)
                        Text("| Visible: \(animatedIndices.count)")
                            .foregroundColor(.orange)
                            .font(.caption2)
                    }
                }
                .padding(.top, 50)
                
                // Test controls for infinite scrolling
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
            Spacer()
        }
    }
    
    @ViewBuilder
    private var carouselItemsView: some View {
        let visibleItems = getVisibleItemsForCarousel()
        
        ForEach(Array(visibleItems.enumerated()), id: \.element.index) { _, item in
            let itemRotation = Double(item.visualIndex) * anglePerItem - continuousRotation
            let itemAngle = alignment.itemAngleForCarousel(rotation: itemRotation)
            
            // Enhanced visibility check with spacing consideration
            if shouldItemBeVisible(visualIndex: item.visualIndex) {
                // Calculate opacity for smooth fade-in/out at edges
                let opacity = getItemOpacity(visualIndex: item.visualIndex)
                
                // Only show item if opacity is significant enough to avoid ghosting
                if opacity > 0.1 {
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
    
    @ViewBuilder
    private var subMenuItemsView: some View {
        if let selectedIndex = showingSubMenuForIndex,
           let subMenuItems = pizzas[selectedIndex].subMenuItems {
            ForEach(subMenuItems.indices, id: \.self) { subIndex in
                // Find the main item's current angle based on continuous rotation
                let mainItemAngle = getMainItemAngle(for: selectedIndex)
                
                // Calculate submenu positioning
                let subItemCount = Double(subMenuItems.count)
                let subMenuAngleSpan: Double = 120.0
                let subMenuAnglePerItem = subMenuAngleSpan / subItemCount
                let subMenuStartAngle = mainItemAngle - (subMenuAngleSpan / 2) + (subMenuAnglePerItem / 2)
                let subPizzaAngle = subMenuStartAngle + (Double(subIndex) * subMenuAnglePerItem)

                PizzaCard(pizza: subMenuItems[subIndex])
                    .rotationEffect(.degrees(-subPizzaAngle))
                    .offset(
                        x: subMenuAnimatedIndices.contains(subIndex) ? subMenuRadius * cos(subPizzaAngle * .pi / 180) : radius * cos(mainItemAngle * .pi / 180),
                        y: subMenuAnimatedIndices.contains(subIndex) ? subMenuRadius * sin(subPizzaAngle * .pi / 180) : radius * sin(mainItemAngle * .pi / 180)
                    )
                    .scaleEffect(subMenuAnimatedIndices.contains(subIndex) ? 1 : 0.1)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: subMenuAnimatedIndices)
                    .onTapGesture {
                        nameofPizza = subMenuItems[subIndex].pizza
                        priceofPizza = subMenuItems[subIndex].pizzaPrice
                    }
            }
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
                
                // Optimized horizontal wheel rotation for maximum smoothness
                let rotationSensitivity: Double = 2.0
                let delta = Double(translation.width) / radius * (180 / Double.pi) * rotationSensitivity
                
                continuousRotation = startAngle - delta
                
                // Update visible items silently during drag for seamless continuous scrolling
                updateVisibleItemsAnimation()
            }
            .onEnded { value in
                isDragging = false
                startAngle = continuousRotation
                
                // Add momentum/inertia for natural wheel feel
                let velocity = value.velocity.width
                
                if abs(velocity) > 100 { // Only add momentum for fast swipes
                    let momentumRotation = Double(velocity) * 0.0008 // Slightly reduced for smoother momentum
                    
                    withAnimation(.easeOut(duration: 0.6)) { // Shorter duration for snappier feel
                        continuousRotation -= momentumRotation
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

    // Enhanced helper functions for carousel with improved infinite scrolling
    func getItemOpacity(visualIndex: Int) -> Double {
        let itemRotation = Double(visualIndex) * anglePerItem - continuousRotation
        let normalizedRotation = ((itemRotation + 180).truncatingRemainder(dividingBy: 360)) - 180
        let maxDistance = totalSpan / 2
        let distance = abs(normalizedRotation)
        
        if distance <= maxDistance {
            return 1.0
        } else if distance <= maxDistance + anglePerItem {
            // Smoother fade out for seamless transitions during dragging
            let fadeDistance = distance - maxDistance
            let fadeRange = anglePerItem
            let fadeRatio = fadeDistance / fadeRange
            
            // Use a smoother curve for opacity transition
            let smoothOpacity = cos(fadeRatio * .pi / 2)
            return max(0.0, smoothOpacity)
        } else {
            return 0.0
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
            showingSubMenuForIndex = index
            startSubMenuSequentialAnimation(itemCount: subItems.count)
        } else {
            // For items without submenus, just update the selected pizza details
            nameofPizza = pizzas[index].pizza
            priceofPizza = pizzas[index].pizzaPrice
        }
    }

    func closeSubMenu() {
        showingSubMenuForIndex = nil
        subMenuAnimatedIndices.removeAll()
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

    func startSubMenuSequentialAnimation(itemCount: Int) {
        subMenuAnimatedIndices.removeAll() // Reset animation state
        for index in 0..<itemCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                withAnimation(.easeIn) {
                    _ = subMenuAnimatedIndices.insert(index) // Animate each submenu item one by one
                }
            }
        }
    }

    @ViewBuilder
    func PizzaCard(pizza: Pizza, itemNumber: Int? = nil) -> some View {
        ZStack {
            Image(pizza.pizzaImage)
                .resizable()
                .frame(width: 55, height: 55) // Reduced size for better spacing and less overlap
                .clipShape(Circle())
                .padding(4) // Add padding around each pizza card for visual separation
            
            // Add digit overlay to show item number
            let displayNumber = itemNumber ?? (pizzas.firstIndex(where: { $0.id == pizza.id }) ?? 0) + 1
            Text("\(displayNumber)")
                .font(.bold(.system(size: 14))()) // Slightly smaller font size to match smaller card
                .foregroundColor(.white)
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.8))
                        .frame(width: 22, height: 22) // Smaller badge to match smaller card
                )
                .offset(x: 18, y: -18) // Adjusted position for smaller card with padding
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
               Pizza(pizza: "Sub Panner Pizza 1", pizzaImage: "pizza1", pizzaPrice: "200 $"),
               Pizza(pizza: "Sub Panner Pizza 2", pizzaImage: "pizza1", pizzaPrice: "210 $"),
               Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $")
           ]),
        .init(pizza: "Cheese Pizza", pizzaImage: "pizza2",pizzaPrice: "150 $", subMenuItems: nil),
        .init(pizza: "Italian Pizza", pizzaImage: "pizza3",pizzaPrice: "300 $", subMenuItems: [
               Pizza(pizza: "Sub Italian 1", pizzaImage: "pizza3", pizzaPrice: "310 $"),
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
