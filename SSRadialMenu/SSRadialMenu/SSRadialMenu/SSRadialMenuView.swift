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
                    menuItem: viewModel.menus,
                    radius: menuRadius,
                    action: {
                        isSubmenuActivated.toggle()
                    }
                )
                .background {
                    menuBackGround(
                        menuItem: viewModel.subMenus,
                        radius: subMenuRadius,
                        action: {
                            
                        }
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
    
    func subMenuRotationAngles(at index: Int) -> Angle {
        Angle(degrees: 90.0/Double(viewModel.subMenus.count - 1) * Double(index))
    }
}

extension SSRadialMenuView {
    func menuBackGround(
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
                value: isActivated
            )
        }
    }
    
    func radialMenuBackGround() -> some View {
        ForEach(0..<viewModel.menus.count, id: \.self) { i in
            Button {
                isSubmenuActivated.toggle()
            } label: {
                Circle()
                    .fill(viewModel.menus[i].color)
                    .overlay {
                        Image(systemName: viewModel.menus[i].icon)
                            .frame(width: 30, height: 30)
                            .fontWeight(.semibold)
                            .rotationEffect(-menuRotationAngles(at: i))
                    }
                    .shadow(radius: 10)
                    .frame(width: 50, height: 50)
            }
            .foregroundColor(.black)
            .offset(
                x: -menuRadius * 0.5
            )
            .rotationEffect(menuRotationAngles(at: i))
            .transition(.opacity)
            .animation(
                Animation.easeInOut.delay(Double(viewModel.menus.count - 1 - i) * 0.2),
                value: isActivated
            )
        }
    }
    
    func subMenuBackGround() -> some View {
        ForEach(0..<viewModel.subMenus.count, id: \.self) { i in
            Button {
                isSubmenuActivated = false
            } label: {
                Circle()
                    .fill(viewModel.subMenus[i].color)
                    .overlay {
                        Image(systemName: viewModel.subMenus[i].icon)
                            .frame(width: 30, height: 30)
                            .fontWeight(.semibold)
                            .rotationEffect(-subMenuRotationAngles(at: i))
                    }
                    .shadow(radius: 10)
                    .frame(width: 50, height: 50)
            }
            .foregroundColor(.black)
            .offset(
                x: -subMenuRadius * 0.5
            )
            .rotationEffect(subMenuRotationAngles(at: isSubmenuActivated ? i : viewModel.subMenus.count - 1))
            .transition(.opacity)
            .animation(
                Animation.easeInOut.delay(Double(viewModel.subMenus.count - 1 - i) * 0.2),
                value: isSubmenuActivated
            )
        }
    }
}
