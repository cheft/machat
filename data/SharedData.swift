//
//  GlobalData.swift
//  test-swiftui
//
//  Created by chenhaifeng on 2024/3/28.
//

import SwiftUI
import Combine

class SharedData: ObservableObject {
    @Published var counter: Int = 0
}


class TextPublisher: ObservableObject {
    @Published var text: String = ""
}

var textPublisher = TextPublisher()
