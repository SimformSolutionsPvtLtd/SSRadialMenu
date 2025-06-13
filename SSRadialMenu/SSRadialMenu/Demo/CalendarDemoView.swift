//
//  CalendarDemoView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 11/06/25.
//

import SwiftUI

struct CalendarDemoView: View {
    let onBack: () -> Void
    
    // State variables to track selected items from each menu level
    @State private var selectedMainItem: RadialMenuItems? = nil
    @State private var selectedSubItem: RadialMenuItems? = nil
    @State private var selectedSubSubItem: RadialMenuItems? = nil
    
    // UI state
    @State private var showSettings = false
    
    // SSRadialMenu configuration parameters
    @State private var alignment: AlignmentType = .bottomTrailing
    @State private var mainCardSize: CGFloat = 55.0
    @State private var spinsItemsDuringDrag: Bool = false
    @State private var wrapEnabled: Bool = true
    @State private var zoomEffectEnabled: Bool = true
    @State private var zoomEffectScale: CGFloat = 1.1
    @State private var zoomOpacityReduction: Double = 0.3
    @State private var scrollThresholdItemCount: Int = 4
    @State private var scrollingBehavior: ScrollingBehavior = .spinWheel
    @State private var spinWheelSpeed: SpinWheelSpeed = .normal

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            
            VStack {
                // Header with back button
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            
                            Text("Back to Selection")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Button(action: { showSettings.toggle() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "gear.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            
                            Text("Settings")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 50)
                .padding(.horizontal, 20)
                
                // Title and Description
                VStack(spacing: 16) {
                    Text("Calendar Menu Demo")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Navigate through months and select dates")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Current selections display
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Selection:")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 30)


                    Group {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            Text("Month: \(selectedMainItem?.name ?? "None")")
                        }
                        
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(.purple)
                            Text("Day: \(selectedSubItem?.name ?? "None")")
                        }
                    }
                    .font(.body)
                    .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Calendar radial menu
                SSRadialMenu(
                    menuItems: calendarMenuItems,
                    alignment: alignment,
                    expandMenuIcon: "calendar.badge.plus",
                    collapseMenuIcon: "calendar.badge.minus",
                    mainCardSize: mainCardSize,
                    spinsItemsDuringDrag: spinsItemsDuringDrag,
                    wrapEnabled: wrapEnabled,
                    zoomEffectEnabled: zoomEffectEnabled,
                    zoomEffectScale: zoomEffectScale,
                    zoomOpacityReduction: zoomOpacityReduction,
                    scrollThresholdItemCount: scrollThresholdItemCount,
                    scrollingBehavior: scrollingBehavior,
                    spinWheelSpeed: spinWheelSpeed,
                    onMainMenuSelection: { item in
                        selectedMainItem = item
                        selectedSubItem = nil // Reset sub selection when main changes
                        print("Main menu selected: \(item.name)")
                    },
                    onSubMenuSelection: { item in
                        selectedSubItem = item
                        print("Sub menu selected: \(item.name)")
                    },
                    onSubSubMenuSelection: { item in
                        selectedSubSubItem = item
                        print("Sub-sub menu selected: \(item.name)")
                    }
                )
            }
        }
        .overlay(
            // Settings overlay
            Group {
                if showSettings {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showSettings = false
                        }
                    
                    VStack {
                        CommonSettingsView(
                            alignment: $alignment,
                            mainCardSize: $mainCardSize,
                            spinsItemsDuringDrag: $spinsItemsDuringDrag,
                            wrapEnabled: $wrapEnabled,
                            zoomEffectEnabled: $zoomEffectEnabled,
                            zoomEffectScale: $zoomEffectScale,
                            zoomOpacityReduction: $zoomOpacityReduction,
                            scrollThresholdItemCount: $scrollThresholdItemCount,
                            scrollingBehavior: $scrollingBehavior,
                            spinWheelSpeed: $spinWheelSpeed,
                            theme: .calendar,
                            onDismiss: { showSettings = false }
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.clear)
                }
            }
        )
    }
}

// Calendar menu items data
private let calendarMenuItems: [RadialMenuItems] = {
    // Create sub items for each month
    var monthOfThirtyFirst: [RadialMenuItems] = []
    for i in 1...31 {
        monthOfThirtyFirst.append(RadialMenuItems(name: "Day \(i)", icon: "\(i).circle"))
    }

    var monthsOfThirty: [RadialMenuItems] = []
    for i in 1...30 {
        monthsOfThirty.append(RadialMenuItems(name: "Day \(i)", icon: "\(i).circle"))
    }

    var februaryDays: [RadialMenuItems] = []
    for i in 1...28 {
        februaryDays.append(RadialMenuItems(name: "Day \(i)", icon: "\(i).circle"))
    }

    return [
        .init(name: "January", icon: "snowflake", badgeText: "1", subMenuItems: monthOfThirtyFirst),
        .init(name: "February", icon: "heart.fill", badgeText: "2", subMenuItems: februaryDays),
        .init(name: "March", icon: "leaf.fill", badgeText: "3", subMenuItems: monthOfThirtyFirst),
        .init(name: "April", icon: "cloud.rain.fill", badgeText: "4", subMenuItems: monthsOfThirty),
        .init(name: "May", icon: "sun.max.fill", badgeText: "5", subMenuItems: monthOfThirtyFirst),
        .init(name: "June", icon: "flame.fill", badgeText: "6", subMenuItems: monthsOfThirty),
        .init(name: "July", icon: "beach.umbrella.fill", badgeText: "7", subMenuItems: monthOfThirtyFirst),
        .init(name: "August", icon: "hurricane", badgeText: "8", subMenuItems: monthOfThirtyFirst),
        .init(name: "September", icon: "tree.fill" , badgeText: "9", subMenuItems: monthsOfThirty),
        .init(name: "October", icon: "moon.haze.fill", badgeText: "10", subMenuItems: monthOfThirtyFirst),
        .init(name: "November", icon: "wind", badgeText: "11", subMenuItems: monthsOfThirty),
        .init(name: "December", icon: "gift.fill", badgeText: "12", subMenuItems: monthOfThirtyFirst)
    ]
}()

#Preview {
    CalendarDemoView(onBack: {})
}
