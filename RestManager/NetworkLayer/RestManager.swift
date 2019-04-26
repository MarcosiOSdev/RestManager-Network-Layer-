//
//  RestManager.swift
//  RestManager
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation

class RestManager {
    var requestHttpHeaders = RestEntity()
    var urlQueryParameters = RestEntity()
    var httpBodyParameters = RestEntity()
    
    var httpBody: Data?
    
    func makeRequest(toURL url: URL,
                     withHttpMethod httpMethod: HttpMethod,
                     completion: @escaping (_ result: Results) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            let targetURL = self?.addURLQueryParameters(toURL: url)
            let httpBody = self?.httpBody
            guard let request = self?.prepareRequest(withURL: targetURL, httpBody: httpBody, httpMethod: httpMethod) else
            {
                completion(Results(withError: CustomError.failedToCreateRequest))
                return
            }
            
            let sessionConfiguration = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfiguration)
            let task = session.dataTask(with: request) { (data, response, error) in
                completion(Results(withData: data,
                                   response: Response(fromURLResponse: response),
                                   error: error))
            }
            task.resume()
        }
    }
    
    func getData(fromURL url: URL, completion: @escaping (_ data: Data?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let sessionConfiguration = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfiguration)
            let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
                guard let data = data else { completion(nil); return }
                completion(data)
            })
            task.resume()
        }
    }
    
    
    private func addURLQueryParameters(toURL url: URL) -> URL {
        if urlQueryParameters.totalItems() > 0 {
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
            
            var queryItems = [URLQueryItem]()
            for (key, value) in urlQueryParameters.allValues() {
                let item = URLQueryItem(name: key, value: value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
                queryItems.append(item)
            }
            urlComponents.queryItems = queryItems
            
            guard let updatedURL = urlComponents.url else { return url }
            return updatedURL
        }
        
        return url
    }
    
    private func getHttpBody() -> Data? {
        guard let contentType = requestHttpHeaders.value(forKey: "Content-Type") else { return nil }
        
        if contentType.contains("application/json") {
            return try? JSONSerialization.data(withJSONObject: httpBodyParameters.allValues(), options: [.prettyPrinted, .sortedKeys])
        
        } else if contentType.contains("application/x-www-form-urlencoded") {
            let bodyString = httpBodyParameters.allValues().map { "\($0)=\(String(describing: $1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)))" }.joined(separator: "&")
            return bodyString.data(using: .utf8)
        
        } else {
            return httpBody
        }
    }
    
    private func prepareRequest(withURL url: URL?, httpBody: Data?, httpMethod: HttpMethod) -> URLRequest? {
        guard let url = url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue.uppercased()
        
        for (header, value) in requestHttpHeaders.allValues() {
            request.setValue(value, forHTTPHeaderField: header)
        }
        
        request.httpBody = httpBody
        return request
    }
    
}

extension RestManager {
    
}





struct Response {
    var response: URLResponse?
    var httpStatusCode: Int = 0
    var headers = RestEntity()
    
    init(fromURLResponse response: URLResponse?) {
        guard let response = response else { return }
        self.response = response
        httpStatusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        
        if let headerFields = (response as? HTTPURLResponse)?.allHeaderFields {
            for (key, value) in headerFields {
                headers.add(value: "\(value)", forKey: "\(key)")
            }
        }
    }
}

struct Results {
    var data: Data?
    var response: Response?
    var error: Error?
    
    init(withData data: Data?, response: Response?, error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }
    
    init(withError error: Error) {
        self.error = error
    }
}




