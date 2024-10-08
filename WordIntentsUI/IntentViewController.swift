//
//  IntentViewController.swift
//  WordIntentsUI
//
//  Created by Christian Ray Leovido on 01/04/2023.
//

import IntentsUI

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

class IntentViewController: UIViewController, INUIHostedViewControlling {
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  // MARK: - INUIHostedViewControlling

  // Prepare your view controller for the interaction to handle.
  func configureView(for parameters: Set<INParameter>,
                     of _: INInteraction,
                     interactiveBehavior _: INUIInteractiveBehavior,
                     context _: INUIHostedViewContext,
                     completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void)
  {
    // Do configuration here, including preparing views and calculating a desired size for presentation.
    completion(true, parameters, desiredSize)
  }

  var desiredSize: CGSize {
    extensionContext!.hostedViewMaximumAllowedSize
  }
}
