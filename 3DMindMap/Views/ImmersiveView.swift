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
    @Environment(\.modelContext) var modelContext
    @Query var nodes: [NodeType]

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)
            }
        }
    }
}

extension ImmersiveView {
    func addNode(inputText: String, parentId: String) {
        let newNode = NodeType.init(topic: inputText, parentId: parentId)
        modelContext.insert(newNode)
    }

}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
