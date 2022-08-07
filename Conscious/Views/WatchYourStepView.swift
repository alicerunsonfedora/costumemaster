//
//  WatchYourStepView.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 10/11/20.
//

import SwiftUI

/// A view that handles the "Watch Your Step" DLC content, including IAP.
struct WatchYourStepView: View {

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
            Image("AppIconDLCRepresentable")
                .resizable()
                .scaledToFit()
                .cornerRadius(6.0)
                .frame(maxWidth: 100)
                .shadow(radius: 8)
            Text("costumemaster.dialog.dlc_title")
                .font(.system(.title, design: .rounded))
                .bold()
            Text("costumemaster.dialog.dlc_detail")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack {
                Button {
                    self.onDismiss()
                } label: {
                    Text("costumemaster.dialog.dlc_dismiss_button")
                }

                Spacer()

                Button {
                    self.purchase()
                } label: {
                    Text("costumemaster.dialog.dlc_purchase_button")
                }
                .disabled(self.dlcIsAvailable)
                .help(
                    self.dlcIsAvailable
                    ? NSLocalizedString(
                        "costumemaster.dialog.dlc_purchase_button_disabled_help",
                        comment: "DLC already purchased"
                    )
                    : NSLocalizedString("costumemaster.dialog.dlc_purchase_button_enabled_help", comment: "Purchase")
                )
                Button {
                    self.onStartDLCContent()
                } label: {
                    Text("costumemaster.dialog.dlc_play_button")
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
struct WatchYourStepView_Previews: PreviewProvider {

    /// The preview content.
    static var previews: some View {
        WatchYourStepView()

    }
}
