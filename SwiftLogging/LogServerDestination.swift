//
//  LoggingTelnetServer.swift
//  SwiftLogging
//
//  Created by Jonathan Wight on 3/18/16.
//  Copyright © 2016 schwa.io. All rights reserved.
//

import SwiftIO
import SwiftUtilities

public class LogServerDestination: Destination {
    public private(set) var server: TCPServer!

    public init(identifier: String, address: Address, formatter: EventFormatter = terseFormatter) throws  {
        super.init(identifier: identifier)
        self.formatter = formatter

        server = try TCPServer(address: address)

        server.clientDidConnect = {
            (client) in

            log.debug("Logging client \(client.address) did connect")
        }

        try server.startListening()
    }

    public convenience init(identifier: String, port: UInt16 = 4000, formatter: EventFormatter = terseFormatter) throws  {
        let address = try Address(address: "0.0.0.0", port: port)
        try self.init(identifier: identifier, address: address, formatter: formatter)
    }

    public override func receiveEvent(event: Event) {
        guard case .Formatted(let subject) = event.subject else {
            fatalError("Cannot process unformatted events.")
        }
        let string = subject + "\n"
        do {
            let data = try DispatchData <Void> (string, encoding: NSUTF8StringEncoding)
            for channel in server.connections.value {
                channel.write(data) {
                    (result) in
                }
            }
        }
        catch let error {
            print("Could not write data to clients: \(error)")
        }
    }

}