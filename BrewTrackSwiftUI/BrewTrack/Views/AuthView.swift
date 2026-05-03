import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Brew & Track")
                            .font(AppFont.bold(44))
                            .foregroundStyle(AppTheme.textDark)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                        Text("Sign in to keep your cafe inventory synced.")
                            .font(AppFont.regular(24))
                            .foregroundStyle(AppTheme.textLight)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 10)

                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email")
                                .fieldLabel()
                            TextField("manager@cafe.com", text: $authViewModel.email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .textFieldStyle(InventoryTextFieldStyle())
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .fieldLabel()
                            SecureField("At least 6 characters", text: $authViewModel.password)
                                .textFieldStyle(InventoryTextFieldStyle())
                        }

                        if let errorMessage = authViewModel.errorMessage {
                            Text(errorMessage)
                                .errorText()
                                .padding(.horizontal, 6)
                        }

                        VStack(spacing: 12) {
                            Button {
                                authViewModel.signIn()
                            } label: {
                                authButtonLabel("Sign In", systemImage: "person.crop.circle.fill")
                            }
                            .buttonStyle(PrimaryRoundedButtonStyle())
                            .disabled(authViewModel.isLoading)

                            Button {
                                authViewModel.createAccount()
                            } label: {
                                authButtonLabel("Create Account", systemImage: "person.badge.plus")
                            }
                            .buttonStyle(DangerRoundedButtonStyle(color: AppTheme.teacupDark))
                            .disabled(authViewModel.isLoading)
                        }

                        if authViewModel.isLoading {
                            HStack(spacing: 10) {
                                ProgressView()
                                    .tint(AppTheme.honey)
                                Text("Checking account...")
                                    .font(AppFont.bold(22))
                                    .foregroundStyle(AppTheme.textLight)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 26)
                    .background(CardBackground(cornerRadius: 22, border: AppTheme.honeyLight))
                }
                .frame(maxWidth: 620)
                .padding(.horizontal, 14)
                .padding(.vertical, 44)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func authButtonLabel(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .frame(maxWidth: .infinity)
    }
}
