//
//  ContentView.swift
//  machat
//
//  Created by chenhaifeng on 2024/3/28.
//

import SwiftUI
import AppKit
import MarkdownView
import OpenAI
import RealmSwift

class MessagesViewModel: ObservableObject {
    @Published var realm: Realm
    
    private var token: NotificationToken?
    
    @Published var messages: [Message] = []
    
    init(chatId: ObjectId) {
        do {
            realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
        // 获取筛选后的Results对象
        let messagesResults = realm.objects(Message.self).filter("chatId == %@", chatId)
        
        // 将Results转换为SwiftUI可以使用的数组
        self.messages = Array(messagesResults)
        
        // 监听Results对象的变化
        token = messagesResults.observe { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                // 最初加载数据时，Results已经被筛选和转换为数组
                break
            case .update(let results, _, _, _):
                //                print(results)
                // 当数据发生变化时，更新Published属性
                self?.messages = Array(results)
            case .error(let error):
                // 处理错误
                print(error)
            }
        }
    }
    
    deinit {
        // 当ViewModel将要被销毁时，取消数据监听
        token?.invalidate()
    }
}

struct TextInput: NSViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: TextInput

        init(_ parent: TextInput) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            if let textView = notification.object as? NSTextView {
                DispatchQueue.main.async {
                    self.parent.text = textView.string
                    self.parent.height = textView.intrinsicContentSize.height
                }
            }
        }
        
        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSStandardKeyBindingResponding.insertNewline(_:)) {
                if NSEvent.modifierFlags.contains(.shift) {
                    // 如果当前按下了 Shift 键
                    textView.insertText("\n", replacementRange: textView.selectedRange())
                    return true
                } else {
                    // 处理非 Shift+Enter 的情况，例如，你可能想要执行发送操作
                    print("Enter pressed without Shift")
                    // 执行默认的 Enter 键行为
                    return true
                }
            }
            return false
        }
    
    }
    
    func makeNSView(context: Context) -> NSTextView {
        let scrollView = NSScrollView()
        let textView = NSTextView()
        textView.delegate = context.coordinator
//        textView.isVerticallyResizable = true
//        textView.isHorizontallyResizable = false
//        textView.autoresizingMask = [.width]
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        return textView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        nsView.string = text
        DispatchQueue.main.async {
            self.height = nsView.intrinsicContentSize.height
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

struct ChatView: View {
    
    @ObservedResults(Setting.self) var setting
    
    @State private var openai: OpenAIProtocol?
    
    var chatId: ObjectId
    
    @StateObject private var viewModel: MessagesViewModel
    @State private var lastMessage: String = ""

    @State private var inputText: String = ""
    @State private var inputHeight: CGFloat = 20.0  // State variable for the height
    @State private var isTextFieldDisabled: Bool = false
    @State private var showAlert = false
    
    init(chatId: ObjectId) {
        self.chatId = chatId
        _viewModel = StateObject(wrappedValue: MessagesViewModel(chatId: chatId))
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack{
                        ForEach(viewModel.messages.indices, id: \.self) { index in
                            MarkdownView(text: viewModel.messages[index].content)
                                .padding(.all, 12)
                                .foregroundColor(viewModel.messages[index].role == "system" ? nil : .white)
                                .background(
                                    viewModel.messages[index].role == "system" ? nil : LinearGradient(gradient: Gradient(colors: [bgColor1, bgColor2]), startPoint: .leading, endPoint: .trailing)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .frame(maxWidth: .infinity, alignment: viewModel.messages[index].role == "system" ? .leading : .trailing)
                                .textSelection(.enabled)
                                .id(index)
                        }
                        .onChange(of: lastMessage) { msg in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    proxy.scrollTo(viewModel.messages.count - 1, anchor: .bottomTrailing)
                                }
                            }
                        }
//                        .padding(.bottom, 10)
                    }.onAppear() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                proxy.scrollTo(viewModel.messages.count - 1, anchor: .bottomTrailing)
                                lastMessage += "\n"
                            }
                        }
                    }.onChange(of: viewModel.messages) { _ in
                        DispatchQueue.main.async {
                            withAnimation {
                                proxy.scrollTo(viewModel.messages.count - 1, anchor: .bottomTrailing)
                            }
                        }
                    }
                    .padding(.all, 10)
                }
                
            }
