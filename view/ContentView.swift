//
//  ContentView.swift
//  test-swiftui
//
//  Created by chenhaifeng on 2024/3/28.
//

import SwiftUI
import RealmSwift

struct ChatItem: Hashable, Identifiable {
    let id: Int
    let icon: String
    let name: String
}

struct EditableTextField: View {
    @State private var text: String
    var onSave: (String) -> Void
    
    init(text: String, onSave: @escaping (String) -> Void) {
        _text = State(initialValue: text)
        self.onSave = onSave
    }
    
    var body: some View {
        TextField("Enter name", text: $text, onCommit: {
            onSave(text)
        })
    }
}

struct ContentView: View {
    
    @State private var showingPopup = false
    @State private var selectedChatId: ObjectId?
    
    @State private var showingAlert = false
    
    @ObservedResults(Chat.self) var chats
    
    var realm: Realm
    
    init() {
        realm = try! Realm()
        if chats.isEmpty {
            let chat = Chat(name: "技术问答 Chat 1")
            try! realm.write {
                realm.add(chat)
            }
        }
    }
    
    func deleteItem(chat: Chat) {
        let objectsToDelete = realm.objects(Message.self).filter("chatId = %@", chat._id)
        if objectsToDelete.count > 0 {
            try! realm.write {
                realm.delete(objectsToDelete)
            }
        }

        guard let chatInRealm = realm.object(ofType: Chat.self, forPrimaryKey: chat._id) else {
            // 如果chat对象不属于当前Realm实例，可以进行适当的错误处理
            print("Error: Chat object does not belong to the current Realm instance.")
            return
        }
        
        // 删除属于当前Realm实例的chat对象
        try! realm.write {
            realm.delete(chatInRealm)
        }
    }
    
    func addItem() {
        let chat = Chat(name: "问答 Chat \(chats.count + 1)")
        try! realm.write {
            realm.add(chat)
        }
    }
    
    func updateItem(chat: Chat, newName: String) {
        if chat.isFrozen {
            if let liveObject = chat.thaw() {
                try? realm.write {
                    liveObject.name = newName
                }
            }
        }
        else {
            try? realm.write {
                chat.name = newName
            }
        }
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image(systemName: "message.fill")
                        .resizable()
                        .foregroundColor(primaryColor)
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding(.leading, 16)
                    
                    Text("Machat")
                        .font(.system(size: 24))
                        .font(.headline)
                        .padding(.leading, 8)
                    
                    Spacer()
                    
                    // 设置按钮，位于最右侧
                    Button(action: {
                        // 设置按钮的动作
                        showingPopup = true
                    }) {
                        Image(systemName: "gear")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 10) // 设置按钮与容器右边界的距离
                    .sheet(isPresented: $showingPopup) {
                        PopupFormView(closeAction: {
                            showingPopup = false
                        })
                    }
                }
                .padding(.vertical)
                
                Divider()
                
                HStack {
                    Spacer()
                    Button(action: addItem) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .padding(.trailing, 20)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .listRowInsets(EdgeInsets())
                
                List {
                    ForEach(chats.reversed(), id: \.self) { chat in
                        NavigationLink(destination: ChatView(chatId: chat._id), tag: chat._id, selection: $selectedChatId) {
                            // Label("\(chat.name)@\(chat._id)", systemImage: "message").padding(4)
                            EditableTextField(text: chat.name) { newName in
                                updateItem(chat: chat, newName: newName)
                            }
                            Image(systemName: "message")
                        }.contextMenu {
                            Button(action: {
                                deleteItem(chat: chat)
                            }) {
                                Text(" \(chat.name)")
                                Image(systemName: "trash")
                            }
                        }.padding(.top, 4).padding(.bottom, 6).padding(.leading, 4)
                    }
                }
                .onAppear {
                    // 默认选择第一个 Item
                    selectedChatId = chats.first?._id
                }
                .listStyle(SidebarListStyle())
                .frame(minWidth: 220, idealWidth: 250, maxWidth: 300, maxHeight: .infinity)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button(action: toggleSidebar) {
                            Image(systemName: "sidebar.leading")
                        }
                    }
                }
            }
        }
    }
    
    // 切换侧边栏的函数
    func toggleSidebar() {
#if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
#endif
    }
}
