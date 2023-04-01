import Foundation
import Dependencies

public struct WordClient {
	public var fetchWord: (String) async -> [Definition]
	
	public init(fetchWord: @escaping (String) async -> [Definition]) {
		self.fetchWord = fetchWord
	}
}

extension WordClient: DependencyKey {
	public static var liveValue: WordClient {
		WordClient { word in
			do {
				let url = Constants.BASE_URL!.appending(path: word)
				let request = URLRequest(url: url)
				let (data, _) = try await URLSession.shared.data(for: request)
				let definition = try JSONDecoder().decode([Definition].self, from: data)
				
				return definition
			} catch {
				print(error)
			}
			
			return []
		}
	}
	
}

extension WordClient: TestDependencyKey {
	public static var testValue: WordClient {
		WordClient { _ in
			return [Definition.init(word: nil, phonetic: nil, phonetics: [], origin: nil, meanings: [])]
		}
	}
}

extension DependencyValues {
	public var wordClient: WordClient {
		get { self[WordClient.self] }
		set { self[WordClient.self] = newValue }
	}
}
