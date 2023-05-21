import ComposableArchitecture
import SwiftUI

@MainActor
public struct CountView: View {
  let store: StoreOf<CounterReducer>

  @State var scale: CGFloat = 1

  public init(store: StoreOf<CounterReducer>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store) { viewStore in
      NavigationView {
        VStack {
          Text(viewStore.count.description)
            .font(.largeTitle)

          Button {
//            viewStore.send(.incrementCount)
          } label: {
            Circle()
              .fill(Color.blue.opacity(0.5))
              .colorInvert()
              .frame(width: 220, height: 220)
          }
          .onTapGesture {
            viewStore.send(.incrementCount)
          }
          Button {
            viewStore.send(.resetCount)
          } label: {
            Text("Reset")
              .padding()
              .background(Color.pink)
              .colorInvert()
              .cornerRadius(5)
          }
          .padding()
        }
      }
    }
  }
}
