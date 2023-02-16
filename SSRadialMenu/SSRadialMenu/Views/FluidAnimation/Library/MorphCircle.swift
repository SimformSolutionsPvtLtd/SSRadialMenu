//
//  MorphCircle.swift
//  SSRadialMenu
//
//  Created by Bansi Mamtora on 08/02/23.
//
import Foundation
import SwiftUI

struct MorphCircle: Shape {
    let circlePoints: [CGPoint]
    let angleIntervals: [CGFloat]
    var isDragging: Bool, animatableData: CGFloat
    let isMenu: Bool
//    let color: Color
//    let image: String
//    let size: CGFloat
//    let action: () -> Void
    
    init(isDragging: Bool, isMenu: Bool) {
        self.angleIntervals = Array(stride(from: CGFloat(0.0), to: 360.0, by:  24))
        self.circlePoints = angleIntervals
            .map { $0.degreesToRadians }
            .map { (cos($0), sin($0)) }
            .map(CGPoint.init)
     //   self.draggingPoint = draggingPoint
        self.isDragging = isDragging
        self.animatableData = isDragging ? 1 : 0
        self.isMenu = isMenu
      
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.size.height, rect.size.width)/2
        var points = circlePoints
            .map { $0.scaled(by: Double(radius)) }
            .map { $0 + center }
        
        if isMenu {
            let draggingOffset5 = CGPoint(x: -10, y: 80)
            points[5] = lerp(points[5], draggingOffset5, by: self.animatableData)
        } else {
        
            /// for point[11] done
            let draggingOffset11 = CGPoint(x: center.x, y: 2*center.y)
            points[11] = lerp(points[11], draggingOffset11, by: self.animatableData)
        
        /// for point[5] done
//            let draggingOffset5 = CGPoint(x: -10, y: 80)
//            points[5] = lerp(points[5], draggingOffset5, by: self.animatableData)
        
        /// for point[14] done
//            let draggingOffset14 = CGPoint(x: 10, y: 30)
//            points[14] = lerp(points[14], draggingOffset14, by: self.animatableData)
//
//            let draggingOffset8= CGPoint(x: -40, y: 10)
//            points[8] = lerp(points[8], draggingOffset8, by: self.animatableData)
        
        
 //       print("draggingOffset:", draggingOffset)
     //   print("point[12] lerped:", points[12])
        
        //  points[10] = lerp(points[10], draggingOffset, by: self.animatableData)
           // print("point[10]:", points[10])
        }
        return interpolateWithCatmullRom(points)
    }
    
    fileprivate func interpolateWithCatmullRom(_ points: [CGPoint]) -> Path {
        var path = Path()
        for index in points.startIndex..<points.endIndex {
            let nextIndex = (index + 1) % points.count
            let nextNextIndex = (nextIndex + 1) % points.count
            let prevIndex = (index - 1 < 0 ? points.count - 1 : index - 1)
            let point0 = points[prevIndex]
            let point1 = points[index]
            let point2 = points[nextIndex]
            let point3 = points[nextNextIndex]
            
            let distance1 = linearLength(point0: point1, point1: point0)
            let distance2 = linearLength(point0: point2, point1: point1)
            let distance3 = linearLength(point0: point3, point1: point2)

            var controlPoint1: CGPoint
                controlPoint1 = point2 * pow(distance1, 2.0)
                controlPoint1 = controlPoint1 - (point0 * pow(distance2, 2.0))
                controlPoint1 = controlPoint1 + (point1 * (2.0 * pow(distance1, 2.0) + 3.0 * distance1 * distance2 + pow(distance2, 2 )))
                controlPoint1 = controlPoint1 * (CGFloat(1.0) / (3.0 * distance1 * (distance1 + distance2)))
            
            var controlPoint2: CGPoint
                controlPoint2 = point1 * pow(distance3, 2.0)
                controlPoint2 = controlPoint2 - (point3 * pow(distance2, 2.0))
                controlPoint2 = controlPoint2 + (point2 * ((2.0 * pow(distance3, 2.0) + 3.0 * distance3 * distance2 + pow(distance2, 2.0 ))))
                controlPoint2 = controlPoint2 * (1.0 / (3.0 * distance3 * (distance3 + distance2)))
            if index == points.startIndex {
                path.move(to: point1)
            }
//            if index == 11 {
//                print("Point[11]")
//                print("p1:", point1)
//                print("cp1:", controlPoint1)
//                print("cp2:", controlPoint2)
//                print("p2:", point2)
//            }
            if index == 5 {
                print("Point[5]")
                print("p1:", point1)
                print("cp1:", controlPoint1)
                print("cp2:", controlPoint2)
                print("p2:", point2)
            }
            path.addCurve(to: point2, control1: controlPoint1, control2: controlPoint2)
            
          
        }
        path.closeSubpath()
        return path
    }
    
    fileprivate func lerp<T: BinaryFloatingPoint>(_ fromValue: T, _ toValue: T, by amount: T) -> T {
        return fromValue + (toValue - fromValue) * amount
//                50 + (25-50)
//                25 + (25-25)
                    
    }

    fileprivate func lerp(_ fromValue: CGPoint, _ toValue: CGPoint, by amount: CGFloat) -> CGPoint {
//                            (50,25)
        let x = lerp(fromValue.x, toValue.x, by: amount)
//                        50          25
        let y = lerp(fromValue.y, toValue.y, by: amount)
//                        25          25
        return CGPoint(x: x, y: y)
        
    }

}



fileprivate extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}



fileprivate func linearLength(point0: CGPoint, point1: CGPoint) -> CGFloat {
    hypot(point0.x-point1.x, point0.y-point1.y)
}

extension CGPoint {
    func degrees(to point: CGPoint) -> CGFloat {
        let originX = point.x - self.x
        let originY = point.y - self.y
        let degrees = atan2(originY, originX).radiansToDegrees
        return degrees < 0 ? degrees + 360 : degrees
    }

    func scaled(by rhs: Double) -> CGPoint {
        var point = self
        point.animatableData.scale(by: rhs)
        return point
    }

    static func -(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    static func +(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }

}
