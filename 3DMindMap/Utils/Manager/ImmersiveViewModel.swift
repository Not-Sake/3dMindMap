//
//  ImmersiveViewModel.swift
//  3DMindMap
//
//  Created by saki on 2025/03/22.
//

import SwiftUI
import RealityKit
import SwiftData

@Observable
final class ImmersiveViewModel {
    
    public static let shared = ImmersiveViewModel()
    var nodes: [NodeType] = []
    var cubes: [Entity] = []
    var inputText: String = ""
    var selectedNodeId: String = ""
    var isTextField = false
    private var contentEntity = Entity()
    var saggestionText: [String] = []
    
    func setupContentEntity() -> Entity {
        return contentEntity
    }
    func animateOpacity(nodeEntity: Entity) {
        var value: Float = 0.0
        let duration: TimeInterval = 0.5
        let steps: Int = 60  // 60フレーム（1秒間）
        let interval = duration / Double(steps)

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            value += 1.0 / Float(steps)
            nodeEntity.components.set(OpacityComponent(opacity: value))

            if value >= 1.0 {
                timer.invalidate()  // アニメーション完了後にタイマーを停止
            }
        }
    }
    func findNode(id: String) -> NodeType? {
        if let index = nodes.firstIndex(where: { "\($0.id)" == id }) {
            return nodes[index]
        }
        return nil
    }
    
    func findChild(parentId: String) -> NodeType? {
        if let index = nodes.firstIndex(where: { "\($0.parentId)" == parentId }) {
            return nodes[index]
        }
        return nil
    }
    
    func createInitialNodeData(topic: String) -> NodeType {
        let x: Float = 0
        let y: Float = 1.2
        let z: Float = -3.25
        let id = UUID().uuidString
        let node = NodeType(id: id, topic: topic, parentId: "", position: Point3D(x: x, y: y, z: z), bgColor: CustomColor.defaultColor, frameColor: nil)
        nodes.append(node)
        return node
    }
    
    @MainActor
    func addNodeData(inputText: String, parentId: String) -> NodeType? {
        let id = UUID().uuidString
        let position = CalculatorManager().newPosition(parentId: selectedNodeId, nodes: nodes)
        let parentNode = findNode(id: parentId)
        guard let parentNode else {
            return nil
        }
        let childColor = findChild(parentId: parentId)?.bgColor ?? RandomColor().getRandomColor(parentNode.bgColor)
        let newNode = NodeType(id: id, topic: inputText, parentId: parentId, position: position, bgColor: childColor, frameColor: nil)
        nodes.append(newNode)
        
        if parentNode.childrenCount == 0 {
            if let index = cubes.firstIndex(where: { "\($0.name)" == "\(parentId)" }) {
                let entity = cubes[index]
                if let parentBorder = entity.children.first(where: { "\($0.name)" == "border_\(parentId)" }) {
                    let borderUIColor = UIColor(Color(childColor))
                    let borderMaterial = UnlitMaterial(color: borderUIColor)
                    parentBorder.components[ModelComponent.self]?.materials = [borderMaterial]
                    parentNode.frameColor = childColor
                    do {
                        let context = ModelContext(ModelContainerProvider.shared)
                        let descriptor = FetchDescriptor<NodeType>()
                        if let node = try context.fetch(descriptor).first(where: { $0.id == parentId }) {
                            node.frameColor = childColor
                            try context.save()
                        }
                    } catch {
                        print("Error fetching nodes: \(error)")
                    }
                }
            }
        }
        parentNode.childrenCount += 1
        return newNode
    }
    
    func createNodeEntity(id: String, posision: Point3D, text: String, bgColor: String?, frameColor: String? = nil) -> Entity {
        let color = bgColor ?? CustomColor.defaultColor
        let entity = CreateMesh().createNode(id: id, position: posision, bgColor: color, borderColor: frameColor)

        entity.name = id
        entity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        entity.components.set(HoverEffectComponent(.highlight(.default)))
        
        // テキストの作成
        let textEntity = CreateMesh().createTextEntity(text: text, position:posision)

        entity.addChild(textEntity) // キューブの子要素としてテキストを追加

        contentEntity.addChild(entity)
        animateOpacity(nodeEntity: entity)
        
        return entity
    }
    
    func addNode(node: NodeType) {
        let newCube = createNodeEntity(
            id: node.id,
            posision: node.position,
            text: node.topic,
            bgColor: node.bgColor
        )
        cubes.append(newCube)
        inputText = ""
        
        // 効果音を再生
        //空間オーディオの指向性の焦点
        let focus = 0.5
        newCube.spatialAudio = SpatialAudioComponent(gain: 10, directivity: .beam(focus: focus))
        guard let audio = SoundManager.audio(type: .addNode) else {
            print("Error to load audio file")
            return
        }
        newCube.playAudio(audio)
    }
    
    func updateNodePosition(entity: Entity, newPosition: SIMD3<Float>) {
        if let index = nodes.firstIndex(where: { "\($0.id)" == entity.name }) {
            nodes[index].position = Point3D(x: newPosition.x, y: newPosition.y, z: newPosition.z)
        }
    }

    @MainActor
    func inputTexts(texts: [String]){
        for text in texts {
            let nodeData = addNodeData(inputText: text, parentId: selectedNodeId)
            guard let nodeData else { return }
            addNode(node: nodeData)
        }
    }
    
    func getIdeas(text: String) async -> [String] {
        let repository = GetIdeasRepository(content: text)
        let ideas = await repository.get() ?? []
        print(ideas)
        return ideas
    }

}
