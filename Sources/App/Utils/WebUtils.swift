//
//  WebRequest.swift
//  WebRequest
//
//  Created by Mac Mini on 12/9/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

// Convenience string.trim()
extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


//typealias Parameters = [String:Any]
typealias Callback   = (_ response: WebResponse) -> Void

class WebResponse {
    var isError      : Bool    = false
    var error        : Error?  = nil
    var statusCode   : Int     = 0
    var mimeType     : String  = ""
    var content      : String  = ""
    var file         : URL?    = nil
    var data         : Data?   = nil
    var json         : NSDictionary? = nil
    var response     : URLResponse?  = nil
    var httpResponse : HTTPURLResponse?  = nil
    
    func setError(_ error: Error) {
        self.error   = error
        self.isError = true
    }
}

/* Use:

    let web = WebRequest()
    web.headers.append("User-Agent: WebRequest 1.0")
    web.get("http://google.com", ["q":"swift"]) { response in
        if response.isError {
            print("Error requesting url: ", response.error)
            return
        }
        print("Successful request")
        print("Status code: ", response.statusCode)
        print("Mime type:   ", response.mimeType)
        print("Content:     ", response.content)
        print("JSON:        ", response.json)
    }

*/

// All methods have convenience String/URL argument
// Remember to grant internet access rights in info.plist
class WebRequest {
    
    var headers = [String]()
    
    // web.get("http://google.com?q=swift") { response in }
    func get(_ url: String, callback: @escaping Callback) throws {
        try? self.get(URL(string: url)!, params: [:], callback: callback)
    }
    
    // web.get("http://google.com", params:["q":"swift"]) { response in }
    func get(_ url: String, params: Parameters, callback: @escaping Callback) throws {
        try? self.get(URL(string: url)!, params: params, callback: callback)
    }
    
    func get(_ url: URL, callback: @escaping Callback) throws {
        try? self.get(url, params: [:], callback: callback)
    }
    
    func get(_ url: URL, params: Parameters, callback: @escaping Callback) throws {
        var location = url
        
        if params.count > 0 {
            var path = URLComponents(url: url, resolvingAgainstBaseURL: false)
            for item in params {
                let part = URLQueryItem(name: item.key, value: item.value as? String)
                path?.queryItems?.append(part)
            }
            location = (path?.url)!
        }
        
        var request = URLRequest(url: location)
        request.httpMethod = "GET"
        parseHeaders(&request)

        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            let result = self.handleResponse(data, response, error)
            callback(result)
        }
        task.resume()
    }
    
    // Post urlencoded key=vaue&key=value pairs like html form
    // web.post("http://example.com", params: ["first":"taylor", "last":"swift"]) { response in }
    func post(_ url: String, params: Parameters, callback: @escaping Callback) throws {
        try? self.post(URL(string: url)!, params: params, callback: callback)
    }
    
    func post(_ url: URL, params: Parameters, callback: @escaping Callback) throws {
        var body = ""
        if params.count > 0 {
            body = params.map{ "\($0.0)=\($0.1)" }.joined(separator: "&")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        parseHeaders(&request)
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            let result = self.handleResponse(data, response, error)
            callback(result)
        }
        task.resume()
    }
    
    // Post text as body
    // web.post("http://example.com", text: "Lorem ipsum dolor sit amet") { response in }
    func post(_ url: String, text: String, callback: @escaping Callback) throws {
        try? self.post(URL(string: url)!, text: text, callback: callback)
    }

    func post(_ url: URL, text: String, callback: @escaping Callback) throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = text.data(using: .utf8)
        parseHeaders(&request)
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            let result = self.handleResponse(data, response, error)
            callback(result)
        }
        task.resume()
    }
    
    // Post serialized json as body. For sending json as text use method above
    // web.post("http://example.com", json: json) { response in }
    func post(_ url: String, json: Data, callback: @escaping Callback) throws {
        try? self.post(URL(string: url)!, json: json, callback: callback)
    }
    
    func post(_ url: URL, json: Data, callback: @escaping Callback) throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = json
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        parseHeaders(&request)

        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            let result = self.handleResponse(data, response, error)
            callback(result)
        }
        task.resume()
    }
    
    // web.put("http://example.com", text: "Lorem ipsum dolor sit amet") { response in }
    func put(_ url: String, text: String, callback: @escaping Callback) throws {
        try? self.put(URL(string: url)!, text: text, callback: callback)
    }

    func put(_ url: URL, text: String, callback: @escaping Callback) throws {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = text.data(using: .utf8)
        parseHeaders(&request)
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            let result = self.handleResponse(data, response, error)
            callback(result)
        }
        task.resume()
    }
    
    // web.delete("http://example.com/user/taylor") { response in }
    func delete(_ url: String, callback: @escaping Callback) throws {
        try? self.delete(URL(string: url)!, callback: callback)
    }
    
    func delete(_ url: URL, callback: @escaping Callback) throws {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        parseHeaders(&request)
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            let result = self.handleResponse(data, response, error)
            callback(result)
        }
        task.resume()
    }
    
    // Util that parses headers splitting text like "field:header"
    func parseHeaders( _ request: inout URLRequest) {
        if headers.count > 0 {
            for item in headers {
                let parts = item.components(separatedBy: ":")
                if parts.count > 1, let field = parts.first, let header = parts.last {
                    request.addValue(header.trim(), forHTTPHeaderField: field.trim())
                }
            }
        }
    }

    // Util that parses the response into components to send back to requestor
    private func handleResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> WebResponse {
        let result = WebResponse()
        result.data = data
        result.response = response
        
        guard error == nil else {
            result.setError(error!)
            return result
        }
        
        result.mimeType     = (response?.mimeType)!
        result.httpResponse = response as? HTTPURLResponse
        result.statusCode   = result.httpResponse?.statusCode ?? 0
        
        if let data = data {
            if let html = String(data: data, encoding: .utf8) {
                result.content = html
            }
            if let json = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? NSDictionary {
                result.json = json
            }
        }
        
        return result
    }
    
    /* Use:
        let web = WebRequest()
        web.download(from: webUrl, to: fileUrl) { response in
            if response.isError { 
                print("Error downloading file from ", webUrl)
                print(response.error)
            else {
                print("File downloaded successfully")
                print("Location: ", response.file)
            }
        }
    */
    
    func download(from url: URL, to file: URL, callback: @escaping (_ response: WebResponse?) -> Void) throws {
        let task = URLSession.shared.downloadTask(with: url){ location, response, error in
            let web = WebResponse()
            web.response = response
            web.file = file
            
            guard location != nil && error == nil else {
                web.setError(error!)
                callback(web)
                return
            }

            do {
                let filer = FileManager.default
                try filer.moveItem(at: location!, to: file)
                callback(web)
            } catch {
                web.setError(error)
                callback(web)
            }
        }
        task.resume()
    }

}
