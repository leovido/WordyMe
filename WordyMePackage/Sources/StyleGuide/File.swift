import UIKit

public enum ColorGuide {
  public static let primary = UIColor.hex(0xDBD5B2)
  public static let primaryAlt = UIColor.hex(0xE7DFC6)
  public static let secondary = UIColor.hex(0x54426B)
  public static let secondaryAlt = UIColor.hex(0x623CEA)
  public static let ternary = UIColor.hex(0xE9F1F7)
}

public extension UIColor {
  static func hex(_ hex: UInt) -> Self {
    Self(
      red: CGFloat((hex & 0xFF0000) >> 16) / 255,
      green: CGFloat((hex & 0x00FF00) >> 8) / 255,
      blue: CGFloat(hex & 0x0000FF) / 255,
      alpha: 1
    )
  }
}
