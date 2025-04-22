//
//  MindMapModel.swift
//  3DMindMap
//
//  Created by TAIGA ITO on 2025/03/22.
//

import SwiftData
import SwiftUI

@MainActor
class ModelContainerProvider {
    static let shared: ModelContainer = {
        do {
            let schema = Schema([NodeType.self])
            let config = ModelConfiguration("default", schema: schema)
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
}

@Model
class NodeType {
    var id: String
    var topic: String
    var parentId: String
    var x: Double
    var y: Double
    var z: Double
    var bgColor: String
    var frameColor: String?
    var childrenCount: Int = 0
    
    init(id: String,topic: String, parentId: String, position: Point3D, bgColor: String?, frameColor: String?) {
        self.id = id
        self.topic = topic
        self.parentId = parentId
        self.bgColor = bgColor ?? CustomColor.defaultColor
        self.frameColor = bgColor ?? CustomColor.defaultColor
        self.childrenCount = 0
        self.x = position.x
        self.y = position.y
        self.z = position.z
    }
    
    var position: Point3D {
        get {
            return Point3D(x: x, y: y, z: z)
        }
        set {
            x = newValue.x
            y = newValue.y
            z = newValue.z
        }
    }
}
