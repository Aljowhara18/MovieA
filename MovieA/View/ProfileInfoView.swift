import SwiftUI

struct ProfileInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var profile: ProfileModel
    @State private var showEdit = false

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
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)

                Text("Profile info")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)

                avatar
                    .frame(width: 96, height: 96)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("First name")
                            .foregroundStyle(.white.opacity(0.8))
                        Spacer()
                        Text(profile.firstName)
                            .foregroundStyle(.white)
                    }
                    .padding(12)
                    .background(cardBackground)

                    HStack {
                        Text("Last name")
                            .foregroundStyle(.white.opacity(0.8))
                        Spacer()
                        Text(profile.lastName)
                            .foregroundStyle(.white)
                    }
                    .padding(12)
                    .background(cardBackground)
                }
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Button {
                    showEdit = true
                } label: {
                    Text("Edit profile")
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)

                Spacer()

                Button {
                    profile.signOut {
                        dismiss()
                    }
                } label: {
                    Text("Sign Out")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }

        .navigationDestination(isPresented: $showEdit) {
            EditProfileView()
                .environmentObject(profile)
        }
        .navigationBarBackButtonHidden(true)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color.white.opacity(0.08))
    }

    private var avatar: some View {
        Group {
            if let img = profile.avatar {
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
}

#Preview {
    NavigationStack {
        ProfileInfoView()
            .environmentObject(ProfileModel())
            .preferredColorScheme(.dark)
    }
}
