////
////  ContentView.swift
////  test-swiftui
////
////  Created by chenhaifeng on 2024/3/28.
////
//
//import SwiftData
//import SwiftUI
//import MarkdownView
//import OpenAI
//import RealmSwift
//
//struct ChatView: View {
//    @Environment(\.modelContext) private var context
//    
//    @Query var setting: [Setting]
//    
//    @State private var openai: OpenAIProtocol?
//
//    var chatId: ObjectId = ObjectId()
//    
//    //    @Query(filter: #Predicate<Message> { $0.chatId == 1 })
//    //    @Query(
//    //        filter: #Predicate<Message> { $0.chatId == chatId },
//    //        sort: [
//    //            SortDescriptor(\Message.time, order: .reverse) // order: .reverse
//    //        ]
//    //    )
////    @Query 
//    
//    @State var messages: [Message] = []
//    
//    
//    @State private var inputText: String = ""
//    @State private var isTextFieldDisabled: Bool = false
//    @State private var showAlert = false
//    
////    init(chatId: ObjectId) {
////        self.chatId = chatId
//////        let predicate = #Predicate<Message> {
//////            $0.chatId == chatId
//////        }
//////        
//////        _messages = Query(filter: predicate, sort: \.time) // order: .reverse
////    }
//  
//    var body: some View {
//        VStack {
//            ScrollView {
//                ScrollViewReader { proxy in
//                    LazyVStack{
//                        ForEach(messages.indices, id: \.self) { index in
//                            MarkdownView(text: self.messages[index].content)
//                                .padding(.all, 12)
//                                .foregroundColor(self.messages[index].role == "system" ? nil : .white)
//                                .background(
//                                    self.messages[index].role == "system" ? nil : LinearGradient(gradient: Gradient(colors: [bgColor1, bgColor2]), startPoint: .leading, endPoint: .trailing)
//                                )
//                                .clipShape(RoundedRectangle(cornerRadius: 15))
//                                .frame(maxWidth: .infinity, alignment: self.messages[index].role == "system" ? .leading : .trailing)
//                                .listRowSeparator(.hidden)
//                                .textSelection(.enabled)
//                                .id(index)
//                        }
//                    }.onAppear() {
//                        proxy.scrollTo(messages.count - 1, anchor: .bottom)
//                    }.onChange(of: messages) {
//                        proxy.scrollTo(messages.count - 1, anchor: .bottom)
//                    }.padding(.all, 10)
//                }
//
//            }.frame(minHeight: 460).padding(.all, 0.1).background(Color.white)
//            inputBar()
//        }.background(containerBg).padding(.all, 0).padding(.top, 4)
//    }
//    
//    
//    @ViewBuilder private func inputBar() -> some View {
//        HStack {
//            TextEditor(
//                text: $inputText
//            )
//            .padding(.vertical, -8)
//            .padding(.horizontal, -4)
//            .frame(minHeight: 20, maxHeight: 100)
//            .foregroundColor(.primary)
//            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
//            .font(.system(size: 13))
//            .background(
//                RoundedRectangle(
//                    cornerRadius: 16,
//                    style: .continuous
//                )
//                .fill(Color.white)
//                .overlay(
//                    RoundedRectangle(
//                        cornerRadius: 16,
//                        style: .continuous
//                    )
//                    .stroke(
//                        Color.white,
//                        lineWidth: 1
//                    )
//                )
//            )
//            .fixedSize(horizontal: false, vertical: true)
//            .onSubmit {
//                withAnimation {
////                    tapSendMessage(scrollViewProxy: scrollViewProxy)
////                    sendMessage()
//                }
//            }
//            .alert("提示🔔", isPresented: $showAlert) {
//                Button("OK", role: .cancel) { }
//            } message: {
//                Text("请先设置 apikey 才可以聊天")
//            }
//            .padding(.leading)
//
//            Button(action: {
//                Task {
//                    await sendMessage()
//                }
//            }) {
//                Image(systemName: "paperplane")
//                    .resizable()
//                    .foregroundColor(primaryColor)
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 24, height: 24)
//                    .padding(.trailing)
//            }
//            .buttonStyle(PlainButtonStyle())
//            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTextFieldDisabled)
//            
//        }
//        .padding(.bottom)
//    }
//    
//    
//    func sendMessage() async {
//        var apiKey: String = ""
////        var proxyUrl: String = ""
//        if !setting.isEmpty {
//            apiKey = setting[0].apiKey
////            proxyUrl = setting[0].proxyUrl
//        }
//        if (apiKey == "") {
//            showAlert = true
//            return
//        }
//        if (self.openai == nil) {
//            openai = OpenAI(apiToken: apiKey)
//        }
//        if inputText.isEmpty || isTextFieldDisabled {
//            return
//        }
//        isTextFieldDisabled = true
//        let newMessage = Message(id: UUID().uuidString, chatId: chatId, role: "user", content: inputText, time: Date())
//        messages.append(newMessage)
////        context.insert(newMessage)
//        
//        do {
//            let prompts = messages.map { message in
//                ChatQuery.ChatCompletionMessageParam(role: message.role == "user" ? ChatQuery.ChatCompletionMessageParam.Role.user : ChatQuery.ChatCompletionMessageParam.Role.system, content: message.content)!
//            }
//            
//            inputText = ""
//            print(prompts)
//            
//            let chatsStream: AsyncThrowingStream<ChatStreamResult, Error> = openai!.chatsStream(
//                query: ChatQuery(
//                    messages: prompts, model: "gpt-4", maxTokens: 250
//                )
//            )
//            
//            for try await partialChatResult in chatsStream {
//                for choice in partialChatResult.choices {
//                    let messageText = choice.delta.content ?? ""
//                    let msg = Message(id: partialChatResult.id, chatId: chatId, role: "system", content: messageText, time: Date())
//                    if let existingMessageIndex = messages.firstIndex(where: { $0.id == partialChatResult.id }) {
//                        print("update msg \(existingMessageIndex)")
//                        let previousMessage = messages[existingMessageIndex]
//                        messages[existingMessageIndex].content = previousMessage.content + msg.content
//                    } else {
//                        print("new msg \(msg)")
//                        messages.append(msg)
////                        context.insert(msg)
//                    }
//                }
//            }
//            isTextFieldDisabled = false
//        } catch {
//            print(error)
//            isTextFieldDisabled = false
//        }
//        
//        
////        let urlString = "https://api.openai.com/v1/chat/completions"
////        //        let urlString = "http://localhost:11434/api/chat"
////        
////        let postData = """
////        {
////            "model": "gpt-4",
////            "temperature": 0,
////            "format": "json",
////            "messages": [
////                {"role": "user", "content": "\(inputText)"}
////            ]
////        }
////        """
////        
////        let customHeaders = [
////            "Authorization": "Bearer \(apiKey)",
////        ]
////        
//
////        postRequest(urlString: urlString, data: postData, headers: customHeaders, proxyUrl: proxyUrl) { result in
////            switch result {
////            case .success(let data):
//////                if let rawJSONString = String(data: data, encoding: .utf8) {
//////                   print("返回的原始JSON字符串：\(rawJSONString)")
//////                }
////                isTextFieldDisabled = false
////                do {
////                    // 尝试将JSON数据反序列化为Any
////                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
////                        // 尝试获取choices数组
////                        if let choices = json["choices"] as? [[String: Any]] {
////                            // 获取第一个choice对象
////                            if let firstChoice = choices.first {
////                                // 尝试获取message字典
////                                if let message = firstChoice["message"] as? [String: Any] {
////                                    // 尝试读取content和role
////                                    if let content = message["content"] as? String {
////                                        let msg = Message(id: UUID().uuidString, chatId: chatId, role: "system", content: content, time: Date())
////                                        context.insert(msg)
////                                    }
////                                }
////                            }
////                        }
////                    }
////                } catch {
////                    print("解析JSON时发生错误：\(error)")
////                }
////            case .failure(let error):
////                isTextFieldDisabled = false
////                print("Error: \(error)")
////                // 在这里处理错误
////            }
////        }
//    }
//}
