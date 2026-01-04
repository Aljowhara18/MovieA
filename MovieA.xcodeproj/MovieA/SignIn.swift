//
//  SignIn.swift
//  MovieA
//
//  Created by Teif May on 12/07/1447 AH.
//

import SwiftUI

struct SignIn: View {
    
    @State private var textInput = ""
    @State private var textInput2 = ""
    @FocusState private var focus: FieldFocus?
    @State private var showMovieCenter = false
    
    private var isEmailValid: Bool {
        Self.isValidEmail(textInput)
    }
    private var isPasswordValid: Bool {
        !textInput2.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    private var isFormValid: Bool {
        isEmailValid && isPasswordValid
    }
    var body: some View {
        NavigationStack {
            ZStack{
                Image("Sign in screen")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                VStack{
                    VStack{
                        Text("Sign in")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
                        Text("You'll find what you're looking for in the ocean of movies")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
                    }
                    .padding(18)
                    VStack(spacing: 8) {
                        Text("Email")
                            .fontWeight(.light)
                            .foregroundStyle(Color.white)
                            .font(.callout)
                            .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
                            .padding(.horizontal, 20)
                        
                        TextField("", text: $textInput, prompt: Text("Enter  your email")
                            .foregroundColor(Color.white))
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .glassInput()
                        .onSubmit {
                            focus = .password
                        }
                        .focused($focus, equals: .emailAddress)
                        if !textInput.isEmpty && !isEmailValid {
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
                            .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
                            .padding(.horizontal, 17)
                        
                        SecureField("", text: $textInput2, prompt: Text("Enter your password")
                            .foregroundColor(Color.white))
                        .glassInput()
                        .focused($focus, equals: .password)
                    }
                    .onAppear {
                        focus = .emailAddress
                    }
                    
                    Button(action: {
                        guard isFormValid else { return }
                        showMovieCenter = true
                    }) {
                        VStack{
                            Text("Sign In")
                                .foregroundColor(Color.black)
                                .fontWeight(.semibold)
                                .font(.title2)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(
                            Color(isFormValid ? "SignInYellow" : "SignInGrey")
                        )
                        .cornerRadius(8)
                        .padding(.top,20)
                    }
                    .disabled(!isFormValid)
                    .animation(.easeInOut(duration: 0.2), value: isFormValid)
                }

            }
        }
    }
    private static func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let pattern = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }
}

enum FieldFocus: Hashable {
    case emailAddress
    case password
}

struct TextInputStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.white)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0), lineWidth: 2))
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
    SignIn()
}
