import SwiftUI
import RealityKit

class CreateMesh {
    public func createNode(id: String, position: Point3D) -> ModelEntity {
        let boxMesh = MeshResource.generatePlane(width: 1, height: 0.3, cornerRadius: .infinity)

        var material = SimpleMaterial(color: .white.withAlphaComponent(0.9), isMetallic: false)
        
        material.roughness = 0.05
        material.metallic = 0

        let nodeEntity = ModelEntity(mesh: boxMesh, materials: [material])
        
        nodeEntity.components.set(ModelComponent(
            mesh: boxMesh,
            materials: [material]
        ))

        nodeEntity.transform.translation = SIMD3(position)
        nodeEntity.name = id
        
        // ドラッグ可能にするための必須コンポーネントを追加
        // 1. 衝突判定 (CollisionShapeComponent)
        let collisionShape = ShapeResource.generateBox(size: [0.3, 0.2, 0.1])
        nodeEntity.components.set(CollisionComponent(shapes: [collisionShape],
                                                      isStatic: false,
                                                      filter: .default))
        
        // 2. 物理特性の設定 (PhysicsBodyComponent)
        let physicsMaterial = PhysicsMaterialResource.generate(friction: 0.8, restitution: 0.0)
        nodeEntity.components.set(PhysicsBodyComponent(shapes: nodeEntity.collision!.shapes,
                                                        mass: 0.0,
                                                        material: physicsMaterial,
                                                        mode: .dynamic))

        // 3. ユーザーインタラクションのターゲット設定 (InputTargetComponent)
        nodeEntity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        
        return nodeEntity
    }
}
