//
//  MindMapModel.swift
//  3DMindMap
//
//  Created by TAIGA ITO on 2025/03/22.
//

import SwiftData
import SwiftUI

@Model
class NodeType {
    var id: String
    var topic: String
    var parentId: String
    var position: Point3D
    var bgColor: ColorData
    var frameColor: ColorData?
    var childrenCount: Int = 0
    
    init(id: String,topic: String, parentId: String, position: Point3D, bgColor: ColorData?, frameColor: ColorData?) {
        self.id = id
        self.topic = topic
        self.parentId = parentId
        self.bgColor = bgColor ?? ColorData(color: .white)
        self.frameColor = bgColor ?? ColorData(color: .white)
        self.childrenCount = 0
        self.position = position
    }
}

struct ColorData: Codable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double
    
    init(color: Color) {
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.red = Double(red)
        self.green = Double(green)
        self.blue = Double(blue)
        self.opacity = Double(alpha)
    }
    
    func toColor() -> Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}
