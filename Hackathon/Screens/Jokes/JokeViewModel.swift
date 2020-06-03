//
//  JokeViewModel.swift
//  Hackathon
//
//  Created by alexpezzi on 2020-06-03.
//  Copyright © 2020 Accedo. All rights reserved.
//

import Foundation
import Combine

enum State<T> {
	case loading
	case result(T)
	case failed(Error)
}

struct Output {
	let joke: String
	let translation: String
}

final class JokeViewModel: ObservableObject {
	
	@Published var state: State<Output> = .loading
	
	private let jokesProvider: JokesProvider
	private let translationsProvider: TranslationProvider
	private var disposeBag: Set<AnyCancellable> = .init()
	
	init(jokesProvider: JokesProvider, translationsProvider: TranslationProvider) {
		self.jokesProvider = jokesProvider
		self.translationsProvider = translationsProvider
	}
	
	func fetch() {
		state = .loading
		disposeBag = .init()
		
		jokesProvider
			.fetch()
			.receive(on: RunLoop.main)
			.sink(receiveCompletion: { completion in
				switch completion {
				case .failure(let error):
					self.state = .failed(error)
				default:
					return
				}
			}) { [weak self] value in
				self?.fetchTranslation(message: value)
			}
			.store(in: &disposeBag)
	}
	
	private func fetchTranslation(message: String) {
		translationsProvider
			.fetch(message: message)
			.receive(on: RunLoop.main)
			.sink(receiveCompletion: { completion in
				switch completion {
				case .failure(let error):
					self.state = .failed(error)
				default:
					return
				}
			}) { value in
				self.state = .result(Output(joke: message, translation: value))
			}
			.store(in: &disposeBag)
	}
}
