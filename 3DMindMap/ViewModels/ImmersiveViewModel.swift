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
    
    private var contentEntity = Entity()
    
    func setupContentEntity() -> Entity {
        return contentEntity
    }
    func getTargetEntity(name: String) -> Entity? {
        return contentEntity.children.first { $0.name == name}
    }
    
    func addCube(name: String) -> Entity {
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
        
        entity.position = SIMD3(x: 0, y: 1, z: -2)
        
        contentEntity.addChild(entity)
        
        return entity
    }
}

