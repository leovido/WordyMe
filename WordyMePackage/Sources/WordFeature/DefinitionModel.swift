import Foundation

// MARK: - Definition

public struct Definition: Codable, Hashable {
  public let word, phonetic: String?
  public let phonetics: [Phonetic]
  public let origin: String?
  public let meanings: [Meaning]

  public init(word: String?, phonetic: String?, phonetics: [Phonetic], origin: String?, meanings: [Meaning]) {
    self.word = word
    self.phonetic = phonetic
    self.phonetics = phonetics
    self.origin = origin
    self.meanings = meanings
  }
}

// MARK: - Meaning

public struct Meaning: Identifiable, Hashable, Codable {
  public var id: UUID?

  public let partOfSpeech: String?
  public let definitions: [DefinitionElement]

  public init(id: UUID = .init(), partOfSpeech: String?, definitions: [DefinitionElement]) {
    self.id = id
    self.partOfSpeech = partOfSpeech
    self.definitions = definitions
  }
}

// MARK: - DefinitionElement

public struct DefinitionElement: Identifiable, Hashable, Codable {
  public var id: UUID?

  public let definition, example: String?
  public let synonyms, antonyms: [String]

  public init(id: UUID = .init(), definition: String?, example: String?, synonyms: [String], antonyms: [String]) {
    self.id = id
    self.definition = definition
    self.example = example
    self.synonyms = synonyms
    self.antonyms = antonyms
  }
}

// MARK: - Phonetic

public struct Phonetic: Codable, Hashable {
  public let text, audio: String?
}
