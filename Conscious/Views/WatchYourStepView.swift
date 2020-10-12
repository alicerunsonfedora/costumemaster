//
//  WatchYourStepView.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 10/11/20.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

/// A view that handles the "Watch Your Step" DLC content, including IAP.
@available(OSX 10.15, *) struct WatchYourStepView: View {

    /// A closure that executes when the DLC content starts.
    var onStartDLCContent: () -> Void = {}

    /// A closure that executes when the dialog is dismissed.
    var onDismiss: () -> Void = {}

    /// Whether the DLC is available, or if it needs to be purchased.
    @State var dlcIsAvailable: Bool = UserDefaults.iapModule.bool(
        forKey: IAPManager.PurchaseableContent.watchYourStep.rawValue
    )

    /// The main structure of the view.
    var body: some View {
        VStack {
            Image("WatchYourStep")
                .resizable()
                .scaledToFit()
                .cornerRadius(6.0)
                .frame(maxWidth: 76)
                .shadow(radius: 8)
            Text("Watch Your Step!")
                .font(.title)
                .bold()
            Text(
                "Want to get more out of The Costumemaster? Avoid dangerous abysses and work with new elements like"
                + " the iris scanner to solve new puzzles."
            )
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack {
                Button {
                    self.onDismiss()
                } label: {
                    Text("Not Now")
                }

                Spacer()

                Button {
                    self.purchase()
                } label: {
                    Text("Purchase")
                }
                .disabled(self.dlcIsAvailable)
                Button {
                    self.onStartDLCContent()
                } label: {
                    Text("Play Now")
                }
                .disabled(!self.dlcIsAvailable)
            }
            .padding(.top)
        }
        .padding()
        .background(
            Image("WatchYourStepScreenshot")
                .resizable()
                .scaledToFill()
                .blur(radius: 4.0)
                .overlay(
                    Color(.windowBackgroundColor).opacity(0.5)
                )
        )
        .colorScheme(.dark)
        .frame(minWidth: 500, minHeight: 225)
    }

    /// Purchase the DLC.
    func purchase() {
        IAPManager.shared.purchase(with: .watchYourStep)
        DispatchQueue.main.async {
            self.dlcIsAvailable = UserDefaults.iapModule.bool(
                forKey: IAPManager.PurchaseableContent.watchYourStep.rawValue
            )
        }
    }
}

/// The preview for the WatchYourStepView view.
@available(OSX 10.15, *) struct WatchYourStepView_Previews: PreviewProvider {

    /// The preview content.
    static var previews: some View {
        WatchYourStepView()

    }
}
