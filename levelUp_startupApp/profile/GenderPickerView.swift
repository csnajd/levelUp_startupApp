import SwiftUI

struct GenderPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedGender: Gender
    
    var body: some View {
        NavigationView {
            List(Gender.allCases, id: \.self) { gender in
                Button(action: {
                    selectedGender = gender
                    dismiss()
                }) {
                    HStack {
                        Text(gender.displayName)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedGender == gender {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select Gender")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}