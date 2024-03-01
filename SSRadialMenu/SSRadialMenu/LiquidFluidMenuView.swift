//
//  LiquidFluidMenuView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 26/02/24.
//

import SwiftUI

struct LiquidFluidMenuView: View {
    let centerWidth = UIScreen.main.bounds.width / 2
    let centerHight = UIScreen.main.bounds.height / 2
    
    
    @State var positions: [CGPoint] = [
        CGPoint(x: -0, y: -20),
        CGPoint(x: -0, y: -20),
        CGPoint(x: -0, y: -20),
        CGPoint(x: -0, y: -20)
    ]
    @State var frameSize: CGSize = .zero

    var blurRadius = 10.0
    var alphaThreshHold = 0.2
    var ballCount = 3
    
    let timer = Timer.publish(every: 2, on: .main, in: .common)
        .autoconnect().receive(on: RunLoop.main)
    
    var body: some View {
            VStack {
                Circle().fill(Color.blue)
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 100)
                    .aspectRatio(0.75, contentMode: .fit)
                    .clipped()
                    .mask {
                        Canvas { context, size in
                            let circles = (0..<ballCount)
                                .map { tag in
                                    context.resolveSymbol(id: tag)
                                }
                            context.addFilter(.alphaThreshold(min: alphaThreshHold))
                            context.addFilter(.blur(radius: blurRadius))
                            context.drawLayer { context2 in
                                circles.forEach { circle in
                                    if let circle {
                                        context2.draw(circle, at: .init(x: size.width / 2, y: size.height / 2))
                                    }
                                }
                            }
                        } symbols: {
                            ForEach(positions.indices, id: \.self) { id in
                                Circle()
                                    .frame(
                                        width: id == 0 ? 100 - blurRadius/alphaThreshHold : 25
                                    )
                                    .tag(id)
                                    .offset(
                                        x: id == 0 ? 0 : positions[id].x,
                                        y: id == 0 ? 0 : positions[id].y
                                    ).onAppear {
                                        print(id)
                                    }
                            }
                        }
                    }
            }
            .onReceive(timer, perform: { _ in
                withAnimation(.easeInOut(duration: 4)) {
                    positions = positions.map({ _ in
                        randomPositions(bounds: frameSize, ballSize: .init(width: 100/2, height: 100/2))
                    })
                    print(positions)
                }
            })
            .onAppear {
                frameSize = .init(width: 100, height: 100 / 0.75)
            }
    }
    
    func randomPositions(bounds: CGSize, ballSize: CGSize) -> CGPoint {
        let xRange = ballSize.width / 1.5 ... bounds.width - bounds.width/1.8
        let yRange = ballSize.height / 0.8 ... bounds.height - bounds.height/8
        
        print("\(ballSize.height / 0.8)...\(bounds.height - bounds.height/4)")
        let randomX = CGFloat.random(in: xRange)
        let randomY = CGFloat.random(in: yRange)
        
        print(randomX)
        print("\(randomY) \n")
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let offsetX = randomX - center.x
        let offsetY = randomY - center.y
//        print("offsetX : \(offsetX), offsetY : \(offsetY)")
        
        return CGPoint(x: offsetX, y: offsetY)
    }
}

#Preview {
    LiquidFluidMenuView()
}
