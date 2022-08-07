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
    /// Make a product request.
    func productsRequest(_: SKProductsRequest, didReceive response: SKProductsResponse) {
        if !response.products.isEmpty {
            available = response.products
        }

        if !response.invalidProductIdentifiers.isEmpty {
            invalid = response.invalidProductIdentifiers
        }
    }
}

extension IAPManager: SKRequestDelegate {
    /// Make a products request that handles an error.
    func request(_: SKRequest, didFailWithError _: Error) {
//        print(error.localizedDescription)
    }
}
