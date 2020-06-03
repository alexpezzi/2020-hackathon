//
//  JokesProvider.swift
//  Hackathon
//
//  Created by alexpezzi on 2020-06-03.
//  Copyright © 2020 Accedo. All rights reserved.
//

import Foundation
import Combine

/// Jokes Provider
protocol JokesProvider {
	
	/// Provider name.
	var name: String { get }
	
	/// Fetch random joke.
	func fetch() -> AnyPublisher<String, Error>
}
