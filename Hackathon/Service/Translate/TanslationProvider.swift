//
//  TanslationProvider.swift
//  Hackathon
//
//  Created by alexpezzi on 2020-06-03.
//  Copyright © 2020 Accedo. All rights reserved.
//

import Combine

protocol TranslationProvider {
	func fetch(message: String) -> AnyPublisher<String, Error>
}
