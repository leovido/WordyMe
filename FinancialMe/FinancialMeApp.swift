//
//  FinancialMeApp.swift
//  FinancialMe
//
//  Created by Christian Ray Leovido on 21/05/2023.
//

import ComposableArchitecture
import FinanceComparison
import SwiftUI

@main
struct FinancialMeApp: App {
  let store: StoreOf<FinanceComparisonReducer> = .init(initialState: .init(initial: 1, monthlyPayments: 12, years: 1, interestRate: 0.10), reducer: FinanceComparisonReducer())
  var body: some Scene {
    WindowGroup {
      NavigationView {
        FinanceView(store: store)
      }
    }
  }
}
