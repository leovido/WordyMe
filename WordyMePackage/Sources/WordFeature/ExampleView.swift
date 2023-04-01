import SwiftUI

struct ExampleView: View {
    let example: String?

    var body: some View {
        if let example {
            Text("Example")
                .font(.headline)
            Text(example)
                .italic()
        }
        Divider()
            .padding(.bottom, 16)
    }
}

struct ExampleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExampleView(example: "this is an example")
            ExampleView(example: nil)
        }
        .previewLayout(.sizeThatFits)
    }
}
