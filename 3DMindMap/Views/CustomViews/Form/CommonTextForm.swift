import SwiftUI

struct CommonTextForm: View {
    let val: Binding<String>
    let placeholder: String
    let onSubmit: () -> Void
    
    var body: some View {
        HStack {
            TextField(
                placeholder,
                text: val
            )
            Button(action: onSubmit) {
                Image(systemName: "paperplane")
            }
            .frame(width: 40, height: 40)
            .padding()
            .cornerRadius(.infinity)
        }
        .padding(.leading, 20)
        .cornerRadius(.infinity)
    }
}

#Preview(windowStyle: .automatic) {
    @Previewable @State var text = ""
    CommonTextForm(val: $text, placeholder: "Hello", onSubmit: {print("Hello")})
}
