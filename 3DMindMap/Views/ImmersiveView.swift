//
//  ImmersiveView.swift
//  3DMindMap
//
//  Created by TAIGA ITO on 2025/03/21.
//
import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @State private var cubes: [Entity] = []
    @State var model = ImmersiveViewModel.shared
    @State var nextWindowID = NewWindowID(id: 1)
    @Environment(\.openWindow) private var openWindow
    @ObservedObject var gestureModel: HeartGestureModel
   
    
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
            
            for cube in cubes {
                scene.addChild(cube)
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
                    let entity = value.entity
                    let newPos = value.convert(value.location3D, from: .local, to: entity.parent!)
                    
                    // 位置を変更
                    entity.position = newPos
                    
                    // ノード情報も更新
                    model.updateNodePosition(entity: entity, newPosition: newPos)
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
            
                }
        )
    }
    
    
    func monitorHeartGesture() async {
        if model.isTextField == true{
        while true {
                if let _ = gestureModel.computeTransformOfUserPerformedHeartGesture() {
                    print("Heartできた！!")
                    model.inputTexts(texts: ["りんご","バナナ","きゅうり"])
                }
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒ごとにチェック
            }
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView(gestureModel: HeartGestureModel())
        .environment(AppModel())
}
