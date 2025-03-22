//
//  TextFieldView.swift
//  3DMindMap
//
//  Created by saki on 2025/03/22.
//
import SwiftUI

struct TextFieldView: View {
    let id: Int
    @State var model = ImmersiveViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            CommonTextForm(val: $model.inputText, placeholder: "文字を入力", onSubmit: {
                dismiss()
            })
        }
        
    }
}

#Preview {
    TextFieldView(id: 1)
}
