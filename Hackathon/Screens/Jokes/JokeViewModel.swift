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

final class JokeViewModel: ObservableObject {
	
	@Published var state: State<String> = .loading
	
	private let provider: JokesProvider
	private var disposeBag: Set<AnyCancellable> = .init()
	
	init(provider: JokesProvider) {
		self.provider = provider
	}
	
	func fetch() {
		state = .loading
		disposeBag = .init()
		provider
			.fetch()
			.receive(on: RunLoop.main)
			.sink(receiveCompletion: { completion in
				switch completion {
				case .failure(let error):
					self.state = .failed(error)
				default:
					return
				}
			}) { value in
				self.state = .result(value)
			}
			.store(in: &disposeBag)
	}
}
