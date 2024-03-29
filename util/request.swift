import Foundation

// 定义一个错误类型，用于处理网络请求错误
enum NetworkError: Error {
    case badURL
    case requestFailed(Error)
    case badResponse(Int)
    case jsonDecodingError(Error)
    case noData
}

// 定义 requestPostData 函数
func postRequest(urlString: String, data: String, headers: [String: String]? = nil, proxyUrl: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {

    let configuration = URLSessionConfiguration.default

    if (proxyUrl != "") {
        
        let components = proxyUrl.split(separator: ":")
        if components.count == 2,
           let ip = components.first,
           let portString = components.last,
           let port = Int(portString) {
            
            // 设置代理服务器
            configuration.connectionProxyDictionary = [
                kCFNetworkProxiesHTTPEnable as AnyHashable: true,
                kCFNetworkProxiesHTTPProxy as AnyHashable: ip,
                kCFNetworkProxiesHTTPPort as AnyHashable: port,
                kCFNetworkProxiesHTTPSEnable as AnyHashable: true,
                kCFNetworkProxiesHTTPSProxy as AnyHashable: ip,
                kCFNetworkProxiesHTTPSPort as AnyHashable: port,
            ]
        }
    }
    
    // 创建URLSession实例
    let session = URLSession(configuration: configuration)


    guard let url = URL(string: urlString) else {
        completion(.failure(.badURL))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
    
    guard let jsonData = data.data(using: .utf8) else {
        print("Error: 不能创建JSON数据")
        return
    }
    request.httpBody = jsonData
    
    let task = session.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(.requestFailed(error)))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
            completion(.failure(.badResponse((response as? HTTPURLResponse)?.statusCode ?? 0)))
            return
        }
        
        guard let data = data else {
            completion(.failure(.noData))
            return
        }
        
        completion(.success(data))
    }
    
    task.resume()
}
