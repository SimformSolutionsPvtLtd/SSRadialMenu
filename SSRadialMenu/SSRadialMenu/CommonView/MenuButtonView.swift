//
//  MenuButtonView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 07/12/23.
//

import SwiftUI

struct MenuButtonView: View {
    var systemImage: String
    var action: (() -> Void)
    var body: some View {
        Button(action: {
           action()
        }, label: {
            Image(systemName: systemImage)
                .foregroundColor(.white)
                .font(.headline)
                .fontWeight(.bold)
                .frame(width: 60, height: 60)
        })
        .background(Color.blue)
        .clipShape(Circle())
        .padding(10)
    }
}

struct SubMenuButtonView: View {
    @Binding var isActivated: Bool
    @Binding var shouldDisplaySubSubMenu: Bool
    @ObservedObject var viewModel: MenuViewModel
    var currentItemIndex: Int
    var action: (() -> Void)
    var body: some View {
        let menuItem = viewModel.menus[currentItemIndex]
        return Circle()
            .fill(menuItem.color)
            .frame(width: isActivated ? 50 : 0, height: isActivated ? 50 : 0)
            .shadow(radius: 5)
            .overlay(Image(systemName: menuItem.icon))
            .foregroundColor(.white)
            .offset(x: isActivated ? calcOffset().x : 0, y: isActivated ? calcOffset().y : 0)
            .onTapGesture {
                shouldDisplaySubSubMenu.toggle()
                print(shouldDisplaySubSubMenu)
        }
    }
    
    func calcOffset() -> (x: CGFloat, y: CGFloat) {
        switch currentItemIndex {
        case 0:
            return (-65, 10)
        case 1:
            return (-55, -55)
        default:
            return (15, -70)
        }
    }
}



struct SubSubMenuButtonView: View {
    @Binding var isActivated: Bool
    @ObservedObject var viewModel: MenuViewModel
    var currentItemIndex: Int
    var action: (() -> Void)
    var body: some View {
        let menuItem = viewModel.subMenus[currentItemIndex]
        return Circle()
            .fill(menuItem.color)
            .frame(width: isActivated ? 50 : 0, height: isActivated ? 50 : 0)
            .shadow(radius: 5)
            .overlay(Image(systemName: menuItem.icon))
            .foregroundColor(.white)
            .offset(x: isActivated ? calcOffset().x : 0, y: isActivated ? calcOffset().y : 0)

    }
    
    func calcOffset() -> (x: CGFloat, y: CGFloat) {
        switch currentItemIndex {
        case 0:
            return (-130, 20)
        case 1:
            return (-130, -70)
        case 2:
            return (-60, -130)
        default:
            return (20, -140)
        }
    }
}


// MARK: - SubSubMenu
struct SubSubMenu: View {
    var body: some View {
         Text("HEllooo")
    }
}
