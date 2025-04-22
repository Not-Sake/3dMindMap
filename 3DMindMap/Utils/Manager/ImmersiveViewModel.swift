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
    
    func addNodeData(inputText: String, parentId: String, position: Point3D, id: String) -> NodeType? {
        let parentNode = findNode(id: parentId)
        if parentNode == nil {
            return nil
        }
        let childColor = findChild(parentId: parentId)?.bgColor
        let color = parentNode?.childrenCount == 0 ? RandomColor().getRandomColor(parentNode?.bgColor) : childColor
        let newNode = NodeType(id: id, topic: inputText, parentId: parentId, position: position, bgColor: color, frameColor: nil)
        nodes.append(newNode)
        
        if parentNode?.childrenCount == 0 {
            if let index = cubes.firstIndex(where: { "\($0.name)" == "\(parentId)" }) {
                let entity = cubes[index]
                if let parentBorder = entity.children.first(where: { "\($0.name)" == "border_\(parentId)" }) {
                    let borderUIColor = UIColor(color ?? Color.black)
                    let borderMaterial = UnlitMaterial(color: borderUIColor)
                    parentBorder.components[ModelComponent.self]?.materials = [borderMaterial]
                    parentNode?.frameColor = color
                }
            }
        }
        parentNode?.childrenCount += 1
        return newNode
    }
    
    func createNodeEntity(id: String, posision: Point3D, text: String, bgColor: Color?) -> Entity {
        let entity = CreateMesh().createNode(id: id, position: posision, bgColor: bgColor ?? Color.white, borderColor: nil)

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
    
    func addNode(text:String) {
        let id = UUID().uuidString
        let position = CalculatorManager().newPosition(parentId: selectedNodeId, nodes: nodes)
        let newEntity = addNodeData(inputText: inputText, parentId: selectedNodeId, position: position, id: id)
        let newCube = createNodeEntity(
            id: id,
            posision: position,
            text: text,
            bgColor: newEntity?.bgColor
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
    
    func addInitialNode(text: String) {
        let x: Float = 0
        let y: Float = 1.2
        let z: Float = -3.25
        let id = UUID().uuidString
        
        let newCube = createNodeEntity(
            id: id,
            posision: Point3D(x: x, y: y, z: z), text: text,
            bgColor: Color.white
        )
        cubes.append(newCube)
        nodes.append(NodeType(id: id, topic: inputText, parentId: "", position: Point3D(x: x, y: y, z: z), bgColor: Color.white, frameColor: nil))
        inputText = ""
        
        // 効果音を再生
        //空間オーディオの指向性の焦点
        let focus = 0.5
        newCube.spatialAudio = SpatialAudioComponent(gain: 10, directivity: .beam(focus: focus))
        guard let audio = SoundManager.audio(type: .enterImmersive) else {
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

    func inputTexts(texts: [String]){
        for text in texts {
            addNode(text: text)
        }
    }
    

    
    func getIdeas(text: String) async -> [String] {
        let repository = GetIdeasRepository(content: text)
        let ideas = await repository.getGeminiIdeas()
        return ideas
    }
}
