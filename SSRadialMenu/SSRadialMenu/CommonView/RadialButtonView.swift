//
//  MenuButtonView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 07/12/23.
//

import SwiftUI

struct RadialButtonView: View {
    var icon: String
    var backGroundColor: Color
    var size: CGFloat
    var constantRadius = 50.0
    @State private var opened = false
    @State private var rotationValue = 45.0
    @State private var cornerRadius = 18.0
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack{ }
        .frame(width: size, height: size)
        .background(backGroundColor)
        .clipShape(
            .rect(
                topLeadingRadius: opened ? cornerRadius : constantRadius,
                bottomLeadingRadius: constantRadius,
                bottomTrailingRadius: constantRadius,
                topTrailingRadius: constantRadius
            )
        )
        .rotationEffect(.degrees(opened ? rotationValue : 0))
        .animation(.easeInOut, value: cornerRadius)
        .padding(10)
        .padding(10)
        .overlay {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.headline)
                .fontWeight(.bold)
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(opened ? 45 : 0))
                .animation(.easeInOut, value: opened)
        }
        .onTapGesture {
            withAnimation {
                opened.toggle()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    action?()
                    startRotationUpdates()
                }
            }
        }
    }
    
    private func startRotationUpdates() {
        var counter = 0
        let maxWaves = 3
        let totalRotations = maxWaves * 2

        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            if counter < totalRotations {
                if counter % 2 == 0 {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        cornerRadius = 40
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        cornerRadius = 20
                    }
                }
                rotationValue -= 20
                counter += 1
            } else {
                withAnimation {
                    rotationValue = 45.0
                    opened.toggle()
                    timer.invalidate()
                }
            }
        }
    }
}


struct MenusButtonView: View {
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



struct SubMenusButtonView: View {
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
            .offset(x: isActivated ? calcOffset(currentItemIndex: currentItemIndex).x : 0, y: isActivated ? calcOffset(currentItemIndex: currentItemIndex).y : -100)

    }
}


func calcOffset(currentItemIndex: Int) -> (x: CGFloat, y: CGFloat) {
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
