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
    
    private var contentEntity = Entity()
    
    func setupContentEntity() -> Entity {
        return contentEntity
    }
    
    func addNode(inputText: String, parentId: String, position: Point3D) {
        nodes.append(NodeType(topic: inputText, parentId: parentId, position: position))
    }
    
    func addCube(name: String = "Cube", posision: Point3D) -> Entity {
        let entity = ModelEntity(
            mesh: .generateBox(size: 0.5, cornerRadius: 0),
            materials: [SimpleMaterial(color: .red, isMetallic: false)],
            collisionShape: .generateBox(size: SIMD3<Float>(repeating: 0.5)),
            mass: 0.0
        )
        
        entity.name = name
        entity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        
        let material = PhysicsMaterialResource.generate(friction: 0.8, restitution: 0.0)
        entity.components.set(PhysicsBodyComponent(shapes: entity.collision!.shapes,
                                                   mass: 0.0,
                                                   material: material,
                                                   mode: .dynamic))
        
        entity.position = SIMD3(posision)
        contentEntity.addChild(entity)
        
        return entity
    }
    
    func addCube(text: String, parentId: String) {
        let x = Float.random(in: -5 ... 5)
        let y = Float.random(in: -5 ... 5)
        let z = Float.random(in: -5 ... 5)
        
        let newCube = addCube(
            name: "Cube_\(nodes.count)",
            posision: Point3D(x: x, y: y, z: z)
        )
        
        cubes.append(newCube)
        addNode(inputText: "Cube_\(nodes.count)", parentId: parentId, position: Point3D(x: x, y: y, z: z))
        
        
    }
    
    
    func updateNodePosition(entity: Entity, newPosition: SIMD3<Float>) {
        
        if let index = nodes.firstIndex(where: { "\($0.topic)" == entity.name }) {
            nodes[index].position = Point3D(x: newPosition.x, y: newPosition.y, z: newPosition.z)
            
        }
        
    }
    
    
}
