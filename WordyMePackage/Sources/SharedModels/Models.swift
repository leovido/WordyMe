import Speech

// The core data types in the Speech framework are reference types and are not constructible by us,
// and so they aren't testable out the box. We define struct versions of those types to make
// them easier to use and test.

public struct SpeechRecognitionMetadata: Equatable {
	public var averagePauseDuration: TimeInterval
	public var speakingRate: Double
	public var voiceAnalytics: VoiceAnalytics?
}

public struct SpeechRecognitionResult: Equatable {
	public var bestTranscription: Transcription
	public var isFinal: Bool
	public var speechRecognitionMetadata: SpeechRecognitionMetadata?
  public var transcriptions: [Transcription]
	
	public init(bestTranscription: Transcription,
							isFinal: Bool,
							speechRecognitionMetadata: SpeechRecognitionMetadata? = nil,
							transcriptions: [Transcription]) {
		self.bestTranscription = bestTranscription
		self.isFinal = isFinal
		self.speechRecognitionMetadata = speechRecognitionMetadata
		self.transcriptions = transcriptions
	}
}

public struct Transcription: Identifiable, Hashable {
  public var id: UUID = .init()
  public var formattedString: String
  public var segments: [TranscriptionSegment]
	
	public init(formattedString: String, segments: [TranscriptionSegment]) {
		self.formattedString = formattedString
		self.segments = segments
	}
}

public struct TranscriptionSegment: Hashable {
  public var alternativeSubstrings: [String]
  public var confidence: Float
  public var duration: TimeInterval
  public var substring: String
  public var timestamp: TimeInterval
	
	public init(alternativeSubstrings: [String], confidence: Float, duration: TimeInterval, substring: String, timestamp: TimeInterval) {
		self.alternativeSubstrings = alternativeSubstrings
		self.confidence = confidence
		self.duration = duration
		self.substring = substring
		self.timestamp = timestamp
	}
}

public struct VoiceAnalytics: Equatable {
	public var jitter: AcousticFeature
	public var pitch: AcousticFeature
	public var shimmer: AcousticFeature
	public var voicing: AcousticFeature
}

public struct AcousticFeature: Equatable {
	public var acousticFeatureValuePerFrame: [Double]
	public var frameDuration: TimeInterval
}

extension SpeechRecognitionMetadata {
  public init(_ speechRecognitionMetadata: SFSpeechRecognitionMetadata) {
    averagePauseDuration = speechRecognitionMetadata.averagePauseDuration
    speakingRate = speechRecognitionMetadata.speakingRate
    voiceAnalytics = speechRecognitionMetadata.voiceAnalytics.map(VoiceAnalytics.init)
  }
}

extension SpeechRecognitionResult {
  public init(_ speechRecognitionResult: SFSpeechRecognitionResult) {
    bestTranscription = Transcription(speechRecognitionResult.bestTranscription)
    isFinal = speechRecognitionResult.isFinal
    speechRecognitionMetadata = speechRecognitionResult.speechRecognitionMetadata
      .map(SpeechRecognitionMetadata.init)
    transcriptions = speechRecognitionResult.transcriptions.map(Transcription.init)
  }
}

extension Transcription {
  init(_ transcription: SFTranscription) {
    formattedString = transcription.formattedString
    segments = transcription.segments.map(TranscriptionSegment.init)
  }
}

extension TranscriptionSegment {
  init(_ transcriptionSegment: SFTranscriptionSegment) {
    alternativeSubstrings = transcriptionSegment.alternativeSubstrings
    confidence = transcriptionSegment.confidence
    duration = transcriptionSegment.duration
    substring = transcriptionSegment.substring
    timestamp = transcriptionSegment.timestamp
  }
}

extension VoiceAnalytics {
  init(_ voiceAnalytics: SFVoiceAnalytics) {
    jitter = AcousticFeature(voiceAnalytics.jitter)
    pitch = AcousticFeature(voiceAnalytics.pitch)
    shimmer = AcousticFeature(voiceAnalytics.shimmer)
    voicing = AcousticFeature(voiceAnalytics.voicing)
  }
}

extension AcousticFeature {
  init(_ acousticFeature: SFAcousticFeature) {
    acousticFeatureValuePerFrame = acousticFeature.acousticFeatureValuePerFrame
    frameDuration = acousticFeature.frameDuration
  }
}
