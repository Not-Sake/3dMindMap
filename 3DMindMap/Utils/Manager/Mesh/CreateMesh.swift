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
    public func createTextEntity(text: String, position: Point3D) -> ModelEntity {
        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.1),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        
        let textMaterial = SimpleMaterial(color: .black, isMetallic: false)
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        let bounding = textEntity.visualBounds(relativeTo: nil)

           // **テキストを中央に配置**
           textEntity.position.x = -bounding.center.x
           textEntity.position.y = -bounding.center.y
        textEntity.position.z = 0.02
        
        // 文字の向きを修正
        textEntity.orientation = simd_quatf(angle: 0, axis: [0, 1, 0])
        
        //  textEntity.transform.translation = SIMD3(position)
        
        
        return textEntity
    }
}
