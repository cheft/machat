//
//  test_swiftuiApp.swift
//  test-swiftui
//
//  Created by chenhaifeng on 2024/3/28.
//
import SwiftData
import SwiftUI

@main
struct MachatApp: App {
    var sharedData = SharedData()
    @State private var searchText = ""

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(sharedData).modelContainer(for: [Message.self, Setting.self]) // 设置消息模型的模型容器
                .frame(minWidth: 800, minHeight: 600)
                .toolbar {
                    // 搜索框和设置按钮
                    ToolbarItem(placement: .automatic) {
                        HStack {
                            // 搜索框
                            TextField("搜索", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle()).padding(40).frame(width: 520)
                        }
                        // HStack 自适应宽度
                    }
                }
                .onAppear {
                    // 设置窗口的样式
                    if let window = NSApplication.shared.windows.first {
                        window.titleVisibility = .hidden // 隐藏标题
                        window.titlebarAppearsTransparent = true // 透明的标题栏
                        window.styleMask.insert(.fullSizeContentView) // 允许内容视图延伸到标题栏
                    }
                }
        }
    }
}
