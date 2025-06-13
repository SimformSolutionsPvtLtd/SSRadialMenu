//
//  CommonSettingsView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 16/06/25.
//

import SwiftUI

// MARK: - Settings Theme Configuration
struct SettingsTheme {
    let titleColor: Color
    let accentColor: Color
    let backgroundGradient: LinearGradient
    let borderColor: Color
    let title: String
    
    static let calendar = SettingsTheme(
        titleColor: .white,
        accentColor: .blue,
        backgroundGradient: LinearGradient(
            colors: [Color.black.opacity(0.9), Color.gray.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        borderColor: Color.white.opacity(0.3),
        title: "Radial Menu Settings"
    )
    
    static let food = SettingsTheme(
        titleColor: .white,
        accentColor: .orange,
        backgroundGradient: LinearGradient(
            colors: [Color.black.opacity(0.9), Color.orange.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        borderColor: Color.orange.opacity(0.5),
        title: "Food Menu Settings"
    )
}

// MARK: - Common Settings View
struct CommonSettingsView: View {
    @Binding var alignment: AlignmentType
    @Binding var mainCardSize: CGFloat
    @Binding var spinsItemsDuringDrag: Bool
    @Binding var wrapEnabled: Bool
    @Binding var zoomEffectEnabled: Bool
    @Binding var zoomEffectScale: CGFloat
    @Binding var zoomOpacityReduction: Double
    @Binding var scrollThresholdItemCount: Int
    @Binding var scrollingBehavior: ScrollingBehavior
    @Binding var spinWheelSpeed: SpinWheelSpeed
    let theme: SettingsTheme
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            settingsHeader
            settingsContent
        }
        .background(settingsBackground)
        .overlay(settingsBorder)
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
    }
    
    private var settingsHeader: some View {
        HStack {
            Text(theme.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(theme.titleColor)
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(theme.titleColor)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    private var settingsContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                alignmentSection
                sizeEffectsSection
                behaviorSection
                scrollingSection
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var alignmentSection: some View {
        CommonSettingsSection(title: "Alignment", theme: theme) {
            VStack(spacing: 12) {
                HStack {
                    ForEach([AlignmentType.topLeading, .topTrailing], id: \.self) { option in
                        CommonAlignmentButton(
                            alignment: option,
                            isSelected: alignment == option,
                            theme: theme,
                            action: { alignment = option }
                        )
                    }
                }
                HStack {
                    ForEach([AlignmentType.bottomLeading, .bottomTrailing], id: \.self) { option in
                        CommonAlignmentButton(
                            alignment: option,
                            isSelected: alignment == option,
                            theme: theme,
                            action: { alignment = option }
                        )
                    }
                }
            }
        }
    }
    
    private var sizeEffectsSection: some View {
        CommonSettingsSection(title: "Size & Effects", theme: theme) {
            VStack(spacing: 16) {
                CommonSliderSetting(
                    title: "Card Size",
                    value: Binding(
                        get: { Double(mainCardSize) },
                        set: { mainCardSize = CGFloat($0) }
                    ),
                    range: 30...60,
                    format: "%.0f",
                    theme: theme
                )
                
                CommonSliderSetting(
                    title: "Zoom Scale",
                    value: Binding(
                        get: { Double(zoomEffectScale) },
                        set: { zoomEffectScale = CGFloat($0) }
                    ),
                    range: 1.0...1.2,
                    format: "%.1f",
                    theme: theme
                )
                
                CommonSliderSetting(
                    title: "Zoom Opacity Reduction",
                    value: $zoomOpacityReduction,
                    range: 0.0...1.0,
                    format: "%.1f",
                    theme: theme
                )
                
                CommonSliderSetting(
                    title: "Scroll Threshold",
                    value: Binding(
                        get: { Double(scrollThresholdItemCount) },
                        set: { scrollThresholdItemCount = Int($0) }
                    ),
                    range: 3...8,
                    format: "%.0f",
                    theme: theme
                )
            }
        }
    }
    
    private var behaviorSection: some View {
        CommonSettingsSection(title: "Behavior", theme: theme) {
            VStack(spacing: 16) {
                CommonToggleSetting(title: "Spins Items During Drag", isOn: $spinsItemsDuringDrag, theme: theme)
                CommonToggleSetting(title: "Wrap Enabled", isOn: $wrapEnabled, theme: theme)
                CommonToggleSetting(title: "Zoom Effect Enabled", isOn: $zoomEffectEnabled, theme: theme)
            }
        }
    }
    
    private var scrollingSection: some View {
        CommonSettingsSection(title: "Scrolling", theme: theme) {
            VStack(spacing: 16) {
                scrollingBehaviorPicker
                if scrollingBehavior == .spinWheel {
                    spinWheelSpeedPicker
                }
            }
        }
    }
    
    private var scrollingBehaviorPicker: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Scrolling Behavior:")
                    .foregroundColor(theme.titleColor)
                Spacer()
            }
            
            HStack(spacing: 12) {
                ForEach([ScrollingBehavior.simple, .spinWheel], id: \.self) { behavior in
                    Button(action: { scrollingBehavior = behavior }) {
                        Text(behavior == .simple ? "Simple" : "Spin Wheel")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(scrollingBehavior == behavior ? .black : theme.titleColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(scrollingBehavior == behavior ? theme.accentColor : Color.white.opacity(0.2))
                            )
                    }
                }
                Spacer()
            }
        }
    }
    
    private var spinWheelSpeedPicker: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Spin Wheel Speed:")
                    .foregroundColor(theme.titleColor)
                Spacer()
            }
            
            HStack(spacing: 12) {
                ForEach([SpinWheelSpeed.slow, .normal, .fast], id: \.self) { speed in
                    Button(action: { spinWheelSpeed = speed }) {
                        Text(speedText(for: speed))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(spinWheelSpeed == speed ? .black : theme.titleColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(spinWheelSpeed == speed ? theme.accentColor : Color.white.opacity(0.2))
                            )
                    }
                }
                Spacer()
            }
        }
    }
    
    private var settingsBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(theme.backgroundGradient)
    }
    
    private var settingsBorder: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(theme.borderColor, lineWidth: 1)
    }
    
    private func speedText(for speed: SpinWheelSpeed) -> String {
        switch speed {
        case .slow: return "Slow"
        case .normal: return "Normal"
        case .fast: return "Fast"
        }
    }
}

