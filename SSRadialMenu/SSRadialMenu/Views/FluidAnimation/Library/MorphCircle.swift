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
        self.angleIntervals = Array(stride(from: CGFloat(0.0), to: 360.0, by: isMenu ? 36 : 15))
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
            let draggingOffset = CGPoint(x: -center.x, y: -center.y)
            points[6] = lerp(points[6], draggingOffset, by: self.animatableData )
        } else {
            let draggingOffset = center
        //    points[18] = lerp(points[18], draggingOffset, by: self.animatableData)
            points[14] = lerp(points[14], draggingOffset, by: self.animatableData)
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
            path.addCurve(to: point2, control1: controlPoint1, control2: controlPoint2)
            
          
        }
        path.closeSubpath()
        return path
    }
    
    fileprivate func lerp<T: BinaryFloatingPoint>(_ fromValue: T, _ toValue: T, by amount: T) -> T {
        return fromValue + (toValue - fromValue) * amount
    }

    fileprivate func lerp(_ fromValue: CGPoint, _ toValue: CGPoint, by amount: CGFloat) -> CGPoint {
        let x = lerp(fromValue.x, toValue.x, by: amount)
        let y = lerp(fromValue.y, toValue.y, by: amount)
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
