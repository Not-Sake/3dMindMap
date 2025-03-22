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
    @State var model = ImmersiveViewModel()
    @State var cube = Entity()
    @State var isTextFieldHidden = false
    @State var nextWindowID = NewWindowID(id: 1)
    
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        RealityView { content in
            
            // 背景追加
            var material = UnlitMaterial()
            guard let resource = try? TextureResource.load(named: "space") else {
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
                .onEnded {
                    
                    if isTextFieldHidden {
                        isTextFieldHidden.toggle()
                        model.addCube(text: "aaa", parentId: "aaa")
                    }else{
                        isTextFieldHidden.toggle()
                    }
                }
        )
        //デバッグ用でとりあえず一個
        .onAppear(){
            model.addCube(text: "aaa", parentId: "aaa")
            
        }
        .onChange(of: isTextFieldHidden){
            openWindow(value: nextWindowID.id)
            
        }
        
    }
    
}



#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
