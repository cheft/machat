//
//  Message.swift
//  machat
//
//  Created by chenhaifeng on 2024/3/28.
//
import Foundation
import SwiftData
import SwiftUI

@Model
class Message: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var chatId: Int
    var role: String
    var content: String
    var time: Date
    init(id: String = UUID().uuidString, chatId: Int, role: String, content: String, time: Date) {
        self.id = id
        self.chatId = chatId
        self.role = role
        self.content = content
        self.time = time
    }
}

@Model
class Setting: Identifiable {
    @Attribute(.unique) var id: String = UUID().uuidString
    var apiKey: String
    var proxyUrl: String
    
    init(id: String = UUID().uuidString, apiKey: String, proxyUrl: String) {
        self.apiKey = apiKey
        self.proxyUrl = proxyUrl
    }
}
