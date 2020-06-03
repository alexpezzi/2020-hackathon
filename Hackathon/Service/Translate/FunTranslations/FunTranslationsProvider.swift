//
//  FunTranslationsProvider.swift
//  Hackathon
//
//  Created by alexpezzi on 2020-06-03.
//  Copyright © 2020 Accedo. All rights reserved.
//

import Foundation
import Combine

enum FunTranslationsError: Error {
	case invalidRequest
}

final class FunTranslationsProvider {
	
	private let key: String
	private let session: URLSession = .shared
	
	init(key: String = "yoda") {
		self.key = key
	}
	
	func makeRequest(message: String) -> URLRequest? {
		let urlString = "https://api.funtranslations.com/translate/\(key).json"
		
		guard let url = URL(string: urlString) else {
			return nil
		}
		
		var request = URLRequest(url: url)
		
		request.httpMethod = "POST"
		
		let body = "text=\(message)"
		request.httpBody = body.data(using: .utf8)
		
		return request
	}
}

extension FunTranslationsProvider: TranslationProvider {
	
	func fetch(message: String) -> AnyPublisher<String, Error> {
		guard let request = makeRequest(message: message) else {
			return Fail(error: FunTranslationsError.invalidRequest)
				.eraseToAnyPublisher()
		}
		
		func transform(response: Response) -> String {
			response.contents.translated
		}
		
		return session
			.dataTaskPublisher(for: request)
			.map({ $0.data })
			.decode(type: Response.self, decoder: JSONDecoder())
			.map(transform)
			.eraseToAnyPublisher()
	}
}

/**
{
    “success”: {
        “total”: 1
    },
    “contents”: {
        “translated”: “Force be with you”,
        “text”: “hello”,
        “translation”: “yoda”
    }
}
*/

private struct Response: Codable {
	let contents: Contents
}

private struct Contents: Codable {
	let translated: String
}
