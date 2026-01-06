//  MovieDetailsView.swift
//  MovieA
//
//  Created by Jojo on 31/12/2025.
//
import SwiftUI



// MARK: - Main View
struct MovieDetailsView: View {
    @StateObject var viewModel: MovieDetailsViewModel
    @State private var newReviewText: String = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.isLoading && viewModel.movie == nil {
                ProgressView().tint(.white).scaleEffect(1.5)
            } else if let movie = viewModel.movie {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        HeaderSection(movieName: movie.title, posterURL: movie.posterURL)

                        VStack(alignment: .leading, spacing: 25) {
                            // تم تعديل المحاذاة هنا لتكون لليسار
                            InfoGridView(
                                duration: movie.runtime,
                                language: movie.language.joined(separator: ", "),
                                genre: movie.genre.joined(separator: ", "),
                                age: movie.ageRating
                            )
                            
                            StorySection(story: movie.story)
                            
                            CastSection(director: viewModel.director, actors: viewModel.actors)

                            // إضافة ريفيو
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Add Your Review").font(.headline).foregroundColor(.white)
                                HStack {
                                    TextField("Write your opinion...", text: $newReviewText)
                                        .padding(12)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(10)
                                        .foregroundColor(.white)
                                    
                                    Button(action: {
                                        if !newReviewText.isEmpty {
                                            let textToPost = newReviewText
                                            Task {
                                                await viewModel.postReview(text: textToPost, rate: 5)
                                                newReviewText = ""
                                                hideKeyboard()
                                            }
                                        }
                                    }) {
                                        Image(systemName: "paperplane.fill")
                                            .padding(12)
                                            .background(newReviewText.isEmpty ? Color.gray : Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                    .disabled(newReviewText.isEmpty)
                                }
                            }
                            
                            RatingsAndReviewsSection(
                                rating: movie.imdbRating ?? 0.0,
                                reviews: viewModel.reviews,
                                onDelete: { id in
                                    Task { await viewModel.deleteReview(reviewID: id) }
                                }
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 50)
                    }
                }
                .ignoresSafeArea(edges: .top)
            }
        }
    }
}

// MARK: - InfoGridView (التعديل المطلوب هنا)
struct InfoGridView: View {
    let duration, language, genre, age: String
    
    var body: some View {
        // تم تغيير الـ alignment إلى .leading لجعل الشبكة تبدأ من اليسار
        LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)], spacing: 20) {
            infoItem(title: "Duration", value: duration)
            infoItem(title: "Language", value: language)
            infoItem(title: "Genre", value: genre)
            infoItem(title: "Age", value: age)
        }
    }
    
    func infoItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) { // محاذاة النص داخل العنصر لليسار
            Text(title).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
            Text(value).font(.system(size: 14)).foregroundColor(.gray)
        }
    }
}

// MARK: - بقية المكونات (ثابتة بدون تغيير)

struct HeaderSection: View {
    let movieName: String
    let posterURL: URL?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: posterURL) { phase in
                    if let img = phase.image {
                        img.resizable().aspectRatio(contentMode: .fill)
                    } else { Color.gray.opacity(0.2) }
                }
                .frame(width: UIScreen.main.bounds.width, height: 448)
                .clipped()
                
                LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
                Text(movieName).font(.system(size: 32, weight: .bold)).foregroundColor(.white).padding()
            }
            
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left").font(.title3).padding(12)
                        .background(Color.black.opacity(0.5)).clipShape(Circle())
                }
                Spacer()
                HStack(spacing: 15) {
                    Button(action: { shareMovie() }) {
                        Image(systemName: "square.and.arrow.up").font(.title3).padding(12)
                            .background(Color.black.opacity(0.5)).clipShape(Circle())
                    }
                    Button(action: { }) {
                        Image(systemName: "bookmark").font(.title3).padding(12)
                            .background(Color.black.opacity(0.5)).clipShape(Circle())
                    }
                }
            }
            .foregroundColor(.white).padding(.top, 60).padding(.horizontal)
        }
    }
    
    func shareMovie() {
        let movieText = "Check out this movie: \(movieName)!"
        let activityVC = UIActivityViewController(activityItems: [movieText], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}

struct CastSection: View {
    let director: Director?
    let actors: [Actor]
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Director").font(.headline).foregroundColor(.white)
            if let d = director {
                personItem(name: d.name, url: d.imageURL)
            }
            Text("Stars").font(.headline).foregroundColor(.white)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 25) {
                    ForEach(actors) { actor in
                        personItem(name: actor.name, url: actor.imageURL)
                    }
                }
            }
        }
    }
    func personItem(name: String, url: URL?) -> some View {
        VStack(spacing: 6) {
            AsyncImage(url: url) { phase in
                if let img = phase.image { img.resizable().aspectRatio(contentMode: .fill) }
                else { Circle().fill(Color.gray.opacity(0.3)).overlay(Image(systemName: "person.fill").foregroundColor(.white.opacity(0.5))) }
            }.frame(width: 60, height: 60).clipShape(Circle())
            Text(name).font(.system(size: 10)).foregroundColor(.white).lineLimit(1)
        }
    }
}

struct StorySection: View {
    let story: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Story").font(.headline).foregroundColor(.white)
            Text(story).foregroundColor(.gray).font(.subheadline).lineSpacing(4)
        }
    }
}

struct RatingsAndReviewsSection: View {
    let rating: Double
    let reviews: [Review]
    var onDelete: (String) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rating & Reviews").font(.title2).fontWeight(.bold).foregroundColor(.white)
            HStack(alignment: .bottom, spacing: 8) {
                Text(String(format: "%.1f", rating / 2.0)).font(.system(size: 45, weight: .bold)).foregroundColor(.white)
                Text("out of 5").font(.subheadline).foregroundColor(.gray).padding(.bottom, 8)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    if reviews.isEmpty { Text("No reviews yet.").foregroundColor(.gray).padding() }
                    else {
                        ForEach(reviews) { review in
                            ReviewCard(review: review, onDelete: { onDelete(review.id) })
                        }
                    }
                }
            }
        }
    }
}

struct ReviewCard: View {
    let review: Review
    var onDelete: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "person.crop.circle.fill").resizable().frame(width: 30, height: 30).foregroundColor(.blue)
                Text(review.userName).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                Spacer()
                Button(action: onDelete) { Image(systemName: "trash").font(.caption).foregroundColor(.red.opacity(0.7)) }
            }
            Text(String(repeating: "⭐", count: Int(max(1, review.rating / 2.0)))).font(.caption)
            Text(review.text).font(.system(size: 13)).foregroundColor(.gray).lineLimit(3)
        }
        .padding().frame(width: 280, height: 160).background(Color.white.opacity(0.06)).cornerRadius(15)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}

extension View {
    func hideKeyboard() { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
}
