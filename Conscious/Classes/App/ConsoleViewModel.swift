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

    public enum MessageType: String {
        case info = "INFO"
        case warning = "WARN"
        case error = "ERR"
        case unknown = "LOG"
        case debug = "DEBUG"
    }

    public struct Message: Identifiable {
        public let contents: String
        public let type: MessageType
        public let timestamp: String
        public let id = UUID()
        //swiftlint:disable:previous identifier_name
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

    private func sendMessage(with data: String, type: MessageType, silent: Bool) {
        let (hour, min, sec) = self.time()
        let timestamp = String(format: "%02d:%02d:%02d", hour, min, sec)
        if !silent { print("[\(type.rawValue)]\t\(timestamp)\t" + data) }
        messages.append(Message(contents: data, type: type, timestamp: timestamp))
    }

    public func log(_ message: String, silent: Bool = false) {
        self.sendMessage(with: message, type: .unknown, silent: silent)
    }

    public func info(_ message: String, silent: Bool = false) {
        self.sendMessage(with: message, type: .info, silent: silent)
    }

    public func warn(_ message: String, silent: Bool = false) {
        self.sendMessage(with: message, type: .warning, silent: silent)
    }

    public func error(_ message: String, silent: Bool = false) {
        self.sendMessage(with: message, type: .error, silent: silent)
    }

    public func debug(_ message: String, silent: Bool = true) {
        self.sendMessage(with: message, type: .debug, silent: silent)
    }

    public func clear() {
        self.messages = []
        self.info("Console cleared.", silent: true)
    }
}
