//
//  MindMapModel.swift
//  3DMindMap
//
//  Created by TAIGA ITO on 2025/03/22.
//

import SwiftUI

class NodeType {
    var id: String
    var topic: String
    var parentId: String
    var position: Point3D
    var bgColor: Color
    var frameColor: Color?
    var childrenCount: Int = 0
    
    init(id: String,topic: String, parentId: String, position: Point3D, bgColor: Color?, frameColor: Color?) {
        self.id = id
        self.topic = topic
        self.parentId = parentId
        self.bgColor = bgColor ?? Color.white
        self.frameColor = frameColor
        self.childrenCount = 0
        self.position = position
    }
}
