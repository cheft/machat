//
//  ContentView.swift
//  test-swiftui
//
//  Created by chenhaifeng on 2024/3/28.
//

import SwiftUI

struct ChatItem: Hashable, Identifiable {
    let id: Int
    let icon: String
    let name: String
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

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
                        PopupFormView(closeAction: {
                            showingPopup = false
                        })
                    }
                }
                .padding(.vertical)
                
                Divider()
                
                // 列表项
                List(data, id: \.self, selection: $selectedItem) { item in
                    NavigationLink(destination: ChatView(chatId: item.id)) {
                        Label(item.name, systemImage: item.icon).padding(4)
                    }
                }
                .navigationDestination(for: ChatItem.self) { item in
                    ChatView(chatId: item.id)
                }
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
    }
    
    // 切换侧边栏的函数
    func toggleSidebar() {
#if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
#endif
    }
}

#Preview {
    ContentView()
}
