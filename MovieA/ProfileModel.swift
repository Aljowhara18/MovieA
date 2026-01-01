import SwiftUI
import Combine

final class ProfileModel: ObservableObject {
    @Published var firstName: String
    @Published var lastName: String
    @Published var email: String
    @Published var avatar: UIImage?

    init(
        firstName: String = "Sarah",
        lastName: String = "Abdullah",
        email: String = "Xxxx234@gmail.com",
        avatar: UIImage? = nil
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.avatar = avatar
    }

    func update(firstName: String, lastName: String, avatar: UIImage?) {
        self.firstName = firstName
        self.lastName = lastName
        if let avatar { self.avatar = avatar }
    }

    func signOut(completion: (() -> Void)? = nil) {
        completion?()
    }
}
