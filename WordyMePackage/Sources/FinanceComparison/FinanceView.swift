import ComposableArchitecture
import StyleGuide
import SwiftUI

public struct FinanceView: View {
  let store: StoreOf<FinanceComparisonReducer>

  let formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    formatter.minimumFractionDigits = 2

    formatter.locale = .autoupdatingCurrent

    return formatter
  }()

  let formatterCurrency: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency

    formatter.locale = Locale(identifier: "en_gb")

    return formatter
  }()

  public init(store: StoreOf<FinanceComparisonReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store) { viewStore in
			ZStack {
        ColorGuide.primary
          .edgesIgnoringSafeArea(.all)
				ScrollView {
					VStack(alignment: .leading) {
						Group {
							Text("Initial")
								.font(.headline)
								.bold()
								.padding(.bottom, -4)
								.tint(ColorGuide.secondary)

							TextField(
								value: viewStore.binding(\.$initial),
								format: .number,
								label: {
									Text("Initial")
								}
							)
							.textFieldStyle(RoundedBorderTextFieldStyle())

						}
						.font(.title)

						Group {
							Text("Interest")
								.font(.headline)
								.bold()
								.padding(.bottom, -4)
								.fontDesign(.rounded)

							TextField(
								value: viewStore.binding(\.$interestRate),
								formatter: formatter,
								label: {
									Text("Interest rate")
								}
							)
							.textFieldStyle(RoundedBorderTextFieldStyle())
						}
						.font(.title)

						Group {
							Text("Months")
								.font(.headline)
								.bold()
								.padding(.bottom, -4)

							TextField(
								value: viewStore.binding(\.$monthlyPayments),
								format: .number,
								label: {
									Text("Months")
								}
							)
							.textFieldStyle(RoundedBorderTextFieldStyle())
						}
						.font(.title)

						Group {
							Text("Years")
								.font(.headline)
								.bold()
								.padding(.bottom, -4)

							TextField(
								value: viewStore.binding(\.$years),
								format: .number,
								label: {
									Text("Years")
								}
							)
							.textFieldStyle(RoundedBorderTextFieldStyle())

						}
						.font(.title)

						HStack {
							Text("Your savings")

							Spacer()

							TextField(
								value: viewStore.binding(\.$futureValue),
								formatter: formatterCurrency,
								label: {
									Text("Future value")
								}
							)
							.font(.title)
							.multilineTextAlignment(.center)
							.bold()
						}
						
						HStack {
							Text("Total interest earned")

							Spacer()
							TextField(
								value: viewStore.binding(\.$totalInterestEarned),
								formatter: formatterCurrency,
								label: {
									Text("Total interest earned")
								}
							)
							.font(.title)
							.multilineTextAlignment(.center)
							.bold()
						}

						Spacer()

						
					}
					.padding()
				}
				Button {
					// viewStore.send(.confirmSelection)
				} label: {
					Text("Save")
						.frame(maxWidth: .infinity)
						.contentShape(Rectangle())
						.multilineTextAlignment(.center)
						.foregroundColor(viewStore.isFeatureFlagOn ? ColorGuide.primary : ColorGuide.secondary)
						.fontDesign(.rounded)
						.bold()
				}
				.buttonStyle(PlainButtonStyle())
				.frame(maxWidth: .infinity)
				.frame(height: 50)
				.background(viewStore.isFeatureFlagOn ? ColorGuide.secondary : ColorGuide.primary)
				.cornerRadius(5)
				.padding(.horizontal)
				.frame(maxHeight: .infinity, alignment: .bottom)
      }
      .navigationTitle(Text("Finance calculator"))
      .onAppear {
        viewStore.send(.futureValue)
      }
			.preferredColorScheme(.light)
    }
  }
}

struct FinanceView_Previews: PreviewProvider {
  static let store: StoreOf<FinanceComparisonReducer> = .init(
    initialState: .init(
      initial: 1000,
      monthlyPayments: 12,
      years: 1,
      interestRate: 0.0415
    ),
    reducer: FinanceComparisonReducer()
  )
	
	static let store2: StoreOf<FinanceComparisonReducer> = .init(
		initialState: .init(
			isFeatureFlagOn: true,
			initial: 1000,
			monthlyPayments: 12,
			years: 1,
			interestRate: 0.0415
		),
		reducer: FinanceComparisonReducer()
	)

  static var previews: some View {
		Group {
			FinanceView(store: store)
				.previewLayout(.sizeThatFits)

			FinanceView(store: store2)
				.previewLayout(.sizeThatFits)
		}
  }
}
