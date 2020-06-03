//
//  JokeView.swift
//  Hackathon
//
//  Created by alexpezzi on 2020-06-03.
//  Copyright © 2020 Accedo. All rights reserved.
//

import SwiftUI

struct JokeView: View {
	
	@ObservedObject var viewModel: JokeViewModel
	
    var body: some View {
		ZStack {
			
			
			VStack {
				Button(action: {
					self.viewModel.fetch()
				}) {
					Text("New")
				}
				
				makeView().padding()
			}
			
		}
		.onAppear {
			self.viewModel.fetch()
		}
		
    }
	
	private func makeView() -> AnyView {
		switch viewModel.state {
		case .loading:
			return AnyView(ActivityIndicator())
		case .result(let output):
			
			let view = VStack(spacing: 20) {
				Text(output.joke).font(.headline)
				Text(output.translation)
			}
			
			return AnyView(view)
		case .failed(let error):
			return AnyView(Text(error.localizedDescription))
		}
	}
}


