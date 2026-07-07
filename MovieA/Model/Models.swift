import Foundation
import Combine

// MARK: - Users
struct UsersResponse: Codable {
    let records: [UserRecord]
}

struct UserRecord: Codable, Identifiable {
    let id: String
    let createdTime: String?
    let fields: UserFields
}

struct UserFields: Codable {
    let name: String
    let email: String
    let password: String?
}

// MARK: - Movies
struct MoviesResponse: Codable {
    let records: [MovieRecord]
}

struct MovieRecord: Codable, Identifiable {
    let id: String
    let createdTime: String
    let fields: MovieFields
}

struct MovieFields: Codable {
    let name: String?
    let poster: String?
    let story: String?
    let runtime: String?
    let genre: [String]?
    let rating: String?
    let IMDb_rating: Double?
    let language: [String]?
}

struct Movie: Identifiable, Hashable {
    enum Category: Hashable {
        case drama, comedy, other
    }

    let id: String
    let createdTime: String
    let title: String
    let posterURL: URL?
    let story: String
    let runtime: String
    let genre: [String]
    let ageRating: String
    let imdbRating: Double?
    let language: [String]
    let ratingValue: Double
    let subtitle: String

    var category: Category {
        let all = genre.joined(separator: " ").lowercased()
        if all.contains("drama") { return .drama }
        if all.contains("comedy") { return .comedy }
        return .other
    }

    init(from record: MovieRecord) {
        self.id = record.id
        self.createdTime = record.createdTime
        let f = record.fields
        self.title = f.name ?? "Unknown"
        self.posterURL = URL(string: f.poster ?? "")
        self.story = f.story ?? ""
        self.runtime = f.runtime ?? ""
        self.genre = f.genre ?? []
        self.ageRating = f.rating ?? ""
        self.imdbRating = f.IMDb_rating
        self.language = f.language ?? []
        let imdb = f.IMDb_rating ?? 0
        self.ratingValue = max(0, min(5, imdb / 2.0))
        let gText = self.genre.first ?? "Movie"
        self.subtitle = self.runtime.isEmpty ? gText : "\(gText), \(self.runtime)"
    }
}

// MARK: - Actors & Junction
struct ActorsResponse: Codable {
    let records: [ActorRecord]
}

struct ActorRecord: Codable, Identifiable {
    let id: String
    let fields: ActorFields
}

struct ActorFields: Codable {
    let name: String?
    let image: String?
}

struct MovieActorsResponse: Codable {
    let records: [MovieActorRecord]
}

struct MovieActorRecord: Codable {
    let fields: MovieActorFields
}

struct MovieActorFields: Codable {
    let actor_id: [String]?
}

struct Actor: Identifiable {
    let id: String
    let name: String
    let imageURL: URL?

    init(from record: ActorRecord) {
        self.id = record.id
        self.name = record.fields.name ?? "Unknown"
        self.imageURL = URL(string: record.fields.image ?? "")
    }
}

// MARK: - Directors & Junction
struct DirectorsResponse: Codable {
    let records: [DirectorRecord]
}

struct DirectorRecord: Codable {
    let id: String
    let fields: DirectorFields
}

struct DirectorFields: Codable {
    let name: String?
    let image: String?
}

struct MovieDirectorsResponse: Codable {
    let records: [MovieDirectorRecord]
}

struct MovieDirectorRecord: Codable {
    let fields: MovieDirectorFields
}

struct MovieDirectorFields: Codable {
    let director_id: [String]?
}

struct Director: Identifiable {
    let id: String
    let name: String
    let imageURL: URL?

    init(from record: DirectorRecord) {
        self.id = record.id
        self.name = record.fields.name ?? "Unknown"
        self.imageURL = URL(string: record.fields.image ?? "")
    }
}

// MARK: - Reviews
struct ReviewsResponse: Codable {
    let records: [ReviewRecord]
}

struct ReviewRecord: Codable, Identifiable {
    let id: String
    let createdTime: String?
    let fields: ReviewFields
}

struct ReviewFields: Codable {
    let rate: Double?
    let review_text: String?
    let movie_id: String?
    let user_id: String?
}

struct Review: Identifiable {
    let id: String
    let rating: Double
    let text: String
    let movieID: String
    let userName: String
    let createdTime: String

    init(from record: ReviewRecord) {
        self.id = record.id
        self.rating = record.fields.rate ?? 0.0
        self.text = record.fields.review_text ?? ""
        self.movieID = record.fields.movie_id ?? ""
        self.userName = record.fields.user_id ?? "Guest User"
        self.createdTime = record.createdTime ?? ""
    }
}

// MARK: - Saved Movies
struct SavedMovie: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let posterURLString: String?
    let subtitle: String
    let ratingValue: Double

    var posterURL: URL? {
        guard let posterURLString else { return nil }
        return URL(string: posterURLString)
    }

    init(from movie: Movie) {
        self.id = movie.id
        self.title = movie.title
        self.posterURLString = movie.posterURL?.absoluteString
        self.subtitle = movie.subtitle
        self.ratingValue = movie.ratingValue
    }
}

final class SavedMoviesStore: ObservableObject {
    static let shared = SavedMoviesStore()

    @Published private(set) var savedMovies: [SavedMovie] = []

    private let defaultsKey = "com.movieA.savedMovies"

    private init() {
        load()
    }

    func isSaved(id: String) -> Bool {
        savedMovies.contains { $0.id == id }
    }

    func toggle(movie: Movie) {
        if isSaved(id: movie.id) {
            savedMovies.removeAll { $0.id == movie.id }
        } else {
            savedMovies.append(SavedMovie(from: movie))
        }
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(savedMovies) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let decoded = try? JSONDecoder().decode([SavedMovie].self, from: data) else { return }
        savedMovies = decoded
    }
}

// MARK: - Current User
final class CurrentUserStore: ObservableObject {
    static let shared = CurrentUserStore()

    @Published private(set) var userID: String?
    @Published private(set) var name: String = "Guest"
    @Published private(set) var email: String = ""

    private let idKey = "com.movieA.currentUser.id"
    private let nameKey = "com.movieA.currentUser.name"
    private let emailKey = "com.movieA.currentUser.email"

    private init() {
        let defaults = UserDefaults.standard
        userID = defaults.string(forKey: idKey)
        name = defaults.string(forKey: nameKey) ?? "Guest"
        email = defaults.string(forKey: emailKey) ?? ""
    }

    func signIn(id: String, name: String, email: String) {
        self.userID = id
        self.name = name
        self.email = email

        let defaults = UserDefaults.standard
        defaults.set(id, forKey: idKey)
        defaults.set(name, forKey: nameKey)
        defaults.set(email, forKey: emailKey)
    }

    func signOut() {
        userID = nil
        name = "Guest"
        email = ""

        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: idKey)
        defaults.removeObject(forKey: nameKey)
        defaults.removeObject(forKey: emailKey)
    }
}
