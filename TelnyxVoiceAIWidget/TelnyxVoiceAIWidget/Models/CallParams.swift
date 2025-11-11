//
//  CallParams.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 07-11-25.
//

import Foundation

/// Parameters for customizing call initialization
/// All parameters are optional and will override default values when provided
public struct CallParams {
    /// The name to display as the caller
    public var callerName: String?

    /// The phone number to use as the caller number
    public var callerNumber: String?

    /// The destination number for the call
    public var destinationNumber: String?

    /// Custom client state data to include with the call
    public var clientState: String?

    /// Custom headers to include with the call
    ///
    /// These headers need to start with the X- prefix and will be mapped to dynamic variables in the AI assistant (e.g., X-Account-Number becomes {{account_number}}).
    /// Hyphens in header names are converted to underscores in variable names.
    public var customHeaders: [String: String]?

    public init(
        callerName: String? = nil,
        callerNumber: String? = nil,
        destinationNumber: String? = nil,
        clientState: String? = nil,
        customHeaders: [String: String]? = nil
    ) {
        self.callerName = callerName
        self.callerNumber = callerNumber
        self.destinationNumber = destinationNumber
        self.clientState = clientState
        self.customHeaders = customHeaders
    }
}
