import SwiftUI

public struct BrainView: View {
  @State private var data: [String] = ["Appointments", "Kyouka", "Miscellaneous", "Somthing", "Cooking"]
  @State private var isTapped = false

  public init() {}

  public var body: some View {
    NavigationView {
      ZStack {
        if isTapped {
          HStack {
            NavigationView {
              List {
                Text("Past appointments")
                Text("Future appointments")
                Text("Urgent appointments")
                Text("Upcoming appointments")
              }
              .listStyle(PlainListStyle())
              .navigationTitle(Text("Index"))
            }

            Color.black
              .frame(width: 2)

            VStack(alignment: .leading) {
              Text("NHS number: 047382734")
              Text("Personal appointment. St. Peter's surgery")
              Text("Urgent appointments")
              Text("Upcoming appointments")

              Spacer()
            }
            .padding()
          }
          .padding()
          .border(Color.black)
          .background(Color.white)
          .offset(x: 0, y: 200)
          .zIndex(1)
        }

        ScrollView(.horizontal) {
          HStack {
            ForEach($data, id: \.self) { d in
              Button {
                isTapped.toggle()
              } label: {
                ZStack {
                  Color.blue
                    .frame(width: 100)
                  Text(d.wrappedValue.uppercased())
                    .foregroundColor(Color.yellow)
                    .font(.title3)
                    .bold()
                    .fontDesign(.serif)
                    .rotationEffect(.init(degrees: -90))
                }
              }
            }
          }
        }
        .padding()
      }
      .navigationTitle(Text("BrainLibrary"))
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

struct SwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    BrainView()
  }
}
