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
    @State private var shouldDisplaySubSubMenu = false
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
                if !shouldDisplaySubSubMenu {
                    isActivated.toggle()
                }
            }
            .background{
                menuBackGround(
                    isOpened: isActivated,
                    menuItem: viewModel.menus,
                    radius: menuRadius,
                    action: {
                        isSubmenuActivated.toggle()
                    }
                )
                .background {
                    menuBackGround(
                        isOpened: isSubmenuActivated,
                        menuItem: viewModel.subMenus,
                        radius: subMenuRadius,
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
    
    private var menuRadius: CGFloat {
        isActivated ? 190 : 0
    }
    
    private var subMenuRadius: CGFloat {
        isSubmenuActivated ? 380 : 0
    }
    
    func menuRotationAngles(at index: Int) -> Angle {
        Angle(degrees: 90.0/Double(viewModel.menus.count - 1) * Double(index))
    }
}

extension SSRadialMenuView {
    func menuBackGround(
        isOpened: Bool,
        menuItem: [MenuItem],
        radius: CGFloat,
        action: @escaping (() -> Void)
    ) -> some View {
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
                    .frame(width: 50, height: 50)
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
