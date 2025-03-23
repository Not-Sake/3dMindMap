//
//  CaluculateManager.swift
//  3DMindMap
//
//  Created by TAIGA ITO on 2025/03/22.
//

import SwiftUI

class CalculatorManager {
    //MARK: - 新しいNodeの位置を計算
    //Node間の最接近距離(m)
    let minDistance: Double = 0.22
    //同距離間でのランダム試行回数
    let maxTryCount: Int = 50
    //ある一定の距離で最適な位置が見つからなかった場合に広げる距離(m)
    let expandDistance: Double = 0.06
    //ユーザーからの最短距離(m)
    let userDistance: Double = 2.0
    
    public func newPosition(parentId: String, nodes: [NodeType]) -> Point3D {
        guard let parent = nodes.first(where: { $0.id == parentId }) else {
            print("Cannot find parent")
            return Point3D.zero
        }
        let parentPosition = parent.position
        var newPosition: Point3D = .zero
        var continueCalculate: Bool = true
        var distance = minDistance
        while continueCalculate {
            if let randomPosition = randomPosition(parentPosition: parentPosition, nodes: nodes, distance: 1) {
                newPosition = randomPosition
                continueCalculate = false
                break
            }
            distance += expandDistance
        }
        return newPosition
    }
    
    private func randomPosition(parentPosition: Point3D, nodes: [NodeType], distance: CGFloat) -> Point3D? {
        for _ in 0..<maxTryCount {
            let randomInclination = Angle2D(radians: Double.random(in: 0..<Double.pi * 2))
            let randomAzimuth = Angle2D(radians: Double.random(in: 0..<Double.pi * 2))
            let randomPosition: Point3D = .init(SphericalCoordinates3D(radius: distance, inclination: randomInclination, azimuth: randomAzimuth))
            var success = true
            for node in nodes {
                if checkDistance(from: randomPosition, to: node.position) < minDistance || tooNear(position: randomPosition) {
                    success = false
                    break
                }
            }
            if success {
                return randomPosition
            }
        }
        return nil
    }
    
    private func checkDistance(from p1: Point3D, to p2: Point3D) -> Double {
        return p1.distance(to: p2)
    }
    
    //ユーザーの指定された四方、またユーザーの後ろに配置されないようにする
    private func tooNear(position: Point3D) -> Bool  {
        if position.z > -(userDistance) {
            return true
        }
        if position.x > -(userDistance) && position.x < userDistance {
            return true
        }
        return false
    }
    
    //MARK: - Nodeの向きを計算
    
    public func calculateNodeDirection(position: Point3D) -> CGFloat {
        let radiant: CGFloat = atan2(position.z, position.x)
        let rotate = radiant - CGFloat.pi / 2
        return rotate
    }
}
