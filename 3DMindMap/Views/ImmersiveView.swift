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
    
    var body: some View {
        ZStack{
            
            // 背景追加
            RealityView { content, attachments in
                var material = UnlitMaterial()
                guard let resource = try? TextureResource.load(named: "space") else {
                    fatalError("Couldn't load texture resource.")
                }
                material.color = .init(texture: .init(resource))
                
                let entity = Entity()
                entity.components.set(ModelComponent(mesh: .generateSphere(radius: 1000), materials: [material]))
                
                entity.scale *= SIMD3(repeating: -1)
                content.add(entity)
            }attachments: {
                Attachment(id: "uniqueId") {
                    VStack{
                        CommonTextForm(val: $model.inputText, placeholder: "文字を入力", onSubmit: {
                            print("onSubmit")
                            
                        }
                        )
                        .opacity(isTextFieldHidden ? 0 : 1)
                    }
                }
                
            }
            .glassBackgroundEffect()
            .tag("uniqueId")
            
            
            RealityView { content in
                
                
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
                        isTextFieldHidden.toggle()
                        model.addCube(text: "aaa", parentId: "aaa")
                        
                    }
            )
            //デバッグ用でとりあえず一個
            .onAppear(){
                model.addCube(text: "aaa", parentId: "aaa")
                
            }
            
        }
        
    }
}


#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
