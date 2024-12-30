//
//  Note.swift
//  MilestoneProjects19-21
//
//  Created by Антон Кашников on 03/07/2024.
//

import Foundation

struct Note: Identifiable {
    let id: UUID
    var title: String
    var text: String
    let date: Date
}

struct NoteCodable: Codable, Identifiable {
    let id: UUID
    let title: String
    let date: Date
}
