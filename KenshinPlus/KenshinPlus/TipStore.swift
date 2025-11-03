//
//  TipStore.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/10/23.
//

import Foundation
import StoreKit

@MainActor
final class TipStore: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var purchaseMessage: String?
    
    // Keep these in one place
    static let productIDs: Set<String> = [
        "tip.coffee", "tip.sandwich", "tip.dinner"
    ]
    
    func loadProducts() async {
        guard products.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let fetched = try await Product.products(for: Array(Self.productIDs))
            // Sort to your liking (by price ascending here)
            self.products = fetched.sorted { $0.price < $1.price }
        } catch {
            purchaseMessage = "Couldn't load tips. Please try again later."
            print("Product Load Error: ", error)
        }
    }
    
    func buy(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verificationResult):
                // Verify Transaction
                if case .verified(let transaction) = verificationResult {
                    await transaction.finish()
                    purchaseMessage = "Thanks so much for the tip! 🎉"
                } else {
                    purchaseMessage = "Purchase couldn't be verified."
                }
            case .userCancelled:
                break
            case .pending:
                purchaseMessage = "Your purchase message is pending."
            @unknown default:
                purchaseMessage = "Something went wrong."
            }
        } catch {
            purchaseMessage = "Purchase failed. Please try again."
            print("Purchase error: ", error)
        }
    }
}
