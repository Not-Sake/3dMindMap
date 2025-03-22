//
//  ImmersiveViewModel.swift
//  3DMindMap
//
//  Created by saki on 2025/03/22.
//

import SwiftUI
import RealityKit

@Observable
class ImmersiveViewModel {
    
    var nodes: [NodeType] = []
    var cubes: [Entity] = []
    var inputText: String = ""
    
    
    
    private var contentEntity = Entity()
    
    func setupContentEntity() -> Entity {
        return contentEntity
    }
    
    func addNode(inputText: String, parentId: String, position: Point3D, id: String) {
        nodes.append(NodeType(id: id, topic: inputText, parentId: parentId, position: position))
    }
    
    func addEntity(id: String, posision: Point3D, text: String) -> Entity {
        let entity = CreateMesh().createNode(id: id, position: posision)

        entity.name = id
        entity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        entity.components.set(HoverEffectComponent(.highlight(.default)))
        
        // テキストの作成
        let textEntity = CreateMesh().createTextEntity(text: text, position:posision)
        
        entity.addChild(textEntity) // キューブの子要素としてテキストを追加
        
        contentEntity.addChild(entity)
        
        return entity
    }

    func addCube(text: String, parentId: String) {
        let x = Float.random(in: -5 ... 5)
        let y = Float.random(in: -5 ... 5)
        let z = Float.random(in: -5 ... 5)
        let id = UUID().uuidString
        
        let newCube = addEntity(
            id: id,
            posision: Point3D(x: x, y: y, z: z), text: "わん"
        )
        
        cubes.append(newCube)
        addNode(inputText: "打たれたテキストはここ", parentId: parentId, position: Point3D(x: x, y: y, z: z), id: id)
        
        dump(nodes)
    }
    
    func addInitialCube(text: String) {
        let x: Float = 0
        let y: Float = 1.5
        let z: Float = -4
        let id = UUID().uuidString
        
        let newCube = addEntity(
            id: id,
            posision: Point3D(x: x, y: y, z: z), text: "aaaaaaaaa"
        )
        
        cubes.append(newCube)
        addNode(inputText: "打たれたテキストはここ", parentId: "", position: Point3D(x: x, y: y, z: z), id: id)
    }
    
    
    func updateNodePosition(entity: Entity, newPosition: SIMD3<Float>) {
        print(nodes.first!.id, entity.name)
        if let index = nodes.firstIndex(where: { "\($0.id)" == entity.name }) {
            nodes[index].position = Point3D(x: newPosition.x, y: newPosition.y, z: newPosition.z)
            
        }
        print(nodes.first!.position)
        
    }
    
    
}
