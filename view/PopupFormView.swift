import SwiftUI
import RealmSwift

class PopupFormViewModel: ObservableObject {
    let realm: Realm
    
    init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
}

struct PopupFormView: View {
    @ObservedResults(Setting.self) var setting
    
    @State private var apiKey: String = "sk-*"
    @State private var gptModel: String = "gpt-4"
    @State private var maxToken: String = "3000"
    @State private var contextNum: String = "3"
    @State private var proxyUrl: String = "127.0.0.1:7890"
    
    
    @State private var showingAlert = false
    
    var closeAction: () -> Void
    
    @StateObject private var viewModel = PopupFormViewModel()
    
    var body: some View {
        VStack {
            Form {
                Text("请输入API KEY")
                TextField("", text: $apiKey).frame(width: 420)
//                Text("&nbsp;")
//                Text("请设置模型名称")
//                TextField("", text: $gptModel).frame(width: 420)
//                Text("&nbsp;")
//                Text("请设置最大Token数")
//                TextField("", text: $maxToken).frame(width: 420)
//                Text("&nbsp;")
//                Text("请设置prompt的上下文条数")
//                TextField("", text: $contextNum).frame(width: 420)
//                
                Text("&nbsp;")
                Text("请输入模型名称")
                TextField("", text: $gptModel).frame(width: 420)
                //                Text("&nbsp;")
                //                Text("待办项：会话管理(prompt、上下文)、流式请求、聊天搜索、滚动优化")
                //                Text("待办项：模型参数设置、数据导出、数据清理、性能优化、美化主题等")
                //                Text("努力更新中...")
            }
            .onAppear {
                if !setting.isEmpty {
                    apiKey = setting[0].apiKey
                    gptModel = setting[0].gptModel
                }
            }
            .toolbar {
                HStack {
                    Button("关闭") {
                        closeAction()
                    }
                    
                    Button(action: {
                        closeAction()
                        if !setting.isEmpty {
                            let s = setting[0]
                            if s.isFrozen {
                                if let liveObject = s.thaw() {
                                    try? viewModel.realm.write {
                                        liveObject.apiKey = apiKey
                                        liveObject.gptModel = gptModel
                                    }
                                }
                            }
                            else {
                                try? viewModel.realm.write {
                                    s.apiKey = apiKey
                                    s.gptModel = gptModel
                                }
                            }
                            
                        } else {
                            try? viewModel.realm.write {
                                viewModel.realm.add(Setting(apiKey: apiKey, gptModel: gptModel))
                            }
                        }
                    }) {
                        Text("保存")
                    }
                    
                    Button(action: {
                        showingAlert = true
                    }) {
                        Text("清空记录")
                            .frame(width: 100) // 宽度
                            .padding(2) // 文字与边缘的距离（可选）
                    }
                    //                    .background(Color.purple)
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("确认"),
                              message: Text("你确定要执行此操作吗，会清空所有聊天记录哦？"),
                              primaryButton: .destructive(Text("确定")) {
                            let objectsToDelete = viewModel.realm.objects(Message.self)
                            // .filter("some_object.some_array.id = '1606213636.830755'")
                            
                            if objectsToDelete.count > 0 {
                                try! viewModel.realm.write {
                                    viewModel.realm.delete(objectsToDelete)
                                }
                            }
                        },
                              secondaryButton: .cancel()
                        )
                    }
                }
            }
        }.frame(width: 460, height: 400)
    }
}
