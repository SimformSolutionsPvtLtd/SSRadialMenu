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

//var points = [CGPoint]()
//func getPoint(newpoints: [CGPoint]) {
//    point = newpoints
//}

struct MenuStyle: ViewModifier {
    @Binding var isShowing: Bool
    let menuPopStyle: MenuPopStyle
    let distance: CGFloat
    let autoClose: Bool
//    let buttons: [MenuButton]
    let buttons: [any View]
    
    @State private var isDragging = false
    
    func body(content: Content) -> some View {
        ZStack {
            content
            fabMenu
        }
    }
    
    private var angleDelta: Double {
        switch menuPopStyle {
        case .linear(let anchor):
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
            print("CGPOINT::",CGPoint(x: distance * cose, y: (distance * sine)))
            return CGPoint(x: distance * cose, y: (distance * sine))
        }
        
    }
    
    @ViewBuilder private var fabMenu: some View {
        let angle = angleDelta
        
        ZStack {
            ForEach(0..<buttons.count, id: \.self) { i in
               // menuButtonStyle(buttons[i],offset: pointFor(angleDelta: angle, index: i))
               menuShape()
                    .rotationEffect(.degrees(180))
                    .frame(width: 30)
                   // .foregroundColor(isShowing ? .black : .clear)
                    .cornerRadius(.infinity)
                   // .position(x: pointFor(angleDelta: angle, index: i).x, y: pointFor(angleDelta: angle, index: i).y)
                    .offset(x: isShowing ? pointFor(angleDelta: angle, index: i).x : 0,
                            y: isShowing ? pointFor(angleDelta: angle, index: i).y :0)
                  //  .opacity(isShowing ? 1 : 0)
                    .animation(.spring().speed(1), value: isShowing)
                    .onChange(of: isShowing, perform: { newValue in
                        isDragging = true
                        withAnimation(.interpolatingSpring(stiffness: 50, damping: 15)) {
                            self.isDragging = false
                        }
                    })
            }
        }
        .frame(height: 30)
      //  .background(.purple)
        .onAppear {
            print("##angleDelta:", angle)
        }
    }
    
    func menuShape() -> some View {
        func path(in rect: CGRect) -> Path {
            return MorphCircle(isDragging: isDragging, isMenu: true).path(in: rect)
        }

        return GeometryReader { proxy in
            let rect = proxy.frame(in: CoordinateSpace.local)
            return AnyView(SimilarShape(path: path(in: rect)))
        }
    }
    
    private func menuButtonStyle(_ button: any View,
                                 offset: CGPoint) -> some View {
        return Image(systemName: button.customImg)
            .frame(width: button.customSize, height: button.customSize)
            .cornerRadius(.infinity)
            .shadow(color: .gray, radius: 2, x: 1, y: 1)
            .onTapGesture {
             //   button.action()
                if autoClose {
                    isShowing.toggle()
                }
            }
//            .offset(x: isShowing ? offset.x : 0,
//                    y: isShowing ? offset.y :0)
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
                    buttons: [any View]) -> some View {
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
