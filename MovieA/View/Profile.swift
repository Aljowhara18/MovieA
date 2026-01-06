//
//  Profile.swift
//  MovieApp-Team8-M
//
//  Created by Teif May on 05/07/1447 AH.
//

import SwiftUI
import PhotosUI

struct Profile: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var profileModel = ProfileModel()
    @State private var showProfileInfo = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
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
                .padding(.top, 8)

                Text("Profile")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(2)

                Button {
                    showProfileInfo = true
                } label: {
                    HStack(spacing: 12) {
                        avatar
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(profileModel.firstName) \(profileModel.lastName)".trimmingCharacters(in: .whitespaces))
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.white)

                            Text(profileModel.email)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white.opacity(0.6))
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                Text("Saved movies")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 4)

                Spacer()

                VStack {
                    Image("No Saved Movies")
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 299)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .navigationDestination(isPresented: $showProfileInfo) {
            ProfileInfoView()
                .environmentObject(profileModel)
        }
        .navigationBarBackButtonHidden(true)
    }

    private var avatar: some View {
        Group {
            if let image = profileModel.avatar {
                Image(uiImage: image)
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
        Profile()
            .preferredColorScheme(.dark)
    }
}
