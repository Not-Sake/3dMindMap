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
    var children: [NodeType] = []
    
    init(id: String,topic: String, parentId: String, position: Point3D) {
        self.id = id
        self.topic = topic
        self.parentId = parentId
        self.children = []
        self.position = position
    }
}
