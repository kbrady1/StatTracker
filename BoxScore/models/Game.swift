//
//  Game.swift
//  StatTracker
//
//  Created by Kent Brady on 5/11/20.
//  Copyright © 2020 Kent Brady. All rights reserved.
//

import Foundation
import CoreGraphics
import CloudKit

extension DateFormatter {
	static func defaultDateFormat(_ format: String) -> DateFormatter {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US")
		formatter.dateFormat = format
		return formatter
	}
}

private let DATE_FORMATTER = DateFormatter.defaultDateFormat("MMM dd, yyyy")

class Game: ObservableObject, Equatable {
	
	@Published var teamScore: Int {
		didSet {
			save()
		}
	}
	@Published var opponentScore: Int {
		didSet {
			save()
		}
	}
	var opponentName: String {
		didSet {
			save()
		}
	}
	
	var playersInGame: [Player] {
		didSet {
			save()
		}
	}
	
	var endDate: Date?
	var startDate: Date?
	
	var dateText: String? {
		guard let endDate = endDate else { return nil }
		return DATE_FORMATTER.string(from: endDate)
	}
	
	@Published var isComplete: Bool {
		didSet {
			guard isComplete else { return }
			endDate = Date()
			playersInGame = []
			save()
		}
	}
	
	private func save() {
		model.endDate = endDate
		model.hasEnded = isComplete
		model.opponentName = opponentName
		model.opponentScore = Int16(opponentScore)
		model.teamScore = Int16(teamScore)
		model.playersInGame = NSSet(array: playersInGame.map { $0.model })
		
		AppDelegate.instance.saveContext()
	}
	
	//These are used on the live game and live game stat view to keep track of a teams current stats
	var statDictionary = [StatType: [Stat]]()
	@Published var statCounter = [StatType: Int]()
	
	//MARK: RecordModel
	
	static func createGame(team: Team) -> Game {
		let model = GameCD(context: AppDelegate.context)
		let id = UUID()
		model.id = id
		model.opponentName = "Opponent"
		
		model.team = team.model
		model.startDate = Date()
		
		return Game(opponentName: "Opponent", model: model, id: id.uuidString)
	}
	
	private init(playersInGame: [Player] = [], hasEnded: Bool? = nil, endDate: Date? = nil, opponentName: String, opponentScore: Int? = nil, teamScore: Int? = nil, model: GameCD, id: String) {
		self.playersInGame = playersInGame
		self.isComplete = hasEnded ?? false
		self.endDate = endDate
		self.teamScore = teamScore ?? 0
		self.opponentScore = opponentScore ?? 0
		self.opponentName = opponentName
		self.id = id
		self.model = model
		self.startDate = Date()
	}
	
	let id: String
	let model: GameCD
	init(model: GameCD) throws {
		guard let id = model.id else { throw BoxScoreError.invalidModelError() }
		
		self.isComplete = model.hasEnded
		self.opponentName = model.opponentName ?? "Opponent"
		self.opponentScore = Int(model.opponentScore)
		self.teamScore = Int(model.teamScore)
		self.playersInGame = try model.playersInGame?.allObjects.compactMap { $0 as? PlayerCD }.map { try Player(model: $0) } ?? []
		self.startDate = model.startDate
		self.endDate = model.endDate
		
		self.model = model
		self.id = id.uuidString
	}
	
	//MARK: Equatable
	
	static func == (lhs: Game, rhs: Game) -> Bool {
		lhs.id == rhs.id
	}
}

class GameList: ObservableObject {
	@Published var games: [Game]
	var statDictionary = [StatType: [Stat]]()
	
	init(_ games: [Game]) {
		self.games = games
	}
	
	init(_ game: Game) {
		self.games = [game]
	}
}