// MARK: - Common Helper Views
struct CommonSettingsSection<Content: View>: View {
    let title: String
    let theme: SettingsTheme
    let content: Content
    
    init(title: String, theme: SettingsTheme, @ViewBuilder content: () -> Content) {
        self.title = title
        self.theme = theme
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(theme.titleColor)
            
            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct CommonAlignmentButton: View {
    let alignment: AlignmentType
    let isSelected: Bool
    let theme: SettingsTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Rectangle()
                        .frame(width: 80, height: 50)
                        .foregroundColor(.white.opacity(0.2))
                        .overlay(
                            Rectangle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                    
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundColor(isSelected ? theme.accentColor : .white)
                        .position(positionForAlignment(alignment))
                }
                
                Text(textForAlignment(alignment))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? theme.accentColor : .white)
            }
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private func positionForAlignment(_ alignment: AlignmentType) -> CGPoint {
        switch alignment {
        case .topLeading: return CGPoint(x: 20, y: 12.5)
        case .topTrailing: return CGPoint(x: 60, y: 12.5)
        case .bottomLeading: return CGPoint(x: 20, y: 37.5)
        case .bottomTrailing: return CGPoint(x: 60, y: 37.5)
        }
    }
    
    private func textForAlignment(_ alignment: AlignmentType) -> String {
        switch alignment {
        case .topLeading: return "Top Left"
        case .topTrailing: return "Top Right"
        case .bottomLeading: return "Bottom Left"
        case .bottomTrailing: return "Bottom Right"
        }
    }
}

struct CommonSliderSetting: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let format: String
    let theme: SettingsTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .foregroundColor(theme.titleColor)
                Spacer()
                Text(String(format: format, value))
                    .foregroundColor(theme.accentColor)
                    .font(.system(size: 14, weight: .semibold))
            }
            
            Slider(value: $value, in: range)
                .accentColor(theme.accentColor)
        }
    }
}

struct CommonToggleSetting: View {
    let title: String
    @Binding var isOn: Bool
    let theme: SettingsTheme
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(theme.titleColor)
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: theme.accentColor))
        }
    }
}

// MARK: - Preview
#Preview {
    CommonSettingsView(
        alignment: .constant(.bottomTrailing),
        mainCardSize: .constant(55.0),
        spinsItemsDuringDrag: .constant(false),
        wrapEnabled: .constant(true),
        zoomEffectEnabled: .constant(true),
        zoomEffectScale: .constant(1.1),
        zoomOpacityReduction: .constant(0.3),
        scrollThresholdItemCount: .constant(4),
        scrollingBehavior: .constant(.spinWheel),
        spinWheelSpeed: .constant(.normal),
        theme: .calendar,
        onDismiss: {}
    )
}
