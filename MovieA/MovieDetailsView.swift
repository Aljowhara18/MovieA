//
//  MovieDetailsView.swift
//  MovieA
//
//  Created by Jojo on 31/12/2025.
//

import SwiftUI

struct MovieDetailsView: View {
    @StateObject var viewModel: MovieDetailsViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            } else if let movie = viewModel.movie {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        HeaderSection(
                            movieName: movie.name ?? "Untitled",
                            posterURL: movie.poster?.first?.url ?? ""
                        )

                        VStack(alignment: .leading, spacing: 25) {
                            InfoGridView(
                                duration: movie.runtime ?? "—",
                                language: (movie.language ?? []).joined(separator: ", "),
                                genre: (movie.genre ?? []).joined(separator: ", "),
                                age: movie.rating ?? "—"
                            )

                            StorySection(story: movie.story ?? "No story available.")
                            CastSection() // إذا عندك بيانات ديناميكية للطاقم، يمكن إضافتها لاحقًا

                            Rectangle()
                                .frame(width: 355, height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                                .padding(.vertical, 10)

                            RatingsAndReviewsSection() // ممكن تبقي كما هي مؤقتًا
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                }
                .ignoresSafeArea(edges: .top)
            }
        }
    }
}

// MARK: - Header Section
struct HeaderSection: View {
    let movieName: String
    let posterURL: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: posterURL)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(width: 390, height: 448)
            .clipped()

            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                startPoint: .center,
                endPoint: .bottom
            )

            VStack {
                HStack {
                    Image(systemName: "chevron.left")
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .foregroundColor(Color("AccentColor"))
                    Spacer()
                    HStack(spacing: 20) {
                        Image(systemName: "square.and.arrow.up")
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .foregroundColor(Color("AccentColor"))
                        Image(systemName: "bookmark")
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .foregroundColor(Color("AccentColor"))
                    }
                }
                .foregroundColor(.white)
                .padding(.top, 60)
                .padding(.horizontal)
                Spacer()
            }

            Text(movieName)
                .font(.system(size: 35, weight: .bold))
                .foregroundColor(.white)
                .padding(.leading, 20)
                .padding(.bottom, 20)
        }
        .frame(width: 390, height: 448)
    }
}

// MARK: - Info Grid View
struct InfoGridView: View {
    let duration: String
    let language: String
    let genre: String
    let age: String

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 20) {
            infoItem(title: "Duration", value: duration)
            infoItem(title: "Language", value: language)
            infoItem(title: "Genre", value: genre)
            infoItem(title: "Age", value: age)
        }
    }

    func infoItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.system(size: 18, weight: .bold)).foregroundColor(.white)
            Text(value).font(.system(size: 14)).foregroundColor(.gray)
        }
    }
}

// MARK: - Story Section
struct StorySection: View {
    let story: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Story").font(.headline).foregroundColor(.white)
            Text(story)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
    }
}

// MARK: - Cast Section
struct CastSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Director").font(.headline).foregroundColor(.white)
            Image("Director")
                .resizable()
                .scaledToFit()
                .frame(width: 76, height: 76)
                .clipShape(Circle())
            Text("Frank Darabont")
                .font(.footnote)
                .foregroundColor(.white)

            Text("Stars").font(.headline).foregroundColor(.white)
            HStack(spacing: 25) {
                castMember(imageName: "Tim", name: "Tim Robbins")
                castMember(imageName: "Morgan", name: "Morgan Freeman")
                castMember(imageName: "Bob", name: "Bob Gunton")
            }
        }
    }

    func castMember(imageName: String, name: String) -> some View {
        VStack(spacing: 6) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 76, height: 76)
                .clipShape(Circle())
            Text(name)
                .font(.system(size: 12))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Ratings & Reviews Section
struct RatingsAndReviewsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Rating & Reviews").font(.headline).foregroundColor(.white)
            VStack(alignment: .leading) {
                Text("4.8").font(.system(size: 45, weight: .bold)).foregroundColor(.white)
                Text("out of 5").font(.caption).foregroundColor(.gray)
                Text("⭐⭐⭐⭐").font(.caption)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ReviewCard(reviewerName: "Afnan Abdullah")
                    ReviewCard(reviewerName: "Sara Alqahtani")
                    ReviewCard(reviewerName: "Mohammed Ali")
                }
            }
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Review Card
struct ReviewCard: View {
    let reviewerName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(getAvatar(for: reviewerName))
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text(reviewerName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("⭐⭐⭐⭐").font(.system(size: 10))
                }
                Spacer()
            }
            Text("This is an engagingly simple, good-hearted film, with just enough darkness around the edges to give contrast and relief to its glowingly benign view of human nature.")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(4)
            Spacer()
            HStack {
                Spacer()
                Text("Tuesday").font(.system(size: 10)).foregroundColor(.gray)
            }
        }
        .padding()
        .frame(width: 305, height: 188)
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }

    func getAvatar(for name: String) -> String {
        switch name {
        case "Afnan Abdullah": return "Avatar1"
        case "Sara Alqahtani": return "Avatar2"
        case "Mohammed Ali": return "Avatar3"
        default: return "DefaultAvatar"
        }
    }
}

// MARK: - Preview
struct MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailsView(viewModel: MovieDetailsViewModel(movieID: "anyID"))
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 15 Pro")
    }
}
