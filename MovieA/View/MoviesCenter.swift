//
//  MoviesCenter.swift
//  MovieApp-Team8-M
//
//  Created by Deemah Alhazmi on 23/12/2025.
//

import SwiftUI
import Observation

// MARK: - MoviesCenter

struct MoviesCenter: View {
    @State private var query = ""
    @State private var selectedMovie: Movie?
    @State private var showProfile = false
    @State private var vm = MoviesCenterVM()

    var body: some View {
        NavigationStack {
            ZStack {
                Color("Dark1").ignoresSafeArea()

                content
                    .searchable(
                        text: $query,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search for Movie name, actors"
                    )
            }
            .navigationTitle("Movies Center")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showProfile = true } label: {
                        Image("ProfileAvatar")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    }
                }
            }
            .navigationDestination(item: $selectedMovie) { movie in
                MovieDetailsView(viewModel: MovieDetailsViewModel(movieID: movie.id))
            }
            .navigationDestination(isPresented: $showProfile) {
                Profile()
            }
            .task { await vm.load() }
        }
        .tint(Color("AccentColor", fallback: .yellow))
    }

    // MARK: - UI

    @ViewBuilder
    private var content: some View {
        if vm.isLoading && vm.movies.isEmpty {
            ProgressView("Loading movies...")
                .foregroundStyle(.white)

        } else if let msg = vm.errorMessage, vm.movies.isEmpty {
            VStack(spacing: 12) {
                Text("Failed to load movies")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(msg)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)

                Button("Retry") { Task { await vm.load() } }
                    .buttonStyle(.borderedProminent)
            }
            .padding()

        } else {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {

                    if isSearching {
                        SectionTitle("Results")
                        SearchResultsGrid(items: searchResults) { movie in
                            selectedMovie = movie
                        }
                    } else {
                        SectionTitle("High Rated")
                        HighRatedCarousel(items: vm.highRated) { movie in
                            selectedMovie = movie
                        }

                        // ✅ Match screenshot: Drama row
                        GenreRow(
                            title: "Drama",
                            actionTitle: "Show more",
                            items: vm.byCategory(.drama)
                        ) { movie in
                            selectedMovie = movie
                        }

                        // ✅ Match screenshot: Comedy row
                        GenreRow(
                            title: "Comedy",
                            actionTitle: "Show more",
                            items: vm.byCategory(.comedy)
                        ) { movie in
                            selectedMovie = movie
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
        }
    }

    // MARK: - Search logic

    private var isSearching: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var searchResults: [Movie] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }

        return vm.movies.filter { movie in
            movie.title.lowercased().contains(q) ||
            movie.subtitle.lowercased().contains(q)
        }
    }
}

// MARK: - Section Title

private struct SectionTitle: View {
    let title: String
    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title)
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(.white)
            .padding(.top, 6)
    }
}

// MARK: - High Rated Carousel

private struct HighRatedCarousel: View {
    let items: [Movie]
    let onSelect: (Movie) -> Void

    var body: some View {
        TabView {
            ForEach(items) { movie in
                MovieHeroCard(movie: movie, onSelect: onSelect)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 2)
            }
        }
        .frame(height: 360)
        .tabViewStyle(.page(indexDisplayMode: .automatic))
    }
}

private struct MovieHeroCard: View {
    let movie: Movie
    let onSelect: (Movie) -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            PosterImageView(movie: movie)
                .frame(maxWidth: .infinity)
                .frame(height: 340)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            LinearGradient(
                colors: [.clear, .black.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)

                StarRatingView(value: movie.ratingValue)
                    .font(.caption)

                Text("\(movie.ratingValue, specifier: "%.1f") out of 5")
                    .foregroundStyle(.white.opacity(0.9))
                    .font(.subheadline)

                Text(movie.subtitle)
                    .foregroundStyle(.white.opacity(0.75))
                    .font(.caption)
            }
            .padding(16)
        }
        .contentShape(Rectangle())
        .onTapGesture { onSelect(movie) }
    }
}

// MARK: - Genre Row (Horizontal list)

private struct GenreRow: View {
    let title: String
    let actionTitle: String
    let items: [Movie]
    let onSelect: (Movie) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Button(actionTitle) {
                    // later: push a grid/list screen
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color("AccentColor", fallback: .yellow))
                .buttonStyle(.plain)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(items) { movie in
                        PosterCard(movie: movie, onSelect: onSelect)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Search Results Grid

private struct SearchResultsGrid: View {
    let items: [Movie]
    let onSelect: (Movie) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        if items.isEmpty {
            ContentUnavailableView(
                "No results",
                systemImage: "magnifyingglass",
                description: Text("Try a different name.")
            )
            .tint(.secondary)
            .padding(.top, 24)
        } else {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(items) { movie in
                    PosterCard(movie: movie, onSelect: onSelect)
                }
            }
            .padding(.top, 6)
        }
    }
}

// MARK: - Poster Card

private struct PosterCard: View {
    let movie: Movie
    let onSelect: (Movie) -> Void

    var body: some View {
        PosterImageView(movie: movie)
            .frame(width: 165, height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .contentShape(Rectangle())
            .onTapGesture { onSelect(movie) }
    }
}

// MARK: - Poster Image (API only)

private struct PosterImageView: View {
    let movie: Movie

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.06))

            if let url = movie.posterURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().tint(.white)
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        fallbackIcon
                    @unknown default:
                        fallbackIcon
                    }
                }
            } else {
                fallbackIcon
            }
        }
        .clipped()
    }

    private var fallbackIcon: some View {
        Image(systemName: "film")
            .font(.system(size: 36, weight: .semibold))
            .foregroundStyle(.white.opacity(0.35))
    }
}

// MARK: - Stars

private struct StarRatingView: View {
    let value: Double // 0...5

    var body: some View {
        let full = Int(value.rounded(.down))
        let hasHalf = (value - Double(full)) >= 0.5

        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { i in
                Image(systemName: starName(index: i, full: full, hasHalf: hasHalf))
                    .foregroundStyle(Color("AccentColor", fallback: .yellow))
            }
        }
        .accessibilityLabel("Rating \(value, specifier: "%.1f") out of 5")
    }

    private func starName(index: Int, full: Int, hasHalf: Bool) -> String {
        if index < full { return "star.fill" }
        if index == full && hasHalf { return "star.leadinghalf.filled" }
        return "star"
    }
}

// MARK: - Safe Color fallback

private extension Color {
    init(_ assetName: String, fallback: Color) {
        if UIColor(named: assetName) != nil {
            self.init(assetName)
        } else {
            self = fallback
        }
    }
}

#Preview {
    MoviesCenter()
        .preferredColorScheme(.dark)
}
