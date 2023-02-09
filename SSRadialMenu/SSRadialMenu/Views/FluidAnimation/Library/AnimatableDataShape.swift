//
//  AnimatableDataShape.swift
//  SSRadialMenu
//
//  Created by Bansi Mamtora on 08/02/23.
//

import SwiftUI

    // MARK: - AnimatableDataShape
public struct AnimatableDataShape: VectorArithmetic {
    
    var elements: [Path.Element]

    init(path: Path) {
        self.elements = path.elements
    }

    private init() {
        self.elements = []
    }

    public static func -= (lhs: inout Self, rhs: Self) {
        lhs.elements -= rhs.elements
    }

    public static func += (lhs: inout Self, rhs: Self) {
        lhs.elements += rhs.elements
    }

    mutating public func scale(by rhs: Double) {
        elements.scale(by: rhs)
    }

    public var magnitudeSquared: Double {
        elements.magnitudeSquared
    }

    public static var zero: Self { .init() }

    func makePath() -> Path {
        Path(elements: elements)
    }
}

//MARK: - extension Path.Element
extension Path.Element: VectorArithmetic {
    
    public static func -= (lhs: inout Self, rhs: Self) {
        switch (lhs, rhs) {
        case let (.move(to: lhsPoint), .move(to: rhsPoint)):
            lhs = .move(to: lhsPoint - rhsPoint)
        case let (.line(to: lhsPoint), .line(to: rhsPoint)):
            lhs = .line(to: lhsPoint - rhsPoint)
        case let (.quadCurve(to: lhsPoint, control: lhsControl), .quadCurve(to: rhsPoint, control: rhsControl)):
            lhs = .quadCurve(to: lhsPoint - rhsPoint, control: lhsControl - rhsControl)
        case let (.curve(to: lhsPoint, control1: lhsControl1, control2: lhsControl2),
                  .curve(to: rhsPoint, control1: rhsControl1, control2: rhsControl2)):
            lhs = .curve(to: lhsPoint - rhsPoint, control1: lhsControl1 - rhsControl1, control2: lhsControl2 - rhsControl2)
        case (.closeSubpath, .closeSubpath):
            lhs = .closeSubpath
        default:
            fatalError("VectorAirthmetic is not support for path having different types of elements.")
        }
    }

    public static func += (lhs: inout Self, rhs: Self) {
        switch (lhs, rhs) {
        case let (.move(to: lhsPoint), .move(to: rhsPoint)):
            lhs = .move(to: lhsPoint + rhsPoint)
        case let (.line(to: lhsPoint), .line(to: rhsPoint)):
            lhs = .line(to: lhsPoint + rhsPoint)
        case let (.quadCurve(to: lhsPoint, control: lhsControl), .quadCurve(to: rhsPoint, control: rhsControl)):
            lhs = .quadCurve(to: lhsPoint + rhsPoint, control: lhsControl + rhsControl)
        case let (.curve(to: lhsPoint, control1: lhsControl1, control2: lhsControl2),
                  .curve(to: rhsPoint, control1: rhsControl1, control2: rhsControl2)):
            lhs = .curve(to: lhsPoint + rhsPoint, control1: lhsControl1 + rhsControl1, control2: lhsControl2 + rhsControl2)
        case (.closeSubpath, .closeSubpath):
            lhs = .closeSubpath
        default:
            fatalError("VectorAirthmetic is not support for path having different types of elements.")
        }
    }

    mutating public func scale(by rhs: Double) {
        switch self {
        case let .move(to: lhsPoint):
            self = .move(to: lhsPoint.scaled(by: rhs))
        case let .line(to: lhsPoint):
            self = .line(to: lhsPoint.scaled(by: rhs))
        case let .quadCurve(to: lhsPoint, control: lhsControl):
            self = .quadCurve(to: lhsPoint.scaled(by: rhs), control: lhsControl.scaled(by: rhs))
        case let .curve(to: lhsPoint, control1: lhsControl1, control2: lhsControl2):
            self = .curve(to: lhsPoint.scaled(by: rhs), control1: lhsControl1.scaled(by: rhs), control2: lhsControl2.scaled(by: rhs))
        case .closeSubpath:
            self = .closeSubpath
        }
    }

    public var magnitudeSquared: Double {
        switch self {
        case let .move(to: lhsPoint):
            return lhsPoint.animatableData.magnitudeSquared
        case let .line(to: lhsPoint):
            return lhsPoint.animatableData.magnitudeSquared
        case let .quadCurve(to: lhsPoint, control: lhsControl):
            return [lhsPoint.animatableData, lhsControl.animatableData].magnitudeSquared
        case let .curve(to: lhsPoint, control1: lhsControl1, control2: lhsControl2):
            return [lhsPoint.animatableData, lhsControl1.animatableData, lhsControl2.animatableData].magnitudeSquared
        case .closeSubpath:
            return 0
        }
    }

    public static var zero: Self { .move(to: .zero) }

}

//MARK: - extension Array
extension Array: AdditiveArithmetic & VectorArithmetic where Element: VectorArithmetic  {
    
    public static func -= (lhs: inout Self, rhs: Self) {
        let range = (lhs.startIndex..<lhs.endIndex)
            .clamped(to: rhs.startIndex..<rhs.endIndex)

        for index in range {
            lhs[index] -= rhs[index]
        }
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        var lhs = lhs
        lhs -= rhs
        return lhs
    }

    public static func += (lhs: inout Self, rhs: Self) {
        let range = (lhs.startIndex..<lhs.endIndex)
            .clamped(to: rhs.startIndex..<rhs.endIndex)
        for index in range {
            lhs[index] += rhs[index]
        }
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        var lhs = lhs
        lhs += rhs
        return lhs
    }

    mutating public func scale(by rhs: Double) {
        for index in startIndex..<endIndex {
            self[index].scale(by: rhs)
        }
    }

    public var magnitudeSquared: Double {
        reduce(into: 0.0) { (result, new) in
            result += new.magnitudeSquared
        }
    }

    public static var zero: Self { .init() }
}

extension Path {
    var elements: [Path.Element] {
        var elements: [Path.Element] = []
        forEach { elements.append($0) }
        return elements
    }

    init(elements: [Path.Element]) {
        self.init()
        for element in elements {
            switch element {
            case let .move(to: point):
                self.move(to: point)
            case let .line(to: point):
                self.addLine(to: point)
            case let .quadCurve(to: point, control: control):
                self.addQuadCurve(to: point, control: control)
            case let .curve(to: point, control1: control1, control2: control2):
                self.addCurve(to: point, control1: control1, control2: control2)
            case .closeSubpath:
                self.closeSubpath()
            }
        }
    }
}

//MARK: - extension VectorArithmetic 
extension VectorArithmetic {

    public static func - (lhs: Self, rhs: Self) -> Self {
//        var lhs = lhs
//       lhs -= rhs
        return lhs
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
//        var lhs = lhs
//        lhs += rhs
        return lhs
    }
}


