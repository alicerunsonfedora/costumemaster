//
//  IAPManager.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 10/10/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import StoreKit

/// A base class responsible for observing in-app purchase transactions (IAP).
class IAPObserver: NSObject, SKPaymentTransactionObserver {

    /// A shared instance of the IAP manager.
    static let shared = IAPObserver()

    /// A list containing the purchased content transactions.
    var purchasedContent = [SKPaymentTransaction]()

    /// A list containing the restored transaction content.
    var restored = [SKPaymentTransaction]()

    /// Whether the IAP manager can handle payments.
    var authorizedToHandlePayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }

    /// Initialize the payment observer.
    override init() {
        super.init()
    }

    /// Tells an observer that one or more transactions have been updated.
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                self.onSuccessfulPayment(with: transaction)
            case .failed:
                self.onFailedPayment(with: transaction)
            case .restored:
                self.onRestorePayment(with: transaction)
            case .deferred:
                print("Deferring this payment transaction")
            case .purchasing:
                break
            @unknown default:
                fatalError("The type of transaction state is not recognized.")
            }
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        DispatchQueue.main.async {
            sendAlert(
                NSLocalizedString("costumemaster.alert.iap_error", comment: "IAP error"),
                withTitle: NSLocalizedString("costumemaster.alert.iap_error_title", comment: "IAP error title"),
                level: .informational,
                attachToMainWindow: false
            ) { _ in }
        }

    }

    /// Restore IAPs.
    func restore() {
        if !self.restored.isEmpty { self.restored.removeAll() }
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    /// Handle a transaction with a successful payment.
    func onSuccessfulPayment(with transaction: SKPaymentTransaction) {
        self.purchasedContent.append(transaction)
        UserDefaults.iapModule.setValue(true, forKey: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    /// Handle a transaction with a failed payment.
    func onFailedPayment(with transaction: SKPaymentTransaction) {
        sendAlert(
            NSLocalizedString("costumemaster.alert.iap_transaction_error", comment: "Transaction failed"),
            withTitle: NSLocalizedString("costumemaster.alert.iap_transaction_error_title", comment: "Transaction failed title"),
            level: .warning
        ) { _ in }
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    /// Handle a transactiom with a restored payment.
    func onRestorePayment(with transaction: SKPaymentTransaction) {
        self.restored.append(transaction)
        UserDefaults.iapModule.setValue(true, forKey: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
