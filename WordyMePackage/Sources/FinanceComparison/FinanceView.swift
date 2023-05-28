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
        ColorGuide.primaryAlt
          .edgesIgnoringSafeArea(.all)
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

          Spacer()

          Button {
            // viewStore.send(.confirmSelection)
          } label: {
            Text("Save")
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
          .cornerRadius(5)
        }
        .padding()
      }
      .navigationTitle(Text("Finance calculator").fontDesign(.serif))
      .onAppear {
        viewStore.send(.futureValue)
      }
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

  static var previews: some View {
    NavigationView {
      FinanceView(store: store)
    }
  }
}
