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

/// A base class that manages in-app purchaes (IAP).
class IAPManager: NSObject {

    /// A shared instance of the IAP Manager.
    static let shared = IAPManager()

    /// A list containing all of the available products.
    var available = [SKProduct]()

    /// A list containing the strings of invalid identifiers.
    var invalid = [String]()

    /// The current product request.
    var request: SKProductsRequest!

    /// The request delegate for the manager.
    weak var delegate: SKProductsRequestDelegate?

    /// An enumeration that represents the available content to purchase.
    enum PurchaseableContent: String, CaseIterable {

        /// The "Watch Your Step!" DLC.
        case watchYourStep = "net.marquiskurt.costumemaster_dlc_wys"

        /// Returns all cases as a set.
        static func toSet() -> Set<String> {
            return Set(PurchaseableContent.allCases.map { content in content.rawValue })
        }
    }

    /// Query a request for all products.
    func makeAllProductRequests() {
        self.makeProductRequests(with: PurchaseableContent.toSet())
    }

    /// Request for a specific item.
    /// - Parameter identifier: The identifier of the item to request for.
    func makeProductRequest(with identifier: PurchaseableContent) {
        self.makeProductRequests(with: [identifier.rawValue])
    }

    /// Request for a specific set of items.
    /// - Parameter identifiers: The list of identifiers to make a request for.
    func makeProductRequests(with identifiers: [String]) {
        let requestSet = Set(identifiers)
        request = SKProductsRequest(productIdentifiers: requestSet)
        request.delegate = self
        request.start()
    }

    /// Request for a specific set of items.
    /// - Parameter identifiers: The set of identifiers to make a request for.
    func makeProductRequests(with identifiers: Set<String>) {
        request = SKProductsRequest(productIdentifiers: identifiers)
        request.delegate = self
        request.start()
    }

    /// Purchase an item.
    /// - Parameter identifier: The identifier to purchase.
    func purchase(with identifier: PurchaseableContent) {
        guard IAPObserver.shared.authorizedToHandlePayments else { return }
        for product in available {
            if product.productIdentifier != identifier.rawValue { continue }
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }

}
