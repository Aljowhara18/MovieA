//
//  SignIn.swift
//  MovieA
//
//  Created by Teif May on 12/07/1447 AH.
//
import SwiftUI

// MARK: - SignIn

struct SignIn: View {

    // MARK: State
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focus: FieldFocus?
    @State private var showMoviesCenter = false

    // MARK: Validation
    private var isEmailValid: Bool {
        Self.isValidEmail(email)
    }
    private var isPasswordValid: Bool {
        !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    private var isFormValid: Bool {
        isEmailValid && isPasswordValid
    }

    // MARK: Body
    var body: some View {
        NavigationStack {
            ZStack {
                background

                VStack {
                    HeaderView()

                    CredentialsForm(
                        email: $email,
                        password: $password,
                        isEmailValid: isEmailValid,
                        focus: _focus
                    )

                    SignInButton(
                        enabled: isFormValid,
                        action: {
                            guard isFormValid else { return }
                            showMoviesCenter = true
                        }
                    )
                    .padding(.top, 20)
                }
            }
            .navigationDestination(isPresented: $showMoviesCenter) {
                // تأكدي أن MoviesCenter لا يحتوي على NavigationStack داخله
                MoviesCenter()
                    .preferredColorScheme(.dark)
            }
        }
        // هذا السطر هو الأهم لحل مشكلة انقسام الشاشة في iPhone Pro Max
        .navigationViewStyle(.stack)
    }

    // MARK: - Background
    private var background: some View {
        Image("Sign in screen")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }

    // MARK: - Helpers
    private static func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let pattern = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return trimmed.range(of: pattern, options: .regularExpression) != nil
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
            // Email
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

            // Password
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
            // تأخير بسيط للفوكس لضمان استقرار الواجهة
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

// MARK: - Styling

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

// MARK: - Preview

#Preview {
    SignIn()
}
