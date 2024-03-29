import SwiftUI
import SwiftData

struct PopupFormView: View {
    @Environment(\.modelContext) private var context

    @Query var setting: [Setting]
    
    @State private var apiKey: String = "sk-*"
    @State private var proxyUrl: String = "127.0.0.1:7890"
    
    var closeAction: () -> Void
    
    var body: some View {
        VStack {
            Form {
                Text("请输入API KEY")
                TextField("", text: $apiKey).frame(width: 420)
                Text("&nbsp;")
                Text("请输入代理地址")
                TextField("", text: $proxyUrl).frame(width: 420)
                
                Text("&nbsp;")
                Text("待办项：会话管理(prompt)、聊天搜索、聊天排序、数据清理、性能优化等")
            }
            .onAppear {
                if !setting.isEmpty {
                    apiKey = setting[0].apiKey
                    proxyUrl = setting[0].proxyUrl
                }
            }
            .toolbar {
                HStack {
                    Button("关闭") {
                        closeAction()
                    }
                    
                    Button(action: {
                        if !setting.isEmpty {
                            setting[0].apiKey = apiKey
                            setting[0].proxyUrl = proxyUrl
                        } else {
                            context.insert(Setting(apiKey: apiKey, proxyUrl: proxyUrl))
                        }
                        // 处理保存逻辑
                        closeAction()
                    }) {
                        Text("保存")
                    }
                }
            }
        }.frame(width: 460, height: 220)
    }
}
