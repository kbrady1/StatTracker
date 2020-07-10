//
//  PlayerView.swift
//  StatTracker
//
//  Created by Kent Brady on 5/11/20.
//  Copyright © 2020 Brigham Young University. All rights reserved.
//

import SwiftUI

struct PlayerInGameView: View {
	@EnvironmentObject var game: Game
	var player: Player
	var shadow: Bool = true
	var color: Color = .clear
	var height: CGFloat = 80
	
	var body: some View {
		PlayerView(player: player, shadow: shadow, color: color, height: height)
			.if(game.playersOnBench.contains(player)) {
				$0.onDrag {
					return NSItemProvider(object: self.player)
				}
			}
	}
}

struct PlayerView: View {
	var player: Player
	var shadow: Bool = true
	var color: Color = .clear
	var height: CGFloat = 80
	
    var body: some View {
		return ZStack {
			VStack {
				Text(String(player.number))
					.font(.largeTitle)
				Text(player.lastName)
					.font(.caption)
			}
			.background(Color.clear)
		}
		.frame(width: height, height: height, alignment: .center)
		.background(DefaultCircleView(color: color, shadow: shadow))
	}
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
		let view = PlayerView(player: Player(lastName: "Brady", firstName: "Kent", number: 12))
			.environmentObject(Game.previewData)
			.previewLayout(.fixed(width: 120, height: 120))
		
		return view
    }
}

extension View {
	func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
		if conditional {
			return AnyView(content(self))
		} else {
			return AnyView(self)
		}
	}
}

struct DefaultCircleView: View {
	@State var color = Color.white
	var shadow: Bool = true
	
	var body: some View {
		CircleView(color: $color, shadow: shadow)
	}
}

struct CircleView: View {
	@Binding var color: Color
	var shadow: Bool = true
	
	var body: some View {
		BlurView(style: .systemThinMaterial)
			.background(color)
			.clipShape(Circle())
			.shadow(radius: shadow ? 3 : 0)
	}
}