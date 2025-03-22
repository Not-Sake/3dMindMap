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
    var position: Point3D = .zero
    var children: [NodeType] = []
    
    init(topic: String, parentId: String) {
        self.id = UUID().uuidString
        self.topic = topic
        self.parentId = parentId
        self.children = []
    }
}
