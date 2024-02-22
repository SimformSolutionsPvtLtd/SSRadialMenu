//
//  SSRadialMenuView.swift
//  SSRadialMenuView
//
//  Created by Rishita Panchal on 07/12/23.
//

import SwiftUI

struct SSRadialMenuView: View {
    // MARK: - Variables
    @State var showButtons = false
    @State private var isActivated = false
    @State private var isSubmenuActivated = false
    @ObservedObject var viewModel = MenuViewModel()
}

// MARK: - Body view
extension SSRadialMenuView {
    var body: some View {
        content
    }
}

// MARK: - Private views
extension SSRadialMenuView {
    private var content: some View {
        ZStack {
            RadialButtonView(
                icon: "plus",
                backGroundColor: .blue,
                size: 60
            ) {
                isActivated.toggle()
            }
            .background{
                menuItems(
                    isOpened: isActivated,
                    menuLayer: .first,
                    menuItem: viewModel.menus,
                    action: {
                        isSubmenuActivated.toggle()
                    }
                )
                .background {
                    menuItems(
                        isOpened: isSubmenuActivated,
                        menuLayer: .second,
                        menuItem: viewModel.subMenus,
                        action: { }
                    )
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .bottomTrailing
        )
        .padding(.trailing, 20)
    }
}

extension SSRadialMenuView {
    func menuItems(
        isOpened: Bool,
        menuLayer: MenuLayer,
        menuItem: [MenuItem],
        action: @escaping (() -> Void)
    ) -> some View {
        Group {
            var radiusMultiplier: CGFloat {
                switch menuLayer {
                case .first:
                    return 10
                case .second:
                    return 20
                case .third:
                    return 30
                }
            }
            
            var radius: CGFloat {
                return isOpened ? radiusMultiplier * 19 : 0
            }
            
            ForEach(0..<menuItem.count, id: \.self) { i in
                let angle = Angle(degrees: 90.0/Double(menuItem.count - 1) * Double(i))
                Button(action: action) {
                    Circle()
                        .fill(menuItem[i].color)
                        .overlay {
                            Image(systemName: menuItem[i].icon)
                                .frame(width: 30, height: 30)
                                .fontWeight(.semibold)
                                .rotationEffect(-angle)
                        }
                        .shadow(radius: 10)
                        .frame(width: menuItem[i].size, height:  menuItem[i].size)
                }
                .foregroundColor(.black)
                .offset(x: -radius * 0.5)
                //subMenuRotationAngles(at: isSubmenuActivated ? i : viewModel.subMenus.count - 1)
                .rotationEffect(angle)
                .transition(.opacity)
                .animation(
                    Animation.easeInOut.delay(Double(menuItem.count - 1 - i) * 0.2),
                    value: isOpened
                )
            }
        }
    }
}


// MARK: - Menu layer
enum MenuLayer {
    case first, second, third
}
