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
import Combine

/// A class for handling console output.
public class ConsoleViewModel: ObservableObject {

    /// The list of console messages that have been logged.
    @Published public var messages: [Message] = []

    /// The filter for the types of console messages that can be displayed.
    @Published public var filter: [MessageType] = [.info, .debug, .error, .warning, .unknown, .success]

    /// Whether to enable "now mode".
    @Published public var nowMode: Bool = false

    /// An enumeration that represents the type of messages that can be logged.
    public enum MessageType: String {

        /// An informational message.
        case info = "INFO"

        /// A warning.
        case warning = "WARN"

        /// An error message.
        case error = "ERR"

        /// An unknown type or standard log.
        case unknown = "LOG"

        /// A debugging message.
        case debug = "DEBUG"

        /// A success message.
        case success = "SUCCESS"
    }

    /// A data structure that represents a console message.
    public struct Message: Identifiable {

        /// The contents of the message.
        public let contents: String

        /// The type of message.
        public let type: MessageType

        /// The time the message was created or logged.
        public let timestamp: String

        /// A(n) unique identifier for this message.
        public let id = UUID()
        // swiftlint:disable:previous identifier_name
    }

    /// Returns a tuple containing the hour, minute, and second logged.
    private func time() -> (Int, Int, Int) {
        // swiftlint:disable:previous large_tuple
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

    /// Log a message to the console.
    /// - Parameter message: The contents of the message entry.
    /// - Parameter silent: Whether to skip printing the message to the terminal.
    public func log(_ message: String, silent: Bool = false) {
        self.sendMessage(with: message, type: .unknown, silent: silent)
    }

    /// Log an informational message to the console.
    /// - Parameter message: The contents of the message entry.
    /// - Parameter silent: Whether to skip printing the message to the terminal.
    public func info(_ message: String, silent: Bool = false) {
        self.sendMessage(with: message, type: .info, silent: silent)
    }

    /// Log a warning to the console.
    /// - Parameter message: The contents of the message entry.
    /// - Parameter silent: Whether to skip printing the message to the terminal.
    public func warn(_ message: String, silent: Bool = false) {
        self.sendMessage(with: message, type: .warning, silent: silent)
    }

    /// Log an error message to the console.
    /// - Parameter message: The contents of the message entry.
    /// - Parameter silent: Whether to skip printing the message to the terminal.
    public func error(_ message: String, silent: Bool = false) {
        self.sendMessage(with: message, type: .error, silent: silent)
    }

    /// Log a debugging message to the console.
    /// - Parameter message: The contents of the message entry.
    /// - Parameter silent: Whether to skip printing the message to the terminal.
    public func debug(_ message: String, silent: Bool = true) {
        self.sendMessage(with: message, type: .debug, silent: silent)
    }

    /// Log a success message to the console.
    /// - Parameter message: The contents of the message entry.
    /// - Parameter silent: Whether to skip printing the message to the terminal.
    public func success(_ message: String, silent: Bool = false) {
        self.sendMessage(with: message, type: .success, silent: silent)
    }

    /// Clears the console.
    public func clear() {
        self.messages = []
        self.info("Console cleared.", silent: true)
    }
}
