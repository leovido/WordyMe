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
							ForEach(viewStore.possibleWords, id: \.self) { possibility in
								Button {
									viewStore.send(.selectWord(possibility))
								} label: {
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
		], selectedWord: nil),
		reducer: PossibleWordsReducer()
	)
	
	static let store2: StoreOf<PossibleWordsReducer> = .init(
		initialState: PossibleWordsReducer.State(possibleWords: [
			.init(formattedString: "Demo", segments: [
				.init(alternativeSubstrings: ["Alternative"], confidence: 0.89, duration: 1, substring: "", timestamp: 1)
			]),
			.init(formattedString: "Word", segments: [
				.init(alternativeSubstrings: ["Alternative"], confidence: 3, duration: 1, substring: "", timestamp: 1)
			])
		], selectedWord: .init(formattedString: "Word", segments: [
			.init(alternativeSubstrings: ["Alternative"], confidence: 3, duration: 1, substring: "", timestamp: 1)
		 ])),
		reducer: PossibleWordsReducer()
	)
	static var previews: some View {
		Group {
			PossibilityView(store: store)
			PossibilityView(store: store2)
		}
	}
}
#endif
