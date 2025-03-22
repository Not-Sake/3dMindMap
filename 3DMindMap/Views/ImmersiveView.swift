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
    @Environment(AppModel.self) var appModel
    @State var model = ImmersiveViewModel()
    @State var cube = Entity()

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            
            content.add(model.setupContentEntity())
            cube = model.addCube(name: "Cube1")
            
        }
        .gesture(
            DragGesture()
                .targetedToEntity(cube)
                .onChanged { value in
                    cube.position = value.convert(value.location3D, from: .local, to: cube.parent!)
                }
        )
        .gesture(
            TapGesture()
                .onEnded {
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
