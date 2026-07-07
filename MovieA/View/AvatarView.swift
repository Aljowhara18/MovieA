import SwiftUI

// MARK: - AvatarView
struct AvatarView: View {
    let image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Circle().fill(.white.opacity(0.15))
                    Image(systemName: "person.fill")
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
    }
}
