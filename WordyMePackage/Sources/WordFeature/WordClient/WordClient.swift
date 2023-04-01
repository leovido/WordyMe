import Dependencies
import Foundation

public struct WordClient {
    public var fetchWord: (String) async -> [Definition]

    public init(fetchWord: @escaping (String) async -> [Definition]) {
        self.fetchWord = fetchWord
    }
}

extension WordClient: DependencyKey {
    public static var liveValue: WordClient {
        WordClient { word in
            let url = Constants.BASE_URL!.appending(path: word)
            let request = URLRequest(url: url)

            guard let (data, response) = try? await URLSession.shared.data(for: request),
                  let response = response as? HTTPURLResponse,
                  (200 ..< 399).contains(response.statusCode),
                  let definition = try? JSONDecoder().decode([Definition].self, from: data)
            else {
                return []
            }

            return definition
        }
    }
}

extension WordClient: TestDependencyKey {
    public static var testValue: WordClient {
        WordClient { _ in
            [Definition(word: "String", phonetic: nil, phonetics: [], origin: nil, meanings: [])]
        }
    }
}

public extension DependencyValues {
    var wordClient: WordClient {
        get { self[WordClient.self] }
        set { self[WordClient.self] = newValue }
    }
}
