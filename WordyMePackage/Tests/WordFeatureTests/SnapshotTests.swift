import ComposableArchitecture
import Foundation
import SnapshotTesting
import XCTest

import SwiftUI
@testable import WordFeature

@MainActor
final class SnapshotTests: XCTestCase {
  func testEmptyView() async {
    let store: StoreOf<WordReducer> = .init(
      initialState: WordReducer.State(),
      reducer: WordReducer()
    )

    let view = UIHostingController(rootView: MainWordView(store: store))

    assertSnapshot(matching: view, as: .image(on: .iPhoneX))
  }
}
