//
//  SignUpView.swift
//  MottuOperator
//
//  Created by Gui Maggiorini on 03/11/25.
//

import SwiftUI

struct SignUpView: View {
    @Environment(AuthService.self) private var authService: AuthService
    
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var errorFullName: String? = nil
    @State private var errorEmail: String? = nil
    @State private var errorPassword: String? = nil
    @State private var errorConfirmPassword: String? = nil
    @State private var authError: String? = nil
    
    @State private var isLoading: Bool = false
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    
    @FocusState private var focusedField: Field?
    
    // if I put this placeholder directly into TextField, it will turn the placeholder into a "mailto" link. this is an easy workaround that i've found.
    private var emailPlaceholder: String = "name@example.com"
    
    enum Field {
        case fullName
        case email
        case password
        case confirmPassword
    }
    
    var isFormValid: Bool {
        AuthValidation.isFormValid(fullName: fullName, email: email, password: password, confirmPassword: confirmPassword)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Get started")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Let's set up your account")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.bottom, 8)
                
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Full name")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        TextField("Your full name", text: $fullName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .fullName)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .email
                            }
                            .onChange(of: fullName) {
                                errorFullName = nil
                                authError = nil
                            }
                            .padding(16)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 48, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 48, style: .continuous)
                                    .stroke(AuthValidation.borderColor(for: errorFullName), lineWidth: 1)
                            }

                        if let errorFullName {
                            Label(errorFullName, systemImage: "exclamationmark.circle.fill")
                                .foregroundStyle(.red)
                                .font(.footnote)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                .accessibilityLabel("Name error: \(errorFullName)")
                        }
                    }

                    
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
                                        .textContentType(.newPassword)
                                        .onChange(of: password) {
                                            errorPassword = nil
                                            authError = nil
                                            if !confirmPassword.isEmpty {
                                                errorConfirmPassword = nil
                                            }
                                        }
                                } else {
                                    SecureField("At least 6 characters", text: $password)
                                        .textContentType(.newPassword)
                                        .onChange(of: password) {
                                            errorPassword = nil
                                            authError = nil
                                            if !confirmPassword.isEmpty {
                                                errorConfirmPassword = nil
                                            }
                                        }
                                }
                            }
                            .focused($focusedField, equals: .password)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .confirmPassword
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
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Confirm password")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 8) {
                            Group {
                                if isConfirmPasswordVisible {
                                    TextField("Repeat your password", text: $confirmPassword)
                                        .textContentType(.newPassword)
                                        .onChange(of: confirmPassword) {
                                            errorConfirmPassword = nil
                                            authError = nil
                                        }
                                } else {
                                    SecureField("Repeat your password", text: $confirmPassword)
                                        .textContentType(.newPassword)
                                        .onChange(of: confirmPassword) {
                                            errorConfirmPassword = nil
                                            authError = nil
                                        }
                                }
                            }
                            .focused($focusedField, equals: .confirmPassword)
                            .submitLabel(.go)
                            .onSubmit {
                                if isFormValid && !isLoading {
                                    handleSignup()
                                }
                            }
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    isConfirmPasswordVisible.toggle()
                                }
                            } label: {
                                Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundStyle(.separator)
                                    .contentShape(Rectangle())
                                    .accessibilityLabel(isConfirmPasswordVisible ? "Hide confirm password" : "Show confirm password")
                            }
                        }
                        .padding(16)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 48, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 48, style: .continuous)
                                .stroke(AuthValidation.borderColor(for: errorConfirmPassword), lineWidth: 1)
                        }
                        
                        if let errorConfirmPassword {
                            Label(errorConfirmPassword, systemImage: "exclamationmark.circle.fill")
                                .foregroundStyle(.red)
                                .font(.footnote)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                .accessibilityLabel("Confirm password error: \(errorConfirmPassword)")
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
                
                Button(action: handleSignup) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        Text("Create account")
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
                .accessibilityHint("Sign up with email and password")
                
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .foregroundStyle(.secondary)
                    NavigationLink("Sign in", destination: SignInView())
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
    
    private func handleSignup() {
        authError = nil
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        errorFullName = AuthValidation.validateFullName(fullName)
        
        if errorFullName != nil {
            focusedField = .fullName
            return
        }
        
        if trimmedEmail.isEmpty {
            errorEmail = "Email is required."
            focusedField = .email
            return
        }
        if !trimmedEmail.contains("@") {
            errorEmail = "Use a valid email."
            focusedField = .email
            return
        }
        
        if password.isEmpty {
            errorPassword = "Password is required."
            focusedField = .password
            return
        }
        if password.count < 6 {
            errorPassword = "Password must have at least 6 characters."
            focusedField = .password
            return
        }
        
        if confirmPassword.isEmpty {
            errorConfirmPassword = "Please confirm your password."
            focusedField = .confirmPassword
            return
        }
        if confirmPassword != password {
            errorConfirmPassword = "Passwords do not match."
            focusedField = .confirmPassword
            return
        }
        
        isLoading = true
        authService.signUp(fullName: fullName, email: trimmedEmail, password: password) { error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    authError = AuthValidation.mapAuthError(error)
                } else {
                    errorEmail = nil
                    errorPassword = nil
                    errorConfirmPassword = nil
                    authError = nil
                    focusedField = nil
                }
            }
        }
    }
}

#Preview {
    SignUpView()
        .environment(AuthService())
}
