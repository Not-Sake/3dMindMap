//
//  ContentView.swift
//  3DMindMap
//
//  Created by TAIGA ITO on 2025/03/21.
//

import SwiftUI
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
                    model.addCube(text: model.inputText)
                    
                    Task { @MainActor in
                        switch appModel.immersiveSpaceState {
                        case .open:
                            //                                appModel.immersiveSpaceState = .inTransition
                            //                                await dismissImmersiveSpace()
                            // Don't set immersiveSpaceState to .closed because there
                            // are multiple paths to ImmersiveView.onDisappear().
                            // Only set .closed in ImmersiveView.onDisappear().
                            withAnimation(.easeInOut(duration: 1.0)) { // 1秒かけてスムーズに
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
                                appModel.immersiveSpaceState = .closed
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
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView(id: 1)
        .environment(AppModel())
}
