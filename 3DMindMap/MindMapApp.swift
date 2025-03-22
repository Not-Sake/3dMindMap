//
//  _DMindMapApp.swift
//  3DMindMap
//
//  Created by TAIGA ITO on 2025/03/21.
//

import SwiftUI

@main
struct MindMapApp: App {
    @State private var appModel = AppModel()
    @State private var avPlayerViewModel = AVPlayerViewModel()
    
    var body: some Scene {
        WindowGroup("New Window", for: NewWindowID.ID.self) { $id in
            ContentView(id: id ?? 1)
                .environment(appModel)
        }
        .defaultSize(CGSize(width: 400, height: 5))
        
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                    avPlayerViewModel.play()
                    appModel.isContentViewActive = false
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                    appModel.isContentViewActive = true
                    avPlayerViewModel.reset()
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
