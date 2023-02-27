//
//  DynamicLiquidMenu.swift
//  SSRadialMenu
//
//  Created by Bansi Mamtora on 27/02/23.
//

import SwiftUI

struct DynamicLiquidMenu: View {

    // - Body
    var position = CGPoint(x: UIScreen.screenWidth/2, y: UIScreen.screenHeight/2)
    var body: some View {
        ZStack {
            LiquidMenu(fabSize: 90, distance: 150,menuDirection: .circular(.topLeft), position: position, menuButtons: [MenuButton(color: .red, image: "xmark", size: 20, action: {
                print("xmark")
            }), MenuButton(color: .red, image: "plus", size: 20, action: {
                    print("xmark")
            }), MenuButton(color: .red, image: "minus", size: 20, action: {
                print("xmark")
            }), MenuButton(color: .red, image: "minus", size: 20, action: {
                print("xmark")
        })])
            
        }
        .ignoresSafeArea()
    }
}

enum MenuDirection {
    case linear(LinearDirection)
    case circular(CircularDirection)
}

enum CircularDirection {
    case topLeft,
         topRight,
         bottomLeft,
         bottomRight,
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
        case .custom(let startAngle, _):
            return startAngle.degrees
        }
    }
    
    var endAngle: Double {
        switch self {
        case .custom(_, let endAngle):
            return endAngle.degrees
        default:
            return startAngle + .pi.degrees / 2
        }
    }
}

enum LinearDirection {
    case popUp,
         popDown,
         popLeft,
         popRight
    
    var anchorPosition: Double {
        return 3 * .pi.degrees / 2
    }
}

struct LiquidMenu: View {
    @State private var isCollapsed: Bool = false
    
    @State var offsets = [CGSize.zero, .zero, .zero, .zero, .zero]
    var fabSize: CGFloat
    var distance: CGFloat
    var menuDirection: MenuDirection
    var position: CGPoint
    var menuButtons: [MenuButton]
    
    var body: some View {
        ZStack {
                Rectangle()
                    .fill(.red.opacity(0.3))
                    .mask {
                        Canvas { context, size in
                            //Adding Filters
                            context.addFilter(.alphaThreshold(min: 0.9, color: .black))
                            context.addFilter(.blur(radius: 8))

                            //Drawing Layers
                            context.drawLayer { ctx in
                                //Placing symbols
                                for button in 0..<menuButtons.count + 1 {
                                    if let resolvedView = context.resolveSymbol(id: button) {
                                        ctx.draw(resolvedView, at: position)
                                    }
                                }

                            }
                        } symbols: {
                            Symbol(diameter: fabSize)
                                .tag(0)

                            ForEach(0..<offsets.count) { index in
                                Symbol(offset: offsets[index],diameter: fabSize - 30)
                                    .tag(index + 1)
                            }
                        }
                     //  .frame(height: 70)
                    }
            CancelButton()
                .offset(x: 0,y: 0)
                .position(position)
//                .position(x: UIScreen.screenWidth/2, y: UIScreen.screenHeight/2)
//                .offset(x: -10,y: 10)
                
            ForEach(0..<menuButtons.count) { index in
                Image(systemName: menuButtons[index].image)
                    .position(position)
                    .offset(offsets[index])
                    .opacity(isCollapsed ? 1 : 0)
            }
        }
        
        .background(.blue.opacity(0.3))
    }
    
    private func Symbol(offset: CGSize = .zero, diameter: CGFloat) -> some View {
        Circle()
            .frame(width: diameter, height: diameter)
            .offset(offset)
    }
    
    func CancelButton() -> some View {
        ZStack {
            Image(systemName: "plus")
                .foregroundColor(.black)
        }
        .onTapGesture {
            withAnimation { isCollapsed.toggle() }
            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 1, blendDuration: 0.1).speed(0.9)) {
                for i in 0..<menuButtons.count {
                    offsets[i] = isCollapsed ? getOffset(index: i) : .zero
                    print("offset\(i)", offsets[i])
                }
            }
        }
    }
    
//    func getOffset(index: Int) -> CGSize {
//        return CGSize(width: 0, height: -90 * (index + 1))
//    }
    private var angleDelta: Double {
        switch menuDirection {
        case .linear(let anchor):
            
            return anchor.anchorPosition
        case .circular(let anchor):
            let span = anchor.endAngle - anchor.startAngle
            let nMinus1 = menuButtons.count - 1
            let candidate = (span / Double(nMinus1))
            return candidate
        }
    }
    
    func getOffset(index: Int) -> CGSize {
        switch menuDirection {
        case .linear(let linearStyle):
            switch linearStyle {
            case .popUp:
                return CGSize(width: 0, height: -90 * (index + 1))
            case .popDown:
                return CGSize(width: 0, height: 90 * (index + 1))
            case .popLeft:
                return CGSize(width:  -90 * (index + 1), height: 0)
            case .popRight:
                return CGSize(width:  90 * (index + 1), height: 0)
            }
        case .circular(let circularStyle):
            let angle = circularStyle.startAngle + angleDelta * Double(index)
            print("angle:::", angle)
            let sine = sin(angle.radians)
            let cose = cos(angle.radians)
            return CGSize(width: ( distance * cose), height: ( distance * sine))
        }
    }
}

extension UIScreen{
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}

struct DynamicLiquidMenu_Previews: PreviewProvider {
    static var previews: some View {
        DynamicLiquidMenu()
    }
}
