
//  MovieDetailsView.swift
//  MovieA
//
//  Created by Jojo on 31/12/2025.
//
//  MovieDetailsView.swift
//  MovieA
//
//  Created by Jojo on 31/12/2025.
import SwiftUI
import Combine
/**

// MARK: - Main View
struct MovieDetailsView: View {
    @StateObject var viewModel: MovieDetailsViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView().tint(.white).scaleEffect(1.5)
            } else if let movie = viewModel.movie {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        HeaderSection(movieName: movie.title, posterURL: movie.posterURL)

                        VStack(alignment: .leading, spacing: 25) {
                            InfoGridView(
                                duration: movie.runtime,
                                language: movie.language.joined(separator: ", "),
                                genre: movie.genre.joined(separator: ", "),
                                age: movie.ageRating
                            )
                            StorySection(story: movie.story)
                            
                            CastSection(director: viewModel.director, actors: viewModel.actors)

                            // تمرير مصفوفة الريفيوز الحقيقية من الـ ViewModel
                            RatingsAndReviewsSection(rating: movie.imdbRating ?? 0.0, reviews: viewModel.reviews)
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

// MARK: - Cast Section
struct CastSection: View {
    let director: Director?
    let actors: [Actor]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Director").font(.headline).foregroundColor(.white)
            if let director = director {
                personItem(name: director.name, url: director.imageURL)
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
            if let imageURL = url {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        errorPlaceholder
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            } else {
                errorPlaceholder.frame(width: 60, height: 60).clipShape(Circle())
            }
            
            Text(name).font(.system(size: 10)).foregroundColor(.white).lineLimit(1).fixedSize(horizontal: true, vertical: false)
        }
    }
    
    var errorPlaceholder: some View {
        ZStack { Circle().fill(Color.gray.opacity(0.3)); Image(systemName: "person.fill").foregroundColor(.white.opacity(0.5)) }
    }
}

// MARK: - Ratings And Reviews Section
struct RatingsAndReviewsSection: View {
    let rating: Double
    let reviews: [Review] // استقبال الريفيوز الحقيقية

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rating & Reviews").font(.title2).fontWeight(.bold).foregroundColor(.white)

            HStack(alignment: .bottom, spacing: 8) {
                Text(String(format: "%.1f", rating / 2.0)).font(.system(size: 45, weight: .bold)).foregroundColor(.white)
                Text("out of 5 (IMDb)").font(.subheadline).foregroundColor(.gray).padding(.bottom, 8)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    if reviews.isEmpty {
                        Text("No reviews yet.").foregroundColor(.gray).font(.caption).padding()
                    } else {
                        ForEach(reviews) { review in
                            ReviewCard(review: review)
                        }
                    }
                }
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Review Card
struct ReviewCard: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill").foregroundColor(.gray)
                Text(review.userName).fontWeight(.semibold).foregroundColor(.white).lineLimit(1)
            }
            // عرض النجوم بناءً على الريفيو الحقيقي (مقسم على 2)
            Text(String(repeating: "⭐", count: Int(max(1, review.rating / 2.0))))
                .font(.caption)

            Text(review.text).font(.subheadline).foregroundColor(.gray).lineLimit(3)
            Spacer()
            Text("Recent").font(.caption2).foregroundColor(.gray)
        }
        .padding()
        .frame(width: 280, height: 160)
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

// MARK: - باقي مكونات التصميم (Header, InfoGrid, Story)
struct HeaderSection: View {
    let movieName: String; let posterURL: URL?
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: posterURL) { phase in
                if let image = phase.image { image.resizable().aspectRatio(contentMode: .fill) }
                else { Color.gray.opacity(0.2) }
            }.frame(width: UIScreen.main.bounds.width, height: 448).clipped()
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.8)]), startPoint: .center, endPoint: .bottom)
            Text(movieName).font(.system(size: 32, weight: .bold)).foregroundColor(.white).padding()
        }
    }
}

struct InfoGridView: View {
    let duration, language, genre, age: String
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), alignment: .top), GridItem(.flexible(), alignment: .top)], spacing: 20) {
            infoItem(title: "Duration", value: duration)
            infoItem(title: "Language", value: language)
            infoItem(title: "Genre", value: genre)
            infoItem(title: "Age", value: age)
        }
    }
    func infoItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
            Text(value).font(.system(size: 14)).foregroundColor(.gray).fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct StorySection: View {
    let story: String
    var body: some View {
        VStack(alignment: .leading) {
            Text("Story").font(.headline).foregroundColor(.white)
            Text(story).foregroundColor(.gray).font(.subheadline)
        }
    }
}

// MARK: - Preview
struct MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailsView(viewModel: MovieDetailsViewModel(movieID: "recfNj1e4waOUJLxd"))
            .preferredColorScheme(.dark)
    }
}


*/



