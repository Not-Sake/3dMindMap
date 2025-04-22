//
//  ImmersiveView.swift
//  3DMindMap
//
//  Created by TAIGA ITO on 2025/03/21.
//
import SwiftData
import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @State private var cubes: [Entity] = []
    @State var model = ImmersiveViewModel.shared
    @State var nextWindowID = NewWindowID(id: 1)
    @Environment(\.openWindow) private var openWindow
    @ObservedObject var gestureModel: HeartGestureModel
    @State var load = false
    
    var body: some View {
        RealityView { content in
            // 背景追加
            var material = UnlitMaterial()
            guard let resource = try? TextureResource.load(named: "cyber") else {
                fatalError("Couldn't load texture resource.")
            }
            material.color = .init(texture: .init(resource))
            
            let entity = Entity()
            entity.components.set(ModelComponent(mesh: .generateSphere(radius: 1000), materials: [material]))
            
            entity.scale *= SIMD3(repeating: -1)
            content.add(entity)
            
            let scene = model.setupContentEntity()
            content.add(scene)
            
            for cube in model.cubes {
                model.animateOpacity(nodeEntity: cube)
            }
            if load == true{
                // memo もっと後ろに配置する
                do {
                    // heartanimationを非同期で読み込む
                    let heartModel = try await Entity(named: "heartanimation", in: RealityKitContent.realityKitContentBundle)
                    heartModel.scale = SIMD3(repeating: 0.1)
                    
                    // Y軸を反転
                    heartModel.scale *= SIMD3(x: 1, y: -1, z: 1)
                    
                    if let animation = heartModel.availableAnimations.first {
                        heartModel.playAnimation(animation.repeat())
                    }
                    
                    // シーンにheartModelを追加
                    scene.addChild(heartModel)
                    
                } catch {
                    // エラーハンドリング
                    print("Error loading entity or playing animation: \(error)")
                }
            }
        }
        .task {
            await gestureModel.start()
        }
        .task {
            await gestureModel.publishHandTrackingUpdates()
        }
        .task {
            await gestureModel.monitorSessionEvents()
        }
        .task {
            await monitorHeartGesture()
        }
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    do {
                        let context = ModelContext(ModelContainerProvider.shared)
                        let descriptor = FetchDescriptor<NodeType>()
                        let nodes = try context.fetch(descriptor)
                        let entity = value.entity
                        let newPos = value.convert(value.location3D, from: .local, to: entity.parent!)
                        // 位置を変更
                        entity.position = newPos
                        // ノード情報も更新
                        model.updateNodePosition(entity: entity, newPosition: newPos)
                        if let index = nodes.firstIndex(where: { "\($0.id)" == entity.name }) {
                            nodes[index].position = Point3D(x: newPos.x, y: newPos.y, z: newPos.z)
                            let context = ModelContext(ModelContainerProvider.shared)
                            let descriptor = FetchDescriptor<NodeType>()
                            if let node = try context.fetch(descriptor).first(where: { $0.id == nodes[index].id }) {
                                node.position = Point3D(x: newPos.x, y: newPos.y, z: newPos.z)
                                try? context.save()
                            }
                        }
                    } catch {
                        print("Error fetching nodes: \(error)")
                    }
                }
        )
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    model.isTextField = true
                    let entity = value.entity
                    let entityId = entity.name
                    model.selectedNodeId = entityId
                    print("selected", model.selectedNodeId)
                    openWindow(value: nextWindowID.id)
                    //クリック音再生
                    //空間オーディオの指向性の焦点
                    let focus = 0.5
                    entity.spatialAudio = SpatialAudioComponent(gain: 10, directivity: .beam(focus: focus))
                    guard let audio = SoundManager.audio(type: .selectNode) else {
                        print("Error to load audio file")
                        return
                    }
                    entity.playAudio(audio)
                }
        )
        .onAppear() {
            do {
                let context = ModelContext(ModelContainerProvider.shared)
                let descriptor = FetchDescriptor<NodeType>()
                let nodes = try context.fetch(descriptor)
                for node in nodes {
                    let cube = model.createNodeEntity(id: node.id, posision: node.position, text: node.topic, bgColor: node.bgColor, frameColor: node.frameColor)
                    model.cubes.append(cube)
                }
            } catch {
                print("Error fetching nodes: \(error)")
            }
        }
    }
    
    init(gestureModel: HeartGestureModel) {
        self.gestureModel = gestureModel
    }
    
    func monitorHeartGesture() async {
        while true {
            if let _ = gestureModel.computeTransformOfUserPerformedHeartGesture() {
                print("Heartできた！!")
                do{
                    let node = model.findNode(id: model.selectedNodeId)
                    if node != nil {
                        let topic = node?.topic
                        let  texts =  await model.getIdeas(text: topic ?? "")
                        model.inputTexts(texts: texts)
                        sleep(5)
                    }
                    else{
                        print(node?.topic)
                    }
                }
            }
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒ごとにチェック
        }
    }
    private func hideKeyboard() {
           UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
       }
}

#Preview(immersionStyle: .full) {
    ImmersiveView(gestureModel: HeartGestureModel())
        .environment(AppModel())
}
