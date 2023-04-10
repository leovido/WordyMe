import SwiftUI
import StyleGuide
import ComposableArchitecture

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
					ScrollView {
						ForEach(viewStore.possibleWords, id: \.id) { possibility in
							HStack {
								Text(possibility.formattedString)
									.font(.headline)
									.foregroundColor(ColorGuide.primary)
									.fontDesign(.rounded)
								
								let confidence = possibility.segments.filter {
									$0.substring == possibility.formattedString
								}
									.map(\.confidence)
									.first ?? 0
								
								let formattedConfidence = String(format: "%0.2f%%", confidence * 100)
								Text(formattedConfidence)
									.foregroundColor(ColorGuide.primary)
							}
							.padding()
						}
					}
				}
			}
		}
	}
}

#if DEBUG
struct PossibilityView_Previews: PreviewProvider {
	static let store: StoreOf<PossibleWordsReducer> = .init(
		initialState: PossibleWordsReducer.State(possibleWords: [
			.init(formattedString: "Demo", segments: [
				.init(alternativeSubstrings: ["Alternative"], confidence: 0.89, duration: 1, substring: "", timestamp: 1)
			]),
			.init(formattedString: "Word", segments: [
				.init(alternativeSubstrings: ["Alternative"], confidence: 3, duration: 1, substring: "", timestamp: 1)
			])
		]),
		reducer: PossibleWordsReducer()
	)
	static var previews: some View {
		PossibilityView(store: store)
	}
}
#endif
