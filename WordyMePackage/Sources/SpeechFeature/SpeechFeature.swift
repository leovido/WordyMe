import ComposableArchitecture
import Foundation
import Speech
import XCTestDynamicOverlay

import AVFoundation
import SwiftUI

public struct SpeechFeature: ReducerProtocol {
  public init() {}

  public struct State: Equatable {
    public var alert: AlertState<Action>?
    public var isRecording = false
    public var transcribedText = ""

    public init(alert: AlertState<Action>? = nil, isRecording: Bool = false, transcribedText: String = "") {
      self.alert = alert
      self.isRecording = isRecording
      self.transcribedText = transcribedText
    }
  }

  public enum Action: Hashable {
    case authorizationStateAlertDismissed
    case recordButtonTapped
    case stopTranscribing
    case speech(TaskResult<String>)
    case possibleWords([Transcription])
    case didLiftFinger
    case speechRecognizerAuthorizationStatusResponse(SFSpeechRecognizerAuthorizationStatus)
  }

  @Dependency(\.speechClient) var speechClient

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .authorizationStateAlertDismissed:
        state.alert = nil
        return .none

      case .didLiftFinger:
        return .fireAndForget {
          await self.speechClient.finishTask()
        }

      case .recordButtonTapped:
        state.isRecording.toggle()

        guard state.isRecording
        else {
          return .none
        }

        return .run { send in
          let status = await self.speechClient.requestAuthorization()
          await send(.speechRecognizerAuthorizationStatusResponse(status))

          guard status == .authorized
          else { return }

          dump("how many times")
          let request = SFSpeechAudioBufferRecognitionRequest()
          for try await result in await self.speechClient.startTask(request) {
            dump(result)
            let transcriptions = result.transcriptions

            await send(.possibleWords(transcriptions))
          }
        } catch: { error, send in
          await send(.speech(.failure(error)))
        }
      case .speech(.failure(SpeechClient.Failure.couldntConfigureAudioSession)),
           .speech(.failure(SpeechClient.Failure.couldntStartAudioEngine)):
        state.alert = AlertState { TextState("Problem with audio device. Please try again.") }
        return .none

      case .speech(.failure):
        state.alert = AlertState {
          TextState("An error occurred while transcribing. Please try again.")
        }
        return .none

      case let .speech(.success(transcribedText)):
        state.transcribedText = transcribedText
        return .none

      case .possibleWords:
        return .none
      case let .speechRecognizerAuthorizationStatusResponse(status):
        state.isRecording = status == .authorized

        switch status {
        case .authorized:
          return .none

        case .denied:
          state.alert = AlertState {
            TextState(
              """
              You denied access to speech recognition. This app needs access to transcribe your \
              speech.
              """
            )
          }
          return .none

        case .notDetermined:
          return .none

        case .restricted:
          state.alert = AlertState { TextState("Your device does not allow speech recognition.") }
          return .none

        @unknown default:
          return .none
        }
      case .stopTranscribing:
        return .run { send in
          await send(.didLiftFinger)
        }
      }
    }
  }
}
