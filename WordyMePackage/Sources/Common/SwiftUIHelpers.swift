import SwiftUI

public struct AnyViewA11y: View {
  public var text: String?
  public var description: String?
  public var hint: String?
  public var trait: AccessibilityTraits?
  public var action: (() -> Void)?

  public var body: some View {
    AnyView(_fromValue: self)
      .accessibilityLabel(Text(text ?? ""))
      .accessibilityHint(Text(hint ?? ""))
      .accessibilityValue(Text(description ?? ""))
      .accessibilityIdentifier(text ?? "")
      //			.accessibilityAddTraits(trait)
      .accessibilityAction {
        action?()
      }
  }
}
