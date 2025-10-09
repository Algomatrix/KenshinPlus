//
//  AppleSignIn.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/10/09.
//

import SwiftUI
import AuthenticationServices
import Security

// MARK: - Simple Keychain wrapper
enum Keychain {
    @discardableResult
    static func set(_ data: Data, for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary) // delete if exists
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    static func get(_ key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        return item as? Data
    }

    @discardableResult
    static func delete(_ key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    @discardableResult
    static func setString(_ string: String, for key: String) -> Bool {
        set(Data(string.utf8), for: key)
    }

    static func getString(_ key: String) -> String? {
        guard let data = get(key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

// MARK: - Account model
struct AppleAccount: Codable, Equatable {
    var userId: String
    var givenName: String?
    var familyName: String?
    var email: String?

    var displayName: String {
        if let g = givenName, let f = familyName, !(g.isEmpty && f.isEmpty) { return "\(g) \(f)" }
        return email ?? "Apple User"
    }
}

// MARK: - Apple Auth ViewModel
final class AppleAuth: ObservableObject {
    @Published private(set) var account: AppleAccount? = nil
    @Published private(set) var credentialState: ASAuthorizationAppleIDProvider.CredentialState = .revoked
    @Published var errorMessage: String? = nil

    private let key = "appleAccount.json"
    private let provider = ASAuthorizationAppleIDProvider()

    var isSignedIn: Bool { account != nil && credentialState == .authorized }

    init() {
        loadFromKeychain()
        refreshCredentialState()
    }

    // Handle Sign in with Apple completion
    func handle(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .failure(let error):
            DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
        case .success(let authorization):
            if let appleIDCred = authorization.credential as? ASAuthorizationAppleIDCredential {
                let newAccount = AppleAccount(
                    userId: appleIDCred.user,
                    givenName: appleIDCred.fullName?.givenName,
                    familyName: appleIDCred.fullName?.familyName,
                    email: appleIDCred.email
                )
                save(account: newAccount)
                refreshCredentialState()
            } else if let passwordCred = authorization.credential as? ASPasswordCredential {
                // Optional: handle iCloud Keychain password credentials
                print("Signed in with stored password for: \(passwordCred.user)")
            }
        }
    }

    func signOut() {
        account = nil
        credentialState = .revoked
        Keychain.delete(key)
    }

    func refreshCredentialState() {
        guard let acct = account else { credentialState = .revoked; return }
        provider.getCredentialState(forUserID: acct.userId) { state, _ in
            DispatchQueue.main.async {
                self.credentialState = state
                if state != .authorized {
                    // If revoked or not found, clear local session
                    self.account = nil
                    Keychain.delete(self.key)
                }
            }
        }
    }

    // MARK: Persistence
    private func loadFromKeychain() {
        guard let data = Keychain.get(key) else { return }
        if let acct = try? JSONDecoder().decode(AppleAccount.self, from: data) {
            account = acct
        }
    }

    private func save(account: AppleAccount) {
        self.account = account
        if let data = try? JSONEncoder().encode(account) {
            _ = Keychain.set(data, for: key)
        }
    }
}

// MARK: - Sign in With Apple Button (SwiftUI helper)
struct AppleSignInButtonView: View {
    @ObservedObject var auth: AppleAuth
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        SignInWithAppleButton(.signIn, onRequest: { request in
            request.requestedScopes = [.fullName, .email]
        }, onCompletion: { result in
            auth.handle(result)
        })
        .signInWithAppleButtonStyle(scheme == .dark ? .white : .black)
        .frame(height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityIdentifier("SignInWithAppleButton")
    }
}

#if DEBUG
extension AppleAuth {
  static var previewSignedOut: AppleAuth { AppleAuth() }
  static var previewSignedIn: AppleAuth {
    let a = AppleAuth()
    a.injectPreview(account: .init(userId: "demo", givenName: "Kenshin", familyName: "User", email: "kenshin@example.com"))
    return a
  }
  func injectPreview(account: AppleAccount) {
    self.account = account
    self.credentialState = .authorized
  }
}
#endif
