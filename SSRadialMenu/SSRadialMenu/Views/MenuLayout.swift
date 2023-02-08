//
//  MenuLayout.swift
//  AnimationPractice
//
//  Created by Bansi Mamtora on 23/01/23.
//

import Foundation
import SwiftUI

struct MenuButton {
    let color: Color
    let image: String
    let size: CGFloat
    let action: () -> Void
}

struct MenuStyle: ViewModifier {
    @Binding var isShowing: Bool
    let menuPopStyle: MenuPopStyle
    let distance: CGFloat
    let autoClose: Bool
    let buttons: [MenuButton]
    
    func body(content: Content) -> some View {
        ZStack {
            content
            fabMenu
        }
    }
    
    private var angleDelta: Double {
        switch menuPopStyle {
        case .linear(let anchor):
            print("##anchor", anchor.anchorPosition)
            return anchor.anchorPosition
        case .circular(let anchor):
            let span = anchor.endAngle - anchor.startAngle
            let n = buttons.count
            let nMinus1 = n - 1
            let candidate = (span / Double(nMinus1))
            return candidate
        }
    }
    
    private func pointFor(angleDelta: Double, index: Int) -> CGPoint {
        
        switch menuPopStyle {
        case .linear(let anchor):
            let space = distance * Double(index + 1)
            switch anchor {
            case .popUp: return CGPoint(x: 0, y: -space)
            case .popDown: return CGPoint(x: 0, y: space)
            case .popLeft: return CGPoint(x: -space, y: 0)
            case .popRight: return CGPoint(x: space, y: 0)
            }
        case .circular(let anchor):
            let angle = anchor.startAngle + angleDelta * Double(index)
            let sine = sin(angle.radians)
            let cose = cos(angle.radians)
            return CGPoint(x: distance * cose, y: (distance * sine))
        }
        
    }
    
    @ViewBuilder private var fabMenu: some View {
        let angle = angleDelta
        
        ZStack {
            ForEach(0..<buttons.count, id: \.self) { i in
                menuButtonStyle(buttons[i],offset: pointFor(angleDelta: angle, index: i))
            }
        }
        .onAppear {
            print("##angleDelta:", angle)
        }
    }
    
    private func menuButtonStyle(_ button: MenuButton,
                                 offset: CGPoint) -> some View {
        return Image(systemName: button.image)
            .frame(width: button.size, height: button.size)
            .background(button.color)
            .cornerRadius(.infinity)
            .shadow(color: .gray, radius: 2, x: 1, y: 1)
            .onTapGesture {
                button.action()
                if autoClose {
                    isShowing.toggle()
                }
            }
            .offset(x: isShowing ? offset.x : 0,
                    y: isShowing ? offset.y :0)
            .opacity(isShowing ? 1 : 0)
            .animation(.spring().speed(1), value: isShowing)
    }
    
    enum MenuPopStyle {
        case linear(LinearDirections)
        case circular(CircularDirections)
    }
    
    enum LinearDirections {
        case popUp,
             popDown,
             popLeft,
             popRight
        
        var anchorPosition: Double {
            return 3 * .pi.degrees / 2
        }
    }
    
    enum CircularDirections {
        case topLeft,
             topRight,
             bottomLeft,
             bottomRight,
             center,
             custom(Angle, Angle)
        
        var startAngle: Double {
            switch self {
            case .topLeft:
                return .pi.degrees
            case .topRight:
                return 3 * .pi.degrees / 2
            case .bottomLeft:
                return .pi.degrees / 2
            case .bottomRight:
                return 0
            case .center:
                return -.pi.degrees / 2
            case .custom(let startAngle, _):
                return startAngle.degrees
            }
        }
        
        var endAngle: Double {
            switch self {
            case .center:
                return 3 * .pi.degrees / 2
            case .custom(_, let endAngle):
                return endAngle.degrees
            default:
                return startAngle + .pi.degrees / 2
            }
        }
    }
}

extension View {
    func radialMenu(isShowing: Binding<Bool>,
                    menuPopStyle: MenuStyle.MenuPopStyle,
                    distance: CGFloat,
                    autoClose: Bool,
                    buttons: [MenuButton]) -> some View {
        self.modifier(MenuStyle(isShowing: isShowing,
                                menuPopStyle: menuPopStyle,
                                distance: distance,
                                autoClose: autoClose,
                                buttons: buttons))
    }
}


extension BinaryFloatingPoint {
    var degrees : Self {
        return self * 180 / .pi
    }
    
    var radians: Self {
        return self * .pi / 180
    }
}
