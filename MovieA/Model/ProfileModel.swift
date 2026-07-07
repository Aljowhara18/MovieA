import SwiftUI
import Combine

// MARK: - ProfileModel
final class ProfileModel: ObservableObject {
    static let shared = ProfileModel()

    @Published var firstName: String
    @Published var lastName: String
    @Published var email: String
    @Published var avatar: UIImage?

    private let firstNameKey = "com.movieA.profile.firstName"
    private let lastNameKey = "com.movieA.profile.lastName"
    private let avatarKey = "com.movieA.profile.avatarData"

    private init() {
        let defaults = UserDefaults.standard
        let loginName = CurrentUserStore.shared.name
        let nameParts = loginName.split(separator: " ", maxSplits: 1).map(String.init)

        self.firstName = defaults.string(forKey: firstNameKey) ?? (nameParts.first ?? loginName)
        self.lastName = defaults.string(forKey: lastNameKey) ?? (nameParts.count > 1 ? nameParts[1] : "")
        self.email = CurrentUserStore.shared.email

        if let data = defaults.data(forKey: avatarKey), let image = UIImage(data: data) {
            self.avatar = image
        } else {
            self.avatar = nil
        }
    }

    func update(firstName: String, lastName: String, avatar: UIImage?) {
        self.firstName = firstName
        self.lastName = lastName
        if let avatar { self.avatar = avatar }

        let defaults = UserDefaults.standard
        defaults.set(firstName, forKey: firstNameKey)
        defaults.set(lastName, forKey: lastNameKey)
        if let avatar, let data = avatar.jpegData(compressionQuality: 0.8) {
            defaults.set(data, forKey: avatarKey)
        }
    }

    func signOut(completion: (() -> Void)? = nil) {
        CurrentUserStore.shared.signOut()
        completion?()
    }
}
