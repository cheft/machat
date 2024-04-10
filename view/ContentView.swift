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

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
//    @Environment(\.realmConfiguration) var realmConfiguration

    @State private var showingPopup = false

    @State private var selectedItem: ChatItem?
    let data = [
        ChatItem(id: 1, icon: "message", name: "技术问答 Chat 1"),
        ChatItem(id: 2, icon: "message", name: "技术问答 Chat 2"),
        ChatItem(id: 3, icon: "message", name: "技术问答 Chat 3"),
        ChatItem(id: 4, icon: "message", name: "技术问答 Chat 4"),
        ChatItem(id: 5, icon: "message", name: "技术问答 Chat 5"),
        ChatItem(id: 6, icon: "message", name: "技术问答 Chat 6"),
        ChatItem(id: 7, icon: "message", name: "技术问答 Chat 7"),
        ChatItem(id: 8, icon: "message", name: "技术问答 Chat 8"),
        ChatItem(id: 9, icon: "message", name: "技术问答 Chat 9"),
        ChatItem(id: 10, icon: "message", name: "语言翻译 Chat 1"),
        ChatItem(id: 11, icon: "message", name: "语言翻译 Chat 2"),
        ChatItem(id: 12, icon: "message", name: "语言翻译 Chat 3"),
        ChatItem(id: 13, icon: "message", name: "语言翻译 Chat 4"),
        ChatItem(id: 14, icon: "message", name: "生活交流 Chat 1"),
        ChatItem(id: 15, icon: "message", name: "情感交流 Chat 2"),
    ]
    
//    @State private var chats: Results<Chat>
    @ObservedResults(Chat.self) var chats

    var realm: Realm
    
//    func setupRealm() {
//        do {
//            // 使用环境中的配置初始化 Realm
//            realm = try Realm(configuration: realmConfiguration)
//            
//            // 在此处使用 realm 对象
//            print("Realm file location: \(realm.configuration.fileURL!)")
//        } catch {
//            // 处理可能出现的错误
//            print("Error initializing Realm with configuration: \(error)")
//        }
//    }
    
    init() {
//        let config = Realm.Configuration(
//            schemaVersion: 1 // Increment this number by 1 from the previous version
//        )
//
//        Realm.Configuration.defaultConfiguration = config
        
        realm = try! Realm()

//        chats = realm.objects(Chat.self)
        if chats.isEmpty {
            let chat = Chat(name: "技术问答 Chat 1")
            try! realm.write {
                realm.add(chat)
            }
//            chats = realm.objects(Chat.self)
        }
    }
//    
    func deleteItem(chat: Chat) {
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
        let chat = Chat(name: "技术问答 Chat")
        try! realm.write {
            realm.add(chat)
        }
//        chats = realm.objects(Chat.self)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image(systemName: "message") // Logo 图标，可以替换为你的应用 Logo
                        .resizable()
                        .foregroundColor(primaryColor)
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding(.leading, 16)
                    
                    Text("Machat")
                        .font(.system(size: 32))
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
//                        PopupFormView(closeAction: {
//                            showingPopup = false
//                        })
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
                    ForEach(chats, id: \.self) { chat in
//                        NavigationLink(destination: ChatView(chatId: chat._id)) {
//                            Label(chat.name, systemImage: "message").padding(4)

//                        }
                        Text(chat.name).padding(4).contextMenu {
                            Button(action: {
                                // 在这里处理删除操作
                                deleteItem(chat: chat)
                            }) {
                                Text(" \(chat.name)")
                                Image(systemName: "trash")
                            }
                            // 添加更多的按钮和操作
                        }
                    }
                }

          
                // 列表项
//                List(data, id: \.self, selection: $chats) { item in
//                    NavigationLink(destination: ChatView(chatId: item.id)) {
//                        Label(item.name, systemImage: item.icon).padding(4)
//                    }
//                }
//                .navigationDestination(for: ChatItem.self) { item in
//                    ChatView(chatId: item.id)
//                }
                .onAppear {
                    // 默认选择第一个 Item
                    selectedItem = data.first
//                    modelContext.insert(Message(id: UUID().uuidString, chatId: 1, role: "system", content: "💰你好！有什么我可以帮助你的吗？", time: Date()))
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
//        .onAppear {
//                        // 在视图出现时获取 Realm 实例
//                        self.setupRealm()
//                    }
    }
    
    // 切换侧边栏的函数
    func toggleSidebar() {
#if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
#endif
    }
}
//
//#Preview {
//    ContentView()
//}
