//
//  ContentView.swift
//  3DMindMap
//
//  Created by TAIGA ITO on 2025/03/21.
//

import SwiftUI
import SwiftData
import RealityKit

struct ContentView: View {
    let id: Int
    @State var model = ImmersiveViewModel.shared
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    
    
    var body: some View {
        VStack {
            Button(action: {
                Task {
                    appModel.immersiveSpaceState = .inTransition
                    switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
                    case .opened:
                        // Don't set immersiveSpaceState to .open because there
                        // may be multiple paths to ImmersiveView.onAppear().
                        // Only set .open in ImmersiveView.onAppear().
                        withAnimation(.easeInOut(duration: 2.0)) { // 1秒かけてスムーズに
                            dismiss()
                        }
                        break
                    case .userCancelled, .error:
                        // On error, we need to mark the immersive space
                        // as closed because it failed to open.
                        dismiss()
                        fallthrough
                    @unknown default:
                        // On unknown response, assume space did not open.
                        withAnimation(.easeInOut(duration: 2.0)) {
                            appModel.immersiveSpaceState = .closed
                        }
                    }
                }
            }, label: {
                Text("マインドマップを開く")
            })
            HStack {
                TextField(
                    "文字を入力",
                    text: $model.inputText
                )
                .focused($isFocused)
                .onAppear() {
                    isFocused = true
                }
                Button(action: {
                    isFocused = false
                    if model.nodes.count == 0 {
                        let nodeData = model.createInitialNodeData(topic: model.inputText)
                        let context = ModelContext(ModelContainerProvider.shared)
                        context.insert(nodeData)
                    } else {
                        let nodeData = model.addNodeData(inputText: model.inputText, parentId: model.selectedNodeId)
                        guard let nodeData else { return }
                        model.addNode(node: nodeData)
                        let context = ModelContext(ModelContainerProvider.shared)
                        context.insert(nodeData)
                    }
                    model.inputText = ""
                    
                    Task { @MainActor in
                        switch appModel.immersiveSpaceState {
                        case .open:                        
                            withAnimation(.easeInOut(duration: 1.0)) {
                                model.isTextField = false
                                // 1秒かけてスムーズに
                                dismiss()
                            }
                            break
                        case .closed:
                            appModel.immersiveSpaceState = .inTransition
                            switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
                            case .opened:
                                // Don't set immersiveSpaceState to .open because there
                                // may be multiple paths to ImmersiveView.onAppear().
                                // Only set .open in ImmersiveView.onAppear().
                                withAnimation(.easeInOut(duration: 2.0)) { // 1秒かけてスムーズに
                                    dismiss()
                                }
                                break
                                
                            case .userCancelled, .error:
                                // On error, we need to mark the immersive space
                                // as closed because it failed to open.
                                dismiss()
                                fallthrough
                            @unknown default:
                                // On unknown response, assume space did not open.
                                withAnimation(.easeInOut(duration: 2.0)) {
                                    appModel.immersiveSpaceState = .closed
                                }
                            }
                            
                        case .inTransition:
                            // This case should not ever happen because button is disabled for this case.
                            break
                        }
                    }
                }, label: {
                    Image(systemName: "paperplane")
                })
                .frame(width: 40, height: 40)
                .padding()
                .cornerRadius(.infinity)
            }
            .padding(.leading, 20)
            .cornerRadius(.infinity)
            .onAppear() {
                do {
                    let context = ModelContext(ModelContainerProvider.shared)
                    let descriptor = FetchDescriptor<NodeType>()
                    let nodes = try context.fetch(descriptor)
                } catch {
                    print("Error fetching nodes: \(error)")
                }
                
            }
            Text("困ったらハートを作ってね！")
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView(id: 1)
        .environment(AppModel())
}
