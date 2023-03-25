import Foundation
import Speech
import XCTestDynamicOverlay
import ComposableArchitecture

import AVFoundation
import SwiftUI

public struct SpeechRecognizer: ReducerProtocol {
	public struct State: Hashable {
		public var transcript: String = ""

		public init(transcript: String = "") {
			self.transcript = transcript
		}
	}

	public enum Action: Hashable {
		case stopTranscribing
		case start
		case reset
	}
	
	public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
		switch action {
		case .stopTranscribing:
			return .none
		case .reset:
			return .none
		case .start:
			return .none
		}
	}
}
