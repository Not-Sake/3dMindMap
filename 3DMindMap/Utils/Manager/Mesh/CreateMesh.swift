import SwiftUI
import RealityKit

class CreateMesh {
    public func createNode(position: Point3D) -> ModelEntity {
        let boxMesh = MeshResource.generatePlane(width: 1, height: 0.3, cornerRadius: .infinity)

        var material = SimpleMaterial(color: .white.withAlphaComponent(0.7), isMetallic: false)
        
        material.roughness = 0.05
        material.metallic = 0.15

        let nodeEntity = ModelEntity(mesh: boxMesh, materials: [material])
        
        nodeEntity.components.set(ModelComponent(
            mesh: boxMesh,
            materials: [material]
        ))

        nodeEntity.transform.translation = SIMD3(position)
        
        return nodeEntity
    }
}
