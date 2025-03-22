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
    var body: some View {
        // 背景追加
        RealityView { content in
            var material = UnlitMaterial()
            guard let resource = try? TextureResource.load(named: "space") else {
                fatalError("Couldn't load texture resource.")
            }
            material.color = .init(texture: .init(resource))
            
            let entity = Entity()
            entity.components.set(ModelComponent(mesh: .generateSphere(radius: 1000), materials: [material]))
            
            entity.scale *= SIMD3(repeating: -1)
            content.add(entity)
        }
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
                    entity.position = value.convert(value.location3D, from: .local, to: entity.parent!)
                }
        )
        .gesture(
            TapGesture()
                .onEnded {
                    model.addCube()
                    model.addNode(inputText: "aljds", parentId: "ajhsd")
                    print(model.nodes.count)
                }
        )
    }
    
}


#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
