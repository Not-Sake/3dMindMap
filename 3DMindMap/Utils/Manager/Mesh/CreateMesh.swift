import SwiftUI
import RealityKit

class CreateMesh {
    public func createNode(id: String, position: Point3D, bgColor: String?, borderColor: String?) -> ModelEntity {
        // 🎨 パステルカラーの内側のPlane
        let boxMesh = MeshResource.generatePlane(width: 1, height: 0.3, cornerRadius: .infinity)
        let pastelColor = UIColor(Color(bgColor ?? CustomColor.defaultColor)).withAlphaComponent(0.9)
        let material = UnlitMaterial(color: pastelColor)
        let innerEntity = ModelEntity(mesh: boxMesh, materials: [material])
        let borderWidth = 0.04
           
        // 🎨 外側の枠線 (Planeを少し大きく)
        let borderMesh = MeshResource.generatePlane(width: 1 + Float(borderWidth), height: Float(0.3 + borderWidth), cornerRadius: .infinity)
        let borderUIColor = UIColor(Color(borderColor ?? bgColor ?? CustomColor.defaultColor))
        let borderMaterial = UnlitMaterial(color: borderUIColor)
        let borderEntity = ModelEntity(mesh: borderMesh, materials: [borderMaterial])
        borderEntity.name = "border_\(id)"
       
        // ✅ ノードグループの親Entity
        let nodeEntity = ModelEntity()
        nodeEntity.addChild(borderEntity)
        nodeEntity.addChild(innerEntity)
       
        // 📏 位置・サイズの調整
        borderEntity.position.z = -0.001  // 枠線を少し奥に配置
        innerEntity.position.z = 0.0
       
        // 🪝 位置と名前の設定
        nodeEntity.transform.translation = SIMD3(position)
        nodeEntity.name = id
        nodeEntity.components.set(BillboardComponent())
        // ドラッグ可能にするための必須コンポーネントを追加
        // 1. 衝突判定 (CollisionShapeComponent)
        let collisionShape = ShapeResource.generateBox(size: [0.3, 0.2, 0.1])
        nodeEntity.components.set(CollisionComponent(shapes: [collisionShape], isStatic: false, filter: .default))
        
        // 2. 物理特性の設定 (PhysicsBodyComponent)
//        let physicsMaterial = PhysicsMaterialResource.generate(friction: 0.8, restitution: 0.0)
//        nodeEntity.components.set(PhysicsBodyComponent(shapes: nodeEntity.collision!.shapes, mass: 0.0, material: physicsMaterial, mode: .dynamic))
        // 3. ユーザーインタラクションのターゲット設定 (InputTargetComponent)
        nodeEntity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        nodeEntity.components.set(OpacityComponent(opacity: 0))
       
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
        
        let textMaterial = UnlitMaterial(color: .black)
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        let bounding = textEntity.visualBounds(relativeTo: nil)

        // **テキストを中央に配置**
        textEntity.position.x = -bounding.center.x
        textEntity.position.y = -bounding.center.y
        textEntity.position.z = 0.01
        
        // 文字の向きを修正
        textEntity.orientation = simd_quatf(angle: 0, axis: [0, 1, 0])
        
        
        //  textEntity.transform.translation = SIMD3(position)
        
        return textEntity
    }
}