/*
import SwiftUI

// MARK: - Main View
struct MovieDetailsView: View {
    @StateObject var viewModel: MovieDetailsViewModel
    @State private var newReviewText: String = "" // لتخزين نص التعليق الجديد

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.isLoading && viewModel.movie == nil {
                ProgressView().tint(.white).scaleEffect(1.5)
            } else if let movie = viewModel.movie {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // 1. الجزء العلوي (البوستر والاسم)
                        HeaderSection(movieName: movie.title, posterURL: movie.posterURL)

                        VStack(alignment: .leading, spacing: 25) {
                            // 2. شبكة المعلومات
                            InfoGridView(
                                duration: movie.runtime,
                                language: movie.language.joined(separator: ", "),
                                genre: movie.genre.joined(separator: ", "),
                                age: movie.ageRating
                            )
                            
                            // 3. قصة الفيلم
                            StorySection(story: movie.story)
                            
                            // 4. المخرج والممثلين
                            CastSection(director: viewModel.director, actors: viewModel.actors)

                            // 5. خانة إضافة تعليق جديد (POST)
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
                                            viewModel.postReview(text: newReviewText, rate: 5)
                                            newReviewText = ""
                                            hideKeyboard()
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
                            
                            // 6. قسم عرض التعليقات (تعليقات الجميع مع خيار DELETE)
                            RatingsAndReviewsSection(
                                rating: movie.imdbRating ?? 0.0,
                                reviews: viewModel.reviews,
                                onDelete: { reviewID in
                                    viewModel.deleteReview(reviewID: reviewID)
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

// MARK: - Ratings And Reviews Section
struct RatingsAndReviewsSection: View {
    let rating: Double
    let reviews: [Review]
    var onDelete: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rating & Reviews").font(.title2).fontWeight(.bold).foregroundColor(.white)

            HStack(alignment: .bottom, spacing: 8) {
                Text(String(format: "%.1f", rating / 2.0)).font(.system(size: 45, weight: .bold)).foregroundColor(.white)
                Text("out of 5 (IMDb)").font(.subheadline).foregroundColor(.gray).padding(.bottom, 8)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    if reviews.isEmpty {
                        Text("No reviews yet.").foregroundColor(.gray).padding()
                    } else {
                        // عرض جميع التعليقات المسترجعة
                        ForEach(reviews) { review in
                            ReviewCard(review: review, onDelete: {
                                onDelete(review.id)
                            })
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Review Card
struct ReviewCard: View {
    let review: Review
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // صورة يوزر افتراضية ملونة لتمييز المستخدمين
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(review.userName.contains("Guest") ? .blue : .green)
                
                Text(review.userName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.7))
                }
            }
            
            Text(String(repeating: "⭐", count: Int(max(1, review.rating / 2.0)))).font(.caption)
            
            Text(review.text)
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            Text("Public Review")
                .font(.system(size: 10))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding()
        .frame(width: 280, height: 160)
        .background(Color.white.opacity(0.06))
        .cornerRadius(15)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}

// MARK: - HeaderSection
struct HeaderSection: View {
    let movieName: String; let posterURL: URL?
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: posterURL) { p in
                if let img = p.image { img.resizable().aspectRatio(contentMode: .fill) }
                else { Color.gray.opacity(0.2) }
            }.frame(width: UIScreen.main.bounds.width, height: 448).clipped()
            LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
            Text(movieName).font(.system(size: 32, weight: .bold)).foregroundColor(.white).padding()
        }
    }
}

// MARK: - InfoGridView
struct InfoGridView: View {
    let duration, language, genre, age: String
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), alignment: .top), GridItem(.flexible(), alignment: .top)], spacing: 20) {
            infoItem(title: "Duration", value: duration)
            infoItem(title: "Language", value: language)
            infoItem(title: "Genre", value: genre)
            infoItem(title: "Age", value: age)
        }
    }
    func infoItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
            Text(value).font(.system(size: 14)).foregroundColor(.gray).fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - StorySection
struct StorySection: View {
    let story: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Story").font(.headline).foregroundColor(.white)
            Text(story).foregroundColor(.gray).font(.subheadline).lineSpacing(4)
        }
    }
}

// MARK: - CastSection
struct CastSection: View {
    let director: Director?; let actors: [Actor]
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Director").font(.headline).foregroundColor(.white)
            if let d = director { personItem(name: d.name, url: d.imageURL) }
            Text("Stars").font(.headline).foregroundColor(.white)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 25) { ForEach(actors) { a in personItem(name: a.name, url: a.imageURL) } }
            }
        }
    }
    func personItem(name: String, url: URL?) -> some View {
        VStack(spacing: 6) {
            AsyncImage(url: url) { phase in
                if let img = phase.image { img.resizable().aspectRatio(contentMode: .fill) }
                else { Circle().fill(Color.gray.opacity(0.3)).overlay(Image(systemName: "person.fill").foregroundColor(.white.opacity(0.5))) }
            }.frame(width: 60, height: 60).clipShape(Circle())
            Text(name).font(.system(size: 10)).foregroundColor(.white).lineLimit(1).fixedSize(horizontal: true, vertical: false)
        }
    }
}

// MARK: - Helpers
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview
struct MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailsView(viewModel: MovieDetailsViewModel(movieID: "reca1oIIcB4R3HVgw"))
            .preferredColorScheme(.dark)
    }
}

/*
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
                        
                        // 1. الهيدر الذي يحتوي على زر المشاركة الفعّال
                        HeaderSection(movieName: movie.title, posterURL: movie.posterURL)

                        VStack(alignment: .leading, spacing: 25) {
                            InfoGridView(
                                duration: movie.runtime,
                                language: movie.language.joined(separator: ", "),
                                genre: movie.genre.joined(separator: ", "),
                                age: movie.ageRating
                            )
                            
                            StorySection(story: movie.story)
                            
                            CastSection(director: viewModel.director, actors: viewModel.actors)

                            // خانة إضافة تعليق
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
                                            viewModel.postReview(text: newReviewText, rate: 5)
                                            newReviewText = ""
                                            hideKeyboard()
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
                                onDelete: { reviewID in
                                    viewModel.deleteReview(reviewID: reviewID)
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

// MARK: - HeaderSection (الذي يحتوي على منطق المشاركة)
struct HeaderSection: View {
    let movieName: String
    let posterURL: URL?
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: posterURL) { p in
                    if let img = p.image { img.resizable().aspectRatio(contentMode: .fill) }
                    else { Color.gray.opacity(0.2) }
                }
                .frame(width: UIScreen.main.bounds.width, height: 448)
                .clipped()
                
                LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
                
                Text(movieName)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
            }
            
            HStack {
                // زر الرجوع
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .padding(12)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                HStack(spacing: 15) {
                    // زر المشاركة - الآن يستدعي دالة الشير الحقيقية
                    Button(action: { shareMovie() }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    // زر الحفظ
                    Button(action: { print("Movie Saved!") }) {
                        Image(systemName: "bookmark")
                            .font(.title3)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
            }
            .foregroundColor(.white)
            .padding(.top, 60)
            .padding(.horizontal)
        }
    }
    
    // هذه هي الدالة التي تفتح قائمة المشاركة الحقيقية في الآيفون
    func shareMovie() {
        let movieText = "Check out this movie: \(movieName)!"
        
        // إذا كان هناك رابط للفيلم أو بوستر يمكن إضافته هنا
        let activityVC = UIActivityViewController(activityItems: [movieText], applicationActivities: nil)
        
        // الكود التالي لضمان ظهور القائمة فوق الواجهة الحالية
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            
            // في حال كان الجهاز آيباد نحتاج لتحديد مكان ظهور القائمة
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = rootVC.view
                popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}

// MARK: - بقية المكونات (لا تغيير)
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
                    if reviews.isEmpty { Text("No reviews").foregroundColor(.gray) }
                    else { ForEach(reviews) { review in ReviewCard(review: review, onDelete: { onDelete(review.id) }) } }
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
            Spacer()
        }
        .padding().frame(width: 280, height: 160).background(Color.white.opacity(0.06)).cornerRadius(15)
    }
}

struct InfoGridView: View {
    let duration, language, genre, age: String
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            infoItem(title: "Duration", value: duration)
            infoItem(title: "Language", value: language)
            infoItem(title: "Genre", value: genre)
            infoItem(title: "Age", value: age)
        }
    }
    func infoItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
            Text(value).font(.system(size: 14)).foregroundColor(.gray)
        }
    }
}

struct StorySection: View {
    let story: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Story").font(.headline).foregroundColor(.white)
            Text(story).foregroundColor(.gray).font(.subheadline)
        }
    }
}

struct CastSection: View {
    let director: Director?; let actors: [Actor]
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Director").font(.headline).foregroundColor(.white)
            if let d = director { personItem(name: d.name, url: d.imageURL) }
            Text("Stars").font(.headline).foregroundColor(.white)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 25) { ForEach(actors) { a in personItem(name: a.name, url: a.imageURL) } }
            }
        }
    }
    func personItem(name: String, url: URL?) -> some View {
        VStack(spacing: 6) {
            AsyncImage(url: url) { phase in
                if let img = phase.image { img.resizable().aspectRatio(contentMode: .fill) }
                else { Circle().fill(Color.gray.opacity(0.3)) }
            }.frame(width: 60, height: 60).clipShape(Circle())
            Text(name).font(.system(size: 10)).foregroundColor(.white)
        }
    }
}

extension View {
    func hideKeyboard() { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
}
// MARK: - Preview
struct MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailsView(viewModel: MovieDetailsViewModel(movieID: "reca1oIIcB4R3HVgw"))
            .preferredColorScheme(.dark)
    }
}
 */*/
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
                        
                        // 1. الهيدر مع أزرار المشاركة والحفظ والرجوع
                        HeaderSection(movieName: movie.title, posterURL: movie.posterURL)

                        VStack(alignment: .leading, spacing: 25) {
                            // 2. شبكة المعلومات
                            InfoGridView(
                                duration: movie.runtime,
                                language: movie.language.joined(separator: ", "),
                                genre: movie.genre.joined(separator: ", "),
                                age: movie.ageRating
                            )
                            
                            // 3. قصة الفيلم
                            StorySection(story: movie.story)
                            
                            // 4. قسم المخرج والنجوم (تم استعادة الربط الصحيح)
                            CastSection(director: viewModel.director, actors: viewModel.actors)

                            // 5. إضافة تعليق جديد
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
                                            viewModel.postReview(text: newReviewText, rate: 5)
                                            newReviewText = ""
                                            hideKeyboard()
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
                            
                            // 6. قسم التعليقات (تعليقات الجميع مع الحذف)
                            RatingsAndReviewsSection(
                                rating: movie.imdbRating ?? 0.0,
                                reviews: viewModel.reviews,
                                onDelete: { reviewID in
                                    viewModel.deleteReview(reviewID: reviewID)
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

// MARK: - HeaderSection المطور
struct HeaderSection: View {
    let movieName: String
    let posterURL: URL?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: posterURL) { p in
                    if let img = p.image { img.resizable().aspectRatio(contentMode: .fill) }
                    else { Color.gray.opacity(0.2) }
                }
                .frame(width: UIScreen.main.bounds.width, height: 448)
                .clipped()
                
                LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
                
                Text(movieName).font(.system(size: 32, weight: .bold)).foregroundColor(.white).padding()
            }
            
            // صف الأزرار العلوي
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
                    Button(action: { print("Saved") }) {
                        Image(systemName: "bookmark").font(.title3).padding(12)
                        .background(Color.black.opacity(0.5)).clipShape(Circle())
                    }
                }
            }
            .foregroundColor(.white).padding(.top, 60).padding(.horizontal)
        }
    }
    
    func shareMovie() {
        let movieText = "Watch this amazing movie: \(movieName)!"
        let activityVC = UIActivityViewController(activityItems: [movieText], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}

// MARK: - CastSection المحدث (الذي يعرض الممثلين والمخرج)
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
                if let img = phase.image {
                    img.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Circle().fill(Color.gray.opacity(0.3))
                        .overlay(Image(systemName: "person.fill").foregroundColor(.white.opacity(0.5)))
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            
            Text(name).font(.system(size: 10)).foregroundColor(.white).lineLimit(1)
        }
    }
}

// MARK: - Ratings & Reviews Section
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
                    if reviews.isEmpty {
                        Text("No reviews yet.").foregroundColor(.gray).padding()
                    } else {
                        ForEach(reviews) { review in
                            ReviewCard(review: review, onDelete: { onDelete(review.id) })
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Review Card
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
            Spacer()
        }
        .padding().frame(width: 280, height: 160).background(Color.white.opacity(0.06)).cornerRadius(15)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}

// MARK: - InfoGridView & StorySection
struct InfoGridView: View {
    let duration, language, genre, age: String
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            infoItem(title: "Duration", value: duration)
            infoItem(title: "Language", value: language)
            infoItem(title: "Genre", value: genre)
            infoItem(title: "Age", value: age)
        }
    }
    func infoItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
            Text(value).font(.system(size: 14)).foregroundColor(.gray)
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

extension View {
    func hideKeyboard() { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
}
// MARK: - Preview
struct MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailsView(viewModel: MovieDetailsViewModel(movieID: "reca1oIIcB4R3HVgw"))
            .preferredColorScheme(.dark)
    }
}
