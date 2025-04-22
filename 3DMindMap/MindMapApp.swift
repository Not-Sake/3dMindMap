//
//  _DMindMapApp.swift
//  3DMindMap
//
//  Created by TAIGA ITO on 2025/03/21.
//

import SwiftUI
import SwiftData

@main
struct MindMapApp: App {
    @State private var appModel = AppModel()
    @State private var avPlayerViewModel = AVPlayerViewModel()
    
    var body: some Scene {
        WindowGroup() {
            ContentView()
                .environment(appModel)
        }
        .defaultSize(CGSize(width: 400, height: 5))
        
        WindowGroup("New Window", for: NewWindowID.ID.self) { $id in
            AddTopicView(id: id ?? 1)
                .environment(appModel)
                .modelContainer(for: NodeType.self)
        }
        .defaultSize(CGSize(width: 400, height: 5))
        
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView( gestureModel: HeartGestureModel())
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                    avPlayerViewModel.play()
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                    avPlayerViewModel.reset()
                }
                .modelContainer(for: NodeType.self)
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
