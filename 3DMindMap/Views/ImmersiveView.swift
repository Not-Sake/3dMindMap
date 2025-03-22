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
    @Environment(AppModel.self) var appModel
    @State var model = ImmersiveViewModel()
    @State var cube = Entity()
    @Environment(\.modelContext) var modelContext
    @Query var nodes: [NodeType]

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
        
    }
}

extension ImmersiveView {
    func addNode(inputText: String, parentId: String) {
        let newNode = NodeType.init(topic: inputText, parentId: parentId)
        modelContext.insert(newNode)
    }
    func deleteNode(id: String) {
        if let itemToDelete = nodes.first(where: { $0.id == id }) {
            modelContext.delete(itemToDelete)
        }
    }
}

#Preview(immersionStyle: .full) {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: NodeType.self, configurations: config)
    ImmersiveView()
        .environment(AppModel())
        .modelContainer(container)
}
