import SwiftUI

// MARK: - SignIn
struct SignIn: View {

    @Binding var isLoggedIn: Bool

    @State private var vm = SignInViewModel()
    @FocusState private var focus: FieldFocus?

    var body: some View {
        ZStack {
            background

            VStack {
                HeaderView()

                CredentialsForm(
                    email: $vm.email,
                    password: $vm.password,
                    isEmailValid: vm.isEmailValid,
                    focus: _focus
                )

                if let authError = vm.authError {
                    Text(authError)
                        .font(.footnote)
                        .foregroundColor(.red.opacity(0.9))
                        .padding(.top, 4)
                }

                if vm.isAuthenticating {
                    ProgressView()
                        .tint(.white)
                        .padding(.top, 8)
                } else {
                    SignInButton(
                        enabled: vm.isFormValid,
                        action: { Task { await vm.signIn() } }
                    )
                    .padding(.top, 20)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: vm.isAuthenticated) { _, authenticated in
            guard authenticated else { return }
            withAnimation(.spring()) {
                isLoggedIn = true
            }
        }
    }

    private var background: some View {
        Image("Sign in screen")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}

// MARK: - Focus
enum FieldFocus: Hashable {
    case emailAddress
    case password
}

// MARK: - Subviews
private struct HeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Sign in")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)

            Text("You'll find what you're looking for in the ocean of movies")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
    }
}

private struct CredentialsForm: View {
    @Binding var email: String
    @Binding var password: String
    let isEmailValid: Bool
    @FocusState var focus: FieldFocus?

    var body: some View {
        VStack(spacing: 8) {
            Text("Email")
                .fontWeight(.light)
                .foregroundStyle(Color.white)
                .font(.callout)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)

            TextField("", text: $email, prompt: Text("Enter your email").foregroundColor(Color.white))
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .glassInput()
                .onSubmit { focus = .password }
                .focused($focus, equals: .emailAddress)

            if !email.isEmpty && !isEmailValid {
                Text("Please enter a valid email address.")
                    .font(.footnote)
                    .foregroundColor(.red.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 22)
            }

            Text("Password")
                .fontWeight(.light)
                .foregroundStyle(Color.white)
                .font(.callout)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 17)

            SecureField("", text: $password, prompt: Text("Enter your password").foregroundColor(Color.white))
                .glassInput()
                .focused($focus, equals: .password)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focus = .emailAddress
            }
        }
    }
}

private struct SignInButton: View {
    let enabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Text("Sign In")
                    .foregroundColor(Color.black)
                    .fontWeight(.semibold)
                    .font(.title2)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(Color(enabled ? "SignInYellow" : "SignInGrey"))
            .cornerRadius(8)
        }
        .disabled(!enabled)
        .animation(.easeInOut(duration: 0.2), value: enabled)
        .padding(.horizontal, 18)
    }
}

struct TextInputStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.white)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 11)
    }
}

extension View {
    func glassInput() -> some View {
        self.modifier(TextInputStyle())
    }
}

#Preview {
    SignIn(isLoggedIn: .constant(false))
}
