//
//  InfoView.swift
//  BoxScore
//
//  Created by Kent Brady on 7/27/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import SwiftUI

struct InstructionCardContent<Content: View>: Identifiable {
	var title: String
	var image: Image? = nil
	var content: Content
	var details: String
	
	var id = UUID()
}

struct WhatsNewCards {
	var cards = [
		InstructionCardContent(title: "Added iPad Support",
							   content: EmptyView(),
							   details: "You can now use BoxScore on the iPad in portrait and horizontal orientations.")
	]
}

struct InfoView: View {
	@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	var whatsNewInfo = WhatsNewCards()
	
	@State private var currentIndex: Int = 0
	
    var body: some View {
		NavigationView {
			VStack {
				Spacer()
				GeometryReader { geometry in
					PagerView(pageCount: whatsNewInfo.cards.count, currentIndex: $currentIndex, highlightColor: Color.brandGreen) {
						whatsNewCards(size: cardSize(geometry.size))
					}
				}
			}
			.navigationBarTitle(Text("What's New"))
			.navigationBarItems(trailing: Button(action: {
				self.presentationMode.wrappedValue.dismiss()
			}) {
				Text("Done")
					.bold()
			})
			.navigationViewStyle(StackNavigationViewStyle())
		}
	}
	
	private func cardSize(_ size: CGSize) -> CGSize {
		CGSize(width: size.width * 0.7, height: size.height * 0.7)
	}
	
	private func whatsNewCards(size: CGSize) -> some View {
		Group {
			ForEach(whatsNewInfo.cards) { content in
				InstructionCardView(title: content.title, image: content.image, content: content.content, details: content.details, width: size.width, height: size.height)
			}
		}
	}
}

struct NewUserView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}