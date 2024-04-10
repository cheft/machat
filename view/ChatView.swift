//
//  ContentView.swift
//  test-swiftui
//
//  Created by chenhaifeng on 2024/3/28.
//

import SwiftData
import SwiftUI
import MarkdownView

struct ChatView: View {
    @Environment(\.modelContext) private var context
    
    @Query var setting: [Setting]
    
    var chatId: Int = 1
    
    //    @Query(filter: #Predicate<Message> { $0.chatId == 1 })
    //    @Query(
    //        filter: #Predicate<Message> { $0.chatId == chatId },
    //        sort: [
    //            SortDescriptor(\Message.time, order: .reverse) // order: .reverse
    //        ]
    //    )
    @Query var messages: [Message] = []
    
    
    @State private var inputText: String = ""
    @State private var isTextFieldDisabled: Bool = false
    @State private var showAlert = false
    
    init(chatId: Int) {
        self.chatId = chatId
        let predicate = #Predicate<Message> {
            $0.chatId == chatId
        }

        _messages = Query(filter: predicate, sort: \.time) // order: .reverse
    }
  
    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack{
                        ForEach(messages.indices, id: \.self) { index in
                            MarkdownView(text: self.messages[index].content)
                                .padding(.all, 12)
                                .foregroundColor(self.messages[index].role == "system" ? nil : .white)
                                .background(
                                    self.messages[index].role == "system" ? nil : LinearGradient(gradient: Gradient(colors: [bgColor1, bgColor2]), startPoint: .leading, endPoint: .trailing)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .frame(maxWidth: .infinity, alignment: self.messages[index].role == "system" ? .leading : .trailing)
                                .listRowSeparator(.hidden)
                                .textSelection(.enabled)
                                .id(index)
                        }
                    }.onAppear() {
                        proxy.scrollTo(messages.count - 1, anchor: .bottom)
                    }.onChange(of: messages) {
                        proxy.scrollTo(messages.count - 1, anchor: .bottom)
                    }.padding(.all, 10)
                }

            }.frame(minHeight: 460).padding(.all, 0.1).background(Color.white)
            inputBar()
        }.background(containerBg).padding(.all, 0).padding(.top, 4)
    }
    
    
    @ViewBuilder private func inputBar() -> some View {
        HStack {
            TextEditor(
                text: $inputText
            )
            .padding(.vertical, -8)
            .padding(.horizontal, -4)
            .frame(minHeight: 20, maxHeight: 100)
            .foregroundColor(.primary)
            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            .font(.system(size: 13))
            .background(
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                    .stroke(
                        Color.white,
                        lineWidth: 1
                    )
                )
            )
            .fixedSize(horizontal: false, vertical: true)
            .onSubmit {
                withAnimation {
//                    tapSendMessage(scrollViewProxy: scrollViewProxy)
                    sendMessage()
                }
            }
            .padding(.leading)

            Button(action: {
                withAnimation {
//                    tapSendMessage(scrollViewProxy: scrollViewProxy)
                    sendMessage()
                }
            }) {
                Image(systemName: "paperplane")
                    .resizable()
                    .foregroundColor(primaryColor)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .padding(.trailing)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.bottom)
    }
    
    
    func sendMessage() {
        var apiKey: String = ""
        var proxyUrl: String = ""
        if !setting.isEmpty {
            apiKey = setting[0].apiKey
            proxyUrl = setting[0].proxyUrl
        }
        if (apiKey == "") {
            showAlert = true
            return
        }
        if inputText.isEmpty || isTextFieldDisabled {
            return
        }
        isTextFieldDisabled = true
        let newMessage = Message(id: UUID().uuidString, chatId: chatId, role: "user", content: inputText, time: Date())
        context.insert(newMessage)
        let urlString = "https://api.openai.com/v1/chat/completions"
        //        let urlString = "http://localhost:11434/api/chat"
        
        let postData = """
        {
            "model": "gpt-4",
            "temperature": 0,
            "format": "json",
            "messages": [
                {"role": "user", "content": "\(inputText)"}
            ]
        }
        """
        
        let customHeaders = [
            "Authorization": "Bearer \(apiKey)",
        ]
        
        inputText = ""
        
        postRequest(urlString: urlString, data: postData, headers: customHeaders, proxyUrl: proxyUrl) { result in
            switch result {
            case .success(let data):
//                if let rawJSONString = String(data: data, encoding: .utf8) {
//                   print("返回的原始JSON字符串：\(rawJSONString)")
//                }
                isTextFieldDisabled = false
                do {
                    // 尝试将JSON数据反序列化为Any
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // 尝试获取choices数组
                        if let choices = json["choices"] as? [[String: Any]] {
                            // 获取第一个choice对象
                            if let firstChoice = choices.first {
                                // 尝试获取message字典
                                if let message = firstChoice["message"] as? [String: Any] {
                                    // 尝试读取content和role
                                    if let content = message["content"] as? String {
                                        let msg = Message(id: UUID().uuidString, chatId: chatId, role: "system", content: content, time: Date())
                                        context.insert(msg)
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    print("解析JSON时发生错误：\(error)")
                }
            case .failure(let error):
                isTextFieldDisabled = false
                print("Error: \(error)")
                // 在这里处理错误
            }
        }
    }
}

