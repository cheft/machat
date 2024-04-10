//
//  Message.swift
//  machat
//
//  Created by chenhaifeng on 2024/3/28.
//
import Foundation
import SwiftData
import SwiftUI
import RealmSwift


//@Model
//class Message: Identifiable {
//    @Attribute(.unique) var id: String = UUID().uuidString
//    var chatId: ObjectId
//    var role: String
//    var content: String
//    var time: Date
//    init(id: String = UUID().uuidString, chatId: ObjectId, role: String, content: String, time: Date) {
//        self.id = id
//        self.chatId = chatId
//        self.role = role
//        self.content = content
//        self.time = time
//    }
//}
//
//@Model
//class Setting: Identifiable {
//    @Attribute(.unique) var id: String = UUID().uuidString
//    var apiKey: String
//    var proxyUrl: String
//    
//    init(id: String = UUID().uuidString, apiKey: String, proxyUrl: String) {
//        self.apiKey = apiKey
//        self.proxyUrl = proxyUrl
//    }
//}

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

