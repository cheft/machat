//
//  Message.swift
//  machat
//
//  Created by chenhaifeng on 2024/3/28.
//
import Foundation
import SwiftUI
import RealmSwift

class Chat: Object, ObjectKeyIdentifiable {
   @Persisted(primaryKey: true) var _id: ObjectId
   @Persisted var name: String = ""
   
    convenience init(name: String) {
       self.init()
       self.name = name
   }
}


class Setting: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var apiKey: String = ""
//    @Persisted var gptModel: String = ""
//    @Persisted var maxToken: Int = 3000
//    @Persisted var contextNum: Int = 10
    @Persisted var proxyUrl: String = ""
    
    convenience init(apiKey: String, proxyUrl: String) {
       self.init()
       self.apiKey = apiKey
       self.proxyUrl = proxyUrl
    }
}

class Message: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var msgId: String
    @Persisted var chatId: ObjectId
    @Persisted var role: String
    @Persisted var content: String
    @Persisted var time: Date
    
    convenience init(msgId: String, chatId: ObjectId, role: String, content: String, time: Date) {
        self.init()
        self.msgId = msgId
        self.chatId = chatId
        self.role = role
        self.content = content
        self.time = time
    }
}

