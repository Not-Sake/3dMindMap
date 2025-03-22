//
//  ImmersiveViewModel.swift
//  3DMindMap
//
//  Created by saki on 2025/03/22.
//

import SwiftUI
import RealityKit

@Observable
final class ImmersiveViewModel {
    
    public static let shared = ImmersiveViewModel()
        
    var nodes: [NodeType] = []
    var cubes: [Entity] = []
    var inputText: String = ""
    var selectedNodeId: String = ""
    private var contentEntity = Entity()
    
    func setupContentEntity() -> Entity {
        return contentEntity
    }
    
    func addNode(inputText: String, parentId: String, position: Point3D, id: String) {
        nodes.append(NodeType(id: id, topic: inputText, parentId: parentId, position: position))
    }
    
    func addEntity(id: String, posision: Point3D) -> Entity {
        let entity = CreateMesh().createNode(id: id, position: posision)

        entity.name = id
        entity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        entity.components.set(HoverEffectComponent(.highlight(.default)))
        
        contentEntity.addChild(entity)
        
        return entity
    }
    
    func addCube() {
        print("called addCube")
        let id = UUID().uuidString
        print("selectedNodeId: \(selectedNodeId)")
        let position = CalculatorManager().newPosition(parentId: selectedNodeId, nodes: nodes)
        print("new position: \(position)")
        let newCube = addEntity(
            id: id,
            posision: position
        )
        cubes.append(newCube)
        addNode(inputText: inputText, parentId: selectedNodeId, position: position, id: id)
        inputText = ""
        dump(nodes)
    }
    
    func addInitialCube() {
        let x: Float = 0
        let y: Float = 1.2
        let z: Float = 1.2
        let id = UUID().uuidString
        
        let newCube = addEntity(
            id: id,
            posision: Point3D(x: x, y: y, z: z)
        )
        cubes.append(newCube)
        addNode(inputText: inputText, parentId: "", position: Point3D(x: x, y: y, z: z), id: id)
        inputText = ""
    }
    
    func updateNodePosition(entity: Entity, newPosition: SIMD3<Float>) {
        if let index = nodes.firstIndex(where: { "\($0.id)" == entity.name }) {
            nodes[index].position = Point3D(x: newPosition.x, y: newPosition.y, z: newPosition.z)
        }
    }
}
