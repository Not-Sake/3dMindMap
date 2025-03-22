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
        Button("キューブを追加") {
            model.addCube()
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .clipShape(Capsule())
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
