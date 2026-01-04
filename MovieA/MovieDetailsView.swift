//
//  MovieDetailsView.swift
//  MovieA
//
//  Created by Jojo on 31/12/2025.
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
                VStack {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                    Text("Loading Movie Details...")
                        .foregroundColor(.gray)
                        .padding(.top)
                }

            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)

                    Text(errorMessage)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Button("Retry") {
                        viewModel.fetchMovieDetails()
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding()

            } else if let movie = viewModel.movie {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        HeaderSection(
                            movieName: movie.title,
                            posterURL: movie.posterURL
                        )

                        VStack(alignment: .leading, spacing: 25) {
                            InfoGridView(
                                duration: movie.runtime.isEmpty ? "—" : movie.runtime,
                                language: movie.language.isEmpty ? "—" : movie.language.joined(separator: ", "),
                                genre: movie.genre.isEmpty ? "—" : movie.genre.joined(separator: ", "),
                                age: movie.ageRating.isEmpty ? "—" : movie.ageRating
                            )

                            StorySection(story: movie.story.isEmpty ? "No story available." : movie.story)

                            // تم تمرير المخرج من الـ ViewModel هنا
                            CastSection(director: viewModel.director)

                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                                .padding(.vertical, 10)

                            RatingsAndReviewsSection(rating: movie.imdbRating ?? 0.0)
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
    let posterURL: URL?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                if let url = posterURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        case .failure:
                            Color.gray
                        case .empty:
                            ZStack {
                                Color.black.opacity(0.2)
                                ProgressView().tint(.white)
                            }
                        @unknown default:
                            Color.gray
                        }
                    }
                } else {
                    Color.gray
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: 448)
            .clipped()

            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.9)]),
                startPoint: .center,
                endPoint: .bottom
            )

            VStack {
                HStack {
                    Image(systemName: "chevron.left")
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .foregroundColor(.white)

                    Spacer()

                    HStack(spacing: 20) {
                        Image(systemName: "square.and.arrow.up")
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .foregroundColor(.white)

                        Image(systemName: "bookmark")
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 60)
                .padding(.horizontal)

                Spacer()
            }

            Text(movieName)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .padding(.leading, 20)
                .padding(.bottom, 20)
                .shadow(radius: 10)
        }
        .frame(height: 448)
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
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Story Section
struct StorySection: View {
    let story: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Story")
                .font(.headline)
                .foregroundColor(.white)

            Text(story)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
    }
}

// MARK: - Cast Section (تحديث لعرض المخرج الحقيقي)
// MARK: - Cast Section
struct CastSection: View {
    let director: Director?

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // عنوان قسم المخرج
            Text("Director")
                .font(.headline)
                .foregroundColor(.white)

            if let director = director {
                // نستخدم نفس تصميم الممثلين للمخرج
                directorItem(name: director.name, url: director.imageURL)
            } else {
                // حالة التحميل (Placeholder)
                directorItem(name: "Loading...", url: nil)
            }

            // عنوان قسم الممثلين
            Text("Stars")
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 25) {
                castMember(name: "Tim Robbins")
                castMember(name: "Morgan Freeman")
                castMember(name: "Bob Gunton")
            }
        }
    }

    // دالة خاصة للمخرج بنفس ستايل الـ castMember تماماً
    // الدالة المحدثة للمخرج ليكون الاسم في سطر واحد
        func directorItem(name: String, url: URL?) -> some View {
            VStack(spacing: 6) {
                Group {
                    if let url = url {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                    } else {
                        Image(systemName: "person.circle")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())

                Text(name)
                    .font(.system(size: 10))
                    .foregroundColor(.white)
                    .lineLimit(1) // يمنع النزول لسطر جديد
                    .fixedSize(horizontal: true, vertical: false) // يسمح للنص بالتمدد أفقياً
            }
        }
    // دالة الممثلين الحالية (للمقارنة والتأكد من التطابق)
    func castMember(name: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)

            Text(name)
                .font(.system(size: 10))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(width: 70)
        }
    }
}

    func castMember(name: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)

            Text(name)
                .font(.system(size: 10))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(width: 70)
        }
    }


// MARK: - Ratings & Reviews Section
struct RatingsAndReviewsSection: View {
    let rating: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Rating & Reviews")
                .font(.headline)
                .foregroundColor(.white)

            VStack(alignment: .leading) {
                Text(String(format: "%.1f", rating))
                    .font(.system(size: 45, weight: .bold))
                    .foregroundColor(.white)

                Text("out of 10 (IMDb)")
                    .font(.caption)
                    .foregroundColor(.gray)
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
                Image(systemName: "person.fill")
                    .resizable()
                    .padding(8)
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(Circle())
                    .foregroundColor(.white)

                VStack(alignment: .leading) {
                    Text(reviewerName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)

                    Text("⭐⭐⭐⭐")
                        .font(.system(size: 10))
                }
                Spacer()
            }

            Text("This is an engagingly simple, good-hearted film, with just enough darkness around the edges to give contrast.")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(4)

            Spacer()

            HStack {
                Spacer()
                Text("Tuesday")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(width: 305, height: 160)
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}
// MARK: - Preview
struct MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        // نمرر ID موجود فعلياً في بياناتك لتجربة العرض
        MovieDetailsView(viewModel: MovieDetailsViewModel(movieID: "recfNj1e4waOUJLxd"))
            .preferredColorScheme(.dark)
    }
}
