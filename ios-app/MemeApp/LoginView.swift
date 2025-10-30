//
//  LoginView.swift
//  Login and signup screen
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var firebaseService: FirebaseService

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()

                // Logo
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 80))
                    .foregroundColor(.purple)

                Text("Meme App")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Access your memes anywhere")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Spacer()

                // Email field
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disabled(isLoading)

                // Password field
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isLoading)

                // Confirm password (only for signup)
                if isSignUp {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(isLoading)
                }

                // Error message
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

                // Submit button
                Button(action: handleSubmit) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(isSignUp ? "Create Account" : "Login")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading)

                // Toggle between login/signup
                Button(action: {
                    isSignUp.toggle()
                    errorMessage = nil
                }) {
                    Text(isSignUp ? "Already have an account? Login" : "Don't have an account? Sign Up")
                        .foregroundColor(.purple)
                        .font(.footnote)
                }
                .disabled(isLoading)

                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }

    private func handleSubmit() {
        errorMessage = nil

        // Validation
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }

        if isSignUp && password != confirmPassword {
            errorMessage = "Passwords do not match"
            return
        }

        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            return
        }

        isLoading = true

        Task {
            do {
                if isSignUp {
                    try await firebaseService.signUp(email: email, password: password)
                } else {
                    try await firebaseService.signIn(email: email, password: password)
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(FirebaseService.shared)
}
