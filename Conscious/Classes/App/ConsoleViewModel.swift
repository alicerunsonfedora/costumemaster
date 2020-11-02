//
//  ConsoleViewModel.swift
//  Costumemaster
//
//  Created by Marquis Kurt on 11/1/20.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

#if canImport(Combine)
import Combine
#endif

@available(OSX 10.15, *)
public class ConsoleViewModel: ObservableObject {
    @Published public var messages: [Message] = []

    public enum MessageType {
        case info
        case warning
        case error
        case unknown
    }

    public struct Message: Identifiable {
        public let contents: String
        public let type: MessageType
        public let timestamp: String
        public let id = UUID() //swiftlint:disable identifier_name
    }

    // swiftlint:disable:next large_tuple
    private func time() -> (Int, Int, Int) {
        let date = Date()
        let calendar = NSCalendar.current
        let hour = calendar.component(.hour, from: date)
        let min = calendar.component(.minute, from: date)
        let sec = calendar.component(.second, from: date)
        return (hour, min, sec)
    }

    private func sendMessage(with data: String, type: MessageType) {
        let (hour, min, sec) = self.time()
        let timestamp = "\(hour):\(min):\(sec > 10 ? "" : "0")\(sec)"
        messages.append(Message(contents: data, type: type, timestamp: timestamp))
    }

    public func log(_ message: String, silent: Bool = false) {
        if !silent { print(message) }
        self.sendMessage(with: message, type: .unknown)
    }

    public func info(_ message: String, silent: Bool = false) {
        if !silent { print(message) }
        self.sendMessage(with: message, type: .info)
    }

    public func warn(_ message: String, silent: Bool = false) {
        if !silent { print(message) }
        self.sendMessage(with: message, type: .warning)
    }

    public func error(_ message: String, silent: Bool = false) {
        if !silent { print(message) }
        self.sendMessage(with: message, type: .error)
    }

    public func clear() {
        self.messages = []
        self.log("Console cleared.", silent: true)
    }
}
