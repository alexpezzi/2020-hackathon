//
//  JokeAPIProvider.swift
//  Hackathon
//
//  Created by alexpezzi on 2020-06-03.
//  Copyright © 2020 Accedo. All rights reserved.
//

import Foundation
import Combine

enum JokeAPIError: Error, CustomStringConvertible {
	case invalidRequest
	case invalidResponse(reason: String)
	
	var description: String {
		switch self {
		case .invalidRequest:
			return "Invalid request"
		case .invalidResponse(let reason):
			return "Invalid response with reason: \(reason)"
		}
	}
}

final class JokeAPIProvider {
	
	enum Category: String {
		case progamming
		case miscellaneous
		case dark
	}
	
	enum Flags: String {
		case nsfw
		case religious
		case political
		case racist
		case sexist
	}
	
	enum JokeType: String, Codable {
		case single
		case twopart
	}
	
	private let categories: [Category]
	private let blacklist: [Flags]
	private let jokeTypes: [JokeType]
	private let session: URLSession = .shared
	
	init(categories: [Category], blacklist: [Flags], jokeTypes: [JokeType]) {
		self.categories = categories
		self.blacklist = blacklist
		self.jokeTypes = jokeTypes
	}
	
	private var categoryPath: String {
		if categories.isEmpty {
			return "All"
		}
		else {
			return categories.map({ $0.rawValue }).joined(separator: ",")
		}
	}
	
	private func makeRequest() -> URLRequest? {
		
//		var components = URLComponents()
//
//		components.scheme = "https"
//		components.host = "sv443.net"
//		components.path = "jokeapi/v2/joke/\(categoryPath)"
//
//		var queryItems: [URLQueryItem] = []
//
//		if !blacklist.isEmpty {
//			let value = blacklist.map({ $0.rawValue }).joined(separator: ",")
//			queryItems.append(.init(name: "blacklistFlags", value: value))
//		}
//
//		if !jokeTypes.isEmpty, let type = jokeTypes.first {
//			queryItems.append(.init(name: "type", value: type.rawValue))
//		}
//
//		components.queryItems = queryItems
//
//		guard let url = components.url else {
//			return nil
//		}
//
		let urlString = "https://sv443.net/jokeapi/v2/joke/Any"
		guard let url = URL(string: urlString) else {
			return nil
		}
		return URLRequest(url: url)
	}
}

extension JokeAPIProvider: JokesProvider {
	
	var name: String {
		let categories = self.categories.map { $0.rawValue }.joined(separator: ", ")
		let blacklist = self.blacklist.map { $0.rawValue }.joined(separator: ", ")
		let types = self.jokeTypes.map { $0.rawValue }.joined(separator: ", ")
		return "JokeAPI [\(categories)] [\(blacklist)] [\(types)]"
	}
	
	func fetch() -> AnyPublisher<String, Error> {
		guard let request = makeRequest() else {
			return Fail(error: JokeAPIError.invalidRequest)
				.eraseToAnyPublisher()
		}
		
		func jokeTransformer(joke: Joke) throws -> String {
			switch joke.type {
			case .single:
				guard let single = joke.joke else {
					throw JokeAPIError.invalidResponse(reason: "Invalid single joke response.")
				}
				return single
			case .twopart:
				guard let setup = joke.setup, let delivery = joke.delivery else {
					throw JokeAPIError.invalidResponse(reason: "Invalid two part joke response.")
				}
				return "\(setup)\n\(delivery)"
			}
		}
		
		return session.dataTaskPublisher(for: request)
			.map({ $0.data })
			.decode(type: Joke.self, decoder: JSONDecoder())
			.tryMap(jokeTransformer)
			.eraseToAnyPublisher()
	}
}

private struct Joke: Codable {
	let type: JokeAPIProvider.JokeType
	let joke: String?
	let setup: String?
	let delivery: String?
}
