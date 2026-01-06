import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var profile: ProfileModel

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var pickedPhoto: PhotosPickerItem?
    @State private var newAvatar: UIImage?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 18) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.yellow)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button {
                        save()
                    } label: {
                        Text("Save")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.yellow)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Text("Edit profile")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)

                ZStack(alignment: .bottomTrailing) {
                    avatarView
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))

                    PhotosPicker(selection: $pickedPhoto, matching: .images) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 28))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.yellow, .black)
                            .background(
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 28, height: 28)
                            )
                            .offset(x: 4, y: 4)
                    }
                    .onChange(of: pickedPhoto) { _, item in
                        Task { await loadImage(from: item) }
                    }
                }
                .padding(.top, 8)

                VStack(spacing: 0) {
                    LabeledFieldRow(title: "First name", text: $firstName)
                    Divider().background(Color.white.opacity(0.08))
                    LabeledFieldRow(title: "Last name", text: $lastName)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .padding(.horizontal, 16)

                Spacer()
            }
        }
        .onAppear {
            firstName = profile.firstName
            lastName = profile.lastName
            newAvatar = profile.avatar
        }
        .navigationBarBackButtonHidden(true)
    }

    private var avatarView: some View {
        Group {
            if let img = newAvatar {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else if UIImage(named: "ProfileAvatar") != nil {
                Image("ProfileAvatar")
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

    private func save() {
        profile.update(firstName: firstName, lastName: lastName, avatar: newAvatar)
        dismiss()
    }

    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let img = UIImage(data: data) {
            await MainActor.run {
                self.newAvatar = img
            }
        }
    }
}

private struct LabeledFieldRow: View {
    let title: String
    @Binding var text: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.white.opacity(0.8))
                .frame(width: 100, alignment: .leading)

            TextField("", text: $text, prompt: Text(title))
                .foregroundStyle(.white)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .tint(.yellow)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    NavigationStack {
        EditProfileView()
            .environmentObject(ProfileModel())
            .preferredColorScheme(.dark)
    }
}
