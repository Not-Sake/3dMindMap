//
//  SoundManager.swift
//  3DMindMap
//
//  Created by TAIGA ITO on 2025/03/23.
//

import RealityFoundation

struct SoundManager {
    enum SoundType: String {
        case enterImmersive = "enter-immersive.mp3"
        case addNode = "add-node.mp3"
        case selectNode = "select-node.mp3"
    }
    
    public static func audio(type: SoundType) -> AudioFileResource? {
        let configuration = AudioFileResource.Configuration(shouldLoop: false)
        var audio: AudioFileResource?
        do {
            audio = try AudioFileResource.load(
                named: type.rawValue,
                configuration: configuration
            )
        } catch {
            print("Failed to load audio file: \(error)")
            return nil
        }
        
        return audio
    }
    
}
