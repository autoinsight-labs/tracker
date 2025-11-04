//
//  SignInView.swift
//  MottuOperator
//
//  Created by Gui Maggiorini on 03/11/25.
//

import SwiftUI

struct SignInView: View {
    @Environment(AuthService.self) private var authService: AuthService
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorEmail: String? = nil
    @State private var errorPassword: String? = nil
    @State private var authError: String? = nil
    @State private var isLoading: Bool = false
    @State private var isPasswordVisible: Bool = false
    @FocusState private var focusedField: Field?
    
    // if I put this placeholder directly into TextField, it will turn the placeholder into a "mailto" link. this is an easy workaround that i've found.
    private var emailPlaceholder: String = "name@example.com"
    
    enum Field {
        case email
        case password
    }
    
    var isFormValid: Bool {
        AuthValidation.isFormValid(email: email, password: password)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Welcome back")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Sign in to your account")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.bottom, 8)
                
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 8) {
                            TextField(emailPlaceholder, text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .textContentType(.emailAddress)
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .password
                                }
                                .onChange(of: email) {
                                    errorEmail = nil
                                    authError = nil
                                }
                        }
                        .padding(16)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 48, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 48, style: .continuous)
                                .stroke(AuthValidation.borderColor(for: errorEmail), lineWidth: 1)
                        }
                        
                        if let errorEmail {
                            Label(errorEmail, systemImage: "exclamationmark.circle.fill")
                                .foregroundStyle(.red)
                                .font(.footnote)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                .accessibilityLabel("Email error: \(errorEmail)")
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 8) {
                            Group {
                                if isPasswordVisible {
                                    TextField("At least 6 characters", text: $password)
                                        .textContentType(.password)
                                        .onChange(of: password) {
                                            errorPassword = nil
                                            authError = nil
                                        }
                                } else {
                                    SecureField("At least 6 characters", text: $password)
                                        .textContentType(.password)
                                        .onChange(of: password) {
                                            errorPassword = nil
                                            authError = nil
                                        }
                                }
                            }
                            .focused($focusedField, equals: .password)
                            .submitLabel(.go)
                            .onSubmit {
                                if isFormValid && !isLoading {
                                    handleSignIn()
                                }
                            }
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    isPasswordVisible.toggle()
                                }
                            } label: {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundStyle(.separator)
                                    .contentShape(Rectangle())
                                    .accessibilityLabel(isPasswordVisible ? "Hide password" : "Show password")
                            }
                        }
                        .padding(16)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 48, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 48, style: .continuous)
                                .stroke(AuthValidation.borderColor(for: errorPassword), lineWidth: 1)
                        }
                        
                        if let errorPassword {
                            Label(errorPassword, systemImage: "exclamationmark.circle.fill")
                                .foregroundStyle(.red)
                                .font(.footnote)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                .accessibilityLabel("Password error: \(errorPassword)")
                        }
                    }
                }
                .padding(.top, 4)
                
                if let authError {
                    Label(authError, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .accessibilityLabel("Authentication error: \(authError)")
                }
                
                Button(action: handleSignIn) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        Text("Join")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(7)
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .disabled(isLoading)
                .animation(.easeInOut(duration: 0.2), value: isFormValid)
                .accessibilityHint("Sign in with email and password")
                
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundStyle(.secondary)
                    NavigationLink("Sign up", destination: SignUpView())
                        .fontWeight(.semibold)
                }
                .font(.footnote)
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func validateEmail() {
        authError = nil
        errorEmail = AuthValidation.validateEmail(email)
    }

    private func validatePassword() {
        authError = nil
        errorPassword = AuthValidation.validatePassword(password)
    }
    
    private func handleSignIn() {
        authError = nil
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let emailError = AuthValidation.validateEmail(trimmedEmail) {
            errorEmail = emailError
            focusedField = .email
            return
        }
        
        if let passwordError = AuthValidation.validatePassword(password) {
            errorPassword = passwordError
            focusedField = .password
            return
        }
        
        isLoading = true
        authService.signIn(email: trimmedEmail, password: password) { error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    authError = AuthValidation.mapAuthError(error)
                } else {
                    errorEmail = nil
                    errorPassword = nil
                    authError = nil
                    focusedField = nil
                }
            }
        }
    }
}

#Preview {
    SignInView()
        .environment(AuthService())
}
