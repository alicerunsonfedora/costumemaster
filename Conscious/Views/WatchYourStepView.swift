//
//  WatchYourStepView.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 10/11/20.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(OSX 10.15, *) struct WatchYourStepView: View {

    var onStartDLCContent: () -> Void = {}
    var onDismiss: () -> Void = {}
    @State var dlcIsAvailable: Bool = UserDefaults.iapModule.bool(forKey: "")

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

    func purchase() {
        IAPManager.shared.purchase(with: .watchYourStep)
    }
}

@available(OSX 10.15, *) struct WatchYourStepView_Previews: PreviewProvider {
    static var previews: some View {
        WatchYourStepView()

    }
}
