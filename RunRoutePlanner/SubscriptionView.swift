import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @StateObject private var subscriptionManager = SubscriptionManager()
    @Binding var isPresented: Bool
    @State private var isPurchasing = false

    private let horizontalPadding = AppConstants.UI.horizontalPadding

    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 30) {
                closeButton
                Spacer()
                headerSection
                featuresList
                Spacer()
                pricingSection
            }
        }
        .alert("Error", isPresented: errorBinding) {
            Button("OK") {
                subscriptionManager.purchaseError = nil
            }
        } message: {
            Text(subscriptionManager.purchaseError ?? "")
        }
    }
    
    // MARK: - View Components
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var closeButton: some View {
        HStack {
            Spacer()
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.white)
            
            Text("Run Route Planner")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Premium")
                .font(.title2)
                .foregroundColor(.white.opacity(0.9))
        }
    }
    
    private var featuresList: some View {
        VStack(alignment: .leading, spacing: 20) {
            FeatureRow(icon: "map.fill", text: "Dynamic route planning while running")
            FeatureRow(icon: "location.fill", text: "Real-time GPS tracking")
            FeatureRow(icon: "infinity", text: "Unlimited routes and distances")
            FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Detailed run statistics")
            FeatureRow(icon: "icloud.fill", text: "Cloud sync across devices")
        }
        .padding(.horizontal, horizontalPadding)
    }
    
    private var pricingSection: some View {
        VStack(spacing: 20) {
            if let product = subscriptionManager.products.first {
                productPricing(product)
                subscribeButton
            } else {
                loadingIndicator
            }
            
            restoreButton
            termsText
        }
        .padding(.bottom, 30)
    }
    
    private func productPricing(_ product: Product) -> some View {
        VStack(spacing: 8) {
            Text(product.displayPrice)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            Text("per month")
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
        }
    }
    
    private var subscribeButton: some View {
        Button(action: handlePurchase) {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                } else {
                    Text("Start Free Trial")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .foregroundColor(.blue)
            .cornerRadius(15)
        }
        .disabled(isPurchasing)
        .padding(.horizontal, horizontalPadding)
    }
    
    private var loadingIndicator: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
    }
    
    private var restoreButton: some View {
        Button("Restore Purchases", action: handleRestore)
            .font(.footnote)
            .foregroundColor(.white.opacity(0.8))
    }
    
    private var termsText: some View {
        Text("Auto-renewable subscription. Cancel anytime in Settings.")
            .font(.caption)
            .foregroundColor(.white.opacity(0.7))
            .multilineTextAlignment(.center)
            .padding(.horizontal, horizontalPadding)
    }
    
    private var errorBinding: Binding<Bool> {
        Binding(
            get: { subscriptionManager.purchaseError != nil },
            set: { if !$0 { subscriptionManager.purchaseError = nil } }
        )
    }

    private func handlePurchase() {
        Task {
            isPurchasing = true
            do {
                try await subscriptionManager.purchase()
                dismissIfSubscribed()
            } catch {
                print("Purchase failed: \(error)")
            }
            isPurchasing = false
        }
    }

    private func handleRestore() {
        Task {
            await subscriptionManager.restorePurchases()
            dismissIfSubscribed()
        }
    }

    private func dismissIfSubscribed() {
        if subscriptionManager.isSubscribed {
            isPresented = false
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 30)

            Text(text)
                .font(.body)
                .foregroundColor(.white)

            Spacer()
        }
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView(isPresented: .constant(true))
    }
}
