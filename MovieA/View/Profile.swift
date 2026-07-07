import SwiftUI
import PhotosUI

// MARK: - Profile
struct Profile: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var profileModel = ProfileModel.shared
    @ObservedObject private var savedStore = SavedMoviesStore.shared
    @State private var showProfileInfo = false
    @State private var selectedSavedMovie: SavedMovie?

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

                if savedStore.savedMovies.isEmpty {
                    Spacer()

                    VStack {
                        Image("No Saved Movies")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 299)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(
                            columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
                            spacing: 14
                        ) {
                            ForEach(savedStore.savedMovies) { movie in
                                SavedMoviePosterCard(movie: movie) {
                                    selectedSavedMovie = movie
                                }
                            }
                        }
                        .padding(.top, 6)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .navigationDestination(isPresented: $showProfileInfo) {
            ProfileInfoView()
                .environmentObject(profileModel)
        }
        .navigationDestination(item: $selectedSavedMovie) { movie in
            MovieDetailsView(viewModel: MovieDetailsViewModel(movieID: movie.id))
        }
        .navigationBarBackButtonHidden(true)
    }

    private var avatar: some View {
        AvatarView(image: profileModel.avatar)
    }
}

// MARK: - Saved Movie Poster Card
private struct SavedMoviePosterCard: View {
    let movie: SavedMovie
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.06))

                if let url = movie.posterURL {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            Image(systemName: "film")
                                .foregroundStyle(.white.opacity(0.35))
                        }
                    }
                } else {
                    Image(systemName: "film")
                        .foregroundStyle(.white.opacity(0.35))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text(movie.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture { onSelect() }
    }
}

#Preview {
    NavigationStack {
        Profile()
            .preferredColorScheme(.dark)
    }
}
