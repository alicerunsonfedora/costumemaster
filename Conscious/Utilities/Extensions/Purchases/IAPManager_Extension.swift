//
//  IAPManager_Extension.swift
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

extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(response.products.map { product in product.productIdentifier })
        if !response.products.isEmpty {
            self.available = response.products
        }

        if !response.invalidProductIdentifiers.isEmpty {
            self.invalid = response.invalidProductIdentifiers
        }
    }
}

extension IAPManager: SKRequestDelegate {
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
