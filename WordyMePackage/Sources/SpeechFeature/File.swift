import Speech
import ComposableArchitecture

struct SpeechClient {
	var transcribe: () -> Void
	var stopTranscribing: () -> Void
	var reset: () -> Void
	
	public init(transcribe: @escaping () -> Void,
							stopTranscribing: @escaping() -> Void,
							reset: @escaping() -> Void) {
		self.transcribe = transcribe
		self.stopTranscribing = stopTranscribing
		self.reset = reset
	}
	
	private actor SpeechActor {
		var transcript: String = ""
		
		var audioEngine: AVAudioEngine?
		var request: SFSpeechAudioBufferRecognitionRequest?
		var task: SFSpeechRecognitionTask?
		let recognizer: SFSpeechRecognizer?
		
		public enum Action: Hashable {
			case stopTranscribing
			case start
			case reset
		}
		
		public enum RecognizerError: Error {
			case nilRecognizer
			case notAuthorizedToRecognize
			case notPermittedToRecord
			case recognizerIsUnavailable
			
			var message: String {
				switch self {
					case .nilRecognizer: return "Can't initialize speech recognizer"
					case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
					case .notPermittedToRecord: return "Not permitted to record audio"
					case .recognizerIsUnavailable: return "Recognizer is unavailable"
				}
			}
		}
		
		public init() {
			self.recognizer = SFSpeechRecognizer()
			
			Task(priority: .background) {
				do {
					guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
						throw RecognizerError.notAuthorizedToRecognize
					}
					guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
						throw RecognizerError.notPermittedToRecord
					}
				} catch {
	//				speakError(error)
				}
			}
		}
		
		func stopTranscribing() {
			reset()
		}
		
		func reset() {
			task?.cancel()
			audioEngine?.stop()
			audioEngine = nil
			request = nil
			task = nil
		}
		
		private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
			let audioEngine = AVAudioEngine()
			
			let request = SFSpeechAudioBufferRecognitionRequest()
			request.shouldReportPartialResults = true
			
			let audioSession = AVAudioSession.sharedInstance()
			try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
			try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
			let inputNode = audioEngine.inputNode
			
			let recordingFormat = inputNode.outputFormat(forBus: 0)
			inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
				request.append(buffer)
			}
			audioEngine.prepare()
			try audioEngine.start()
			
			return (audioEngine, request)
		}
		
		private func recognitionHandler(result: SFSpeechRecognitionResult?, error: Error?) {
			let receivedFinalResult = result?.isFinal ?? false
			let receivedError = error != nil
			
			if receivedFinalResult || receivedError {
				audioEngine?.stop()
				audioEngine?.inputNode.removeTap(onBus: 0)
			}
			
			if let result = result {
				speak(result.bestTranscription.formattedString)
			}
		}
		
		private func speak(_ message: String) {
			self.transcript = message
		}
		
		private func speakError(_ error: Error) {
			var errorMessage = ""
			if let error = error as? RecognizerError {
				errorMessage += error.message
			} else {
				errorMessage += error.localizedDescription
			}
			self.transcript = "<< \(errorMessage) >>"
		}
	}
}

extension SpeechClient: DependencyKey {
	static var liveValue: SpeechClient {
		let actor = SpeechActor()
		return Self(transcribe: {
//			guard let recognizer = actor.recognizer, ((actor.recognizer?.isAvailable) != nil) else {
////				actor.speakError(RecognizerError.recognizerIsUnavailable)
//				fatalError()
//			}
//
//			do {
//				let (audioEngine, request) = try Self.prepareEngine()
//				actor.audioEngine = audioEngine
//				actor.request = request
//				actor.task = actor.recognizer.recognitionTask(with: request, resultHandler: self.recognitionHandler(result:error:))
//			} catch {
//				actor.reset()
//				actor.speakError(error)
//			}
		}, stopTranscribing: {
//			actor.transcript = ""
		}, reset: {
//			actor.reset()
		})
	}
}

extension SFSpeechRecognizer {
	static func hasAuthorizationToRecognize() async -> Bool {
		await withCheckedContinuation { continuation in
			requestAuthorization { status in
				continuation.resume(returning: status == .authorized)
			}
		}
	}
}

extension AVAudioSession {
	func hasPermissionToRecord() async -> Bool {
		await withCheckedContinuation { continuation in
			requestRecordPermission { authorized in
				continuation.resume(returning: authorized)
			}
		}
	}
}

extension DependencyValues {
	var speechClient: SpeechClient {
		get { self[SpeechClient.self] }
		set { self[SpeechClient.self] = newValue }
	}
}
