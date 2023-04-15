import ComposableArchitecture
import StyleGuide
import SwiftUI

public struct PossibilityView: View {
  let store: Store<PossibleWordsReducer.State, PossibleWordsReducer.Action>

  public init(store: Store<PossibleWordsReducer.State, PossibleWordsReducer.Action>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store) { viewStore in
      ZStack {
        ColorGuide.secondary
          .edgesIgnoringSafeArea(.all)
        VStack(alignment: .leading) {
          Button(action: {
            viewStore.send(.didClosePossibleWordsSheet)
          }, label: {
            Image(systemName: "xmark.square.fill")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 30, height: 30)
              .foregroundColor(ColorGuide.ternary)
          })
          .frame(maxWidth: .infinity, alignment: .trailing)
          .padding()

          Text("Possibilities")
            .font(.largeTitle)
            .foregroundColor(ColorGuide.primary)
            .bold()
            .fontDesign(.serif)
            .padding()

          list(viewStore: viewStore)

          Button {
            viewStore.send(.confirmSelection)
          } label: {
            Text("Confirm")
              .frame(maxWidth: .infinity)
              .contentShape(Rectangle())
              .multilineTextAlignment(.center)
              .foregroundColor(ColorGuide.secondary)
              .fontDesign(.rounded)
              .bold()
          }
          .buttonStyle(PlainButtonStyle())
          .frame(maxWidth: .infinity)
          .frame(height: 50)
          .background(ColorGuide.primary)
          .padding(.horizontal)
          .padding(.bottom, 2)
          .cornerRadius(5)
          .disabled(viewStore.state.selectedWord != nil ? false : true)
        }
      }
    }
  }

  private func list(viewStore: ViewStore<PossibleWordsReducer.State, PossibleWordsReducer.Action>) -> some View {
    ScrollView {
      ForEach(viewStore.possibleWords, id: \.self) { possibility in
        Button {
          viewStore.send(.selectWord(possibility))
        } label: {
          HStack {
            Text(possibility.formattedString)
              .font(.headline)
              .foregroundColor(ColorGuide.primary)
              .fontDesign(.rounded)

            let confidence = possibility.segments
              .filter {
                $0.substring == possibility.formattedString
              }
              .map(\.confidence)
              .first ?? 0

            let formattedConfidence = String(format: "%0.2f%%", confidence * 100)
            Text(formattedConfidence)
              .foregroundColor(ColorGuide.primary)
          }
          .padding()
          .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .border(ColorGuide.ternary, width: 2)
        .background(viewStore.state.selectedWord != nil && viewStore.state.selectedWord!.id == possibility.id
          ? ColorGuide.secondaryAlt : Color.clear)
        .cornerRadius(5)
        .padding(.horizontal)
      }
    }
    .frame(maxWidth: .infinity)
  }
}
