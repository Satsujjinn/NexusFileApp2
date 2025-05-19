import SwiftUI

struct CategoryCard: View {
    let name: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 40)
                .foregroundColor(.nexusGreen)
            Text(name)
                .font(.headline)
                .foregroundColor(.nexusGreen)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
