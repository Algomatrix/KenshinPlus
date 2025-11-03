//
//  TipJarSheet.swift
//  KenshinPlus
//
//  Created by Shubham Shetkar on 2025/10/23.
//

import SwiftUI
import StoreKit

struct TipJarSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = TipStore()

    var body: some View {
        NavigationStack {
            Group {
                if store.isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if store.products.isEmpty {
                    ContentUnavailableView("Nothing to show", systemImage: "cart.badge.questionmark", description: Text("Please try again later."))
                } else {
                    List {
                        Section(footer: Text("Tips are completely optional and non-refundable. Thanks for supporting!")) {
                            ForEach(store.products, id: \.id) { product in
                                TipRow(product: product) {
                                    Task { await store.buy(product) }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Tip the Developer")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                await store.loadProducts()
            }
            .alert("Thank you!", isPresented: .constant(store.purchaseMessage != nil), actions: {
                Button("OK") {
                    store.purchaseMessage = nil
                }
            }, message: {
                Text(store.purchaseMessage ?? "")
            })
        }
    }
}

struct TipRow: View {
    let product: Product
    let action: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: iconName(for: product.id))
                .font(.title2)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(label(for: product.id, fallback: product.displayName))
                    .font(.headline)
                Text(product.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            Button(product.displayPrice, action: action)
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
        }
        .padding(.vertical, 6)
    }
    
    private func iconName(for id: String) -> String {
        switch id {
        case "tip.coffee": return "cup.and.saucer.fill"
        case "tip.sandwich": return "takeoutbag.and.cup.and.straw.fill"
        case "tip.dinner": return "frying.pan"
        default: return "gift.fill"
        }
    }
    
    private func label(for id: String, fallback: String) -> String {
        switch id {
        case "tip.coffee": return "Buy me Coffee"
        case "tip.sandwich": return "Buy me Sandwich"
        case "tip.dinner": return "Buy me Dinner"
        default: return fallback
        }
    }
}

#Preview {
    TipJarSheet()
}