//            .frame(minHeight: 460).padding(.all, 0.1)
            .background(Color.white)
            inputBar()
        }.background(containerBg)
            .padding(.all, 0).padding(.top, 4)
    }
    
    
    @ViewBuilder private func inputBar() -> some View {
        HStack {
                        TextEditor(
                            text: $inputText
                        )
//            TextInput(text: $inputText, height: $inputHeight)
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
                .alert("提示🔔", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("请先设置 apikey 才可以聊天")
                }
                .padding(.leading)
            
            Button(action: {
                Task {
                    await sendMessage()
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
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTextFieldDisabled)
            
        }
        .padding(.bottom)
    }
    
    
    func sendMessage() async {
        var apiKey: String = ""
        //        var proxyUrl: String = ""
        if !setting.isEmpty {
            apiKey = setting[0].apiKey
            //            proxyUrl = setting[0].proxyUrl
        }
        if (apiKey == "") {
            showAlert = true
            return
        }
        if (self.openai == nil) {
            openai = OpenAI(apiToken: apiKey)
        }
        if inputText.isEmpty || isTextFieldDisabled {
            return
        }
        isTextFieldDisabled = true
        let newMessage = Message(msgId: UUID().uuidString, chatId: chatId, role: "user", content: inputText, time: Date())
        try! viewModel.realm.write {
            viewModel.realm.add(newMessage)
            viewModel.messages.append(newMessage)
            inputText = ""
        }
        
        do {
            var prompts: [ChatQuery.ChatCompletionMessageParam] {
                var messageParams = [ChatQuery.ChatCompletionMessageParam]()
                let lastThreeMessages = viewModel.messages.suffix(3)
                for message in lastThreeMessages {
                    // 这里假设你有一个初始化 ChatQuery.ChatCompletionMessageParam 的方法
                    let messageParam = ChatQuery.ChatCompletionMessageParam(role: message.role == "user" ? ChatQuery.ChatCompletionMessageParam.Role.user : ChatQuery.ChatCompletionMessageParam.Role.system, content: message.content)!
                    messageParams.append(messageParam)
                }
                return messageParams
            }
            
            let chatsStream: AsyncThrowingStream<ChatStreamResult, Error> = openai!.chatsStream(
                query: ChatQuery(
                    messages: prompts, model: "gpt-4", maxTokens: 1000
                )
            )
            
            for try await partialChatResult in chatsStream {
                for choice in partialChatResult.choices {
                    let messageText = choice.delta.content ?? ""
                    let msg = Message(msgId: partialChatResult.id, chatId: chatId, role: "system", content: messageText, time: Date())
                    if let existingMessageIndex = viewModel.messages.firstIndex(where: { $0.msgId == partialChatResult.id }) {
                        //                        print("update msg \(existingMessageIndex)")
                        let previousMessage = viewModel.messages[existingMessageIndex]
                        
                        let frozenObject = viewModel.messages[existingMessageIndex]
                        if frozenObject.isFrozen {
                            // Thaw the object to get a live, mutable version.
                            if let liveObject = frozenObject.thaw() {
                                // Now you can modify the live object within a write transaction.
                                try? viewModel.realm.write {
                                    liveObject.content =  previousMessage.content + msg.content
                                    lastMessage = liveObject.content
                                }
                            }
                        } else {
                            // The object is not frozen, you can modify it directly within a write transaction.
                            try? viewModel.realm.write {
                                viewModel.messages[existingMessageIndex].content = previousMessage.content + msg.content
                                lastMessage = viewModel.messages[existingMessageIndex].content
                            }
                        }
                    } else {
                        //                        print("new msg \(msg)")
                        try! viewModel.realm.write {
                            viewModel.realm.add(msg)
                            viewModel.messages.append(msg)
                        }
                    }
                }
            }
            isTextFieldDisabled = false
        } catch {
            print(error)
            isTextFieldDisabled = false
        }
    }
}
