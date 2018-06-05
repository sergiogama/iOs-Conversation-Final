//
//  RestUtils.swift
//  ChatDemo
//
//  Created by Marco Aurélio Bigélli Cardoso on 26/07/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

class RestUtils {
    
    static func messageForStatus(_ statusCode: Int) -> String {
        var message = ""
        switch(statusCode) {
        case 200:
            message = "Success"
        case 400:
            message = "Bad request (status code 400). If you are using a custom server, make sure it conforms to the corresponding Watson service interfaces. \n\n This also happens if your workspace ID is empty or incorrect"
        case 401:
            message = "Not authorized (status code 401). Make sure the credentials supplied in the Settings are correct"
        case 404:
            message = "Not found (status code 404). Please check if any custom URLs are correct."
        case 500:
            message = "Internal Server Error (status code 500). The service may be currently down, or the request may have caused it to crash. If you are using a custom server, check the logs for more info."
        case 0:
            message = "Could not resolve server. Please check if you are connected to the Internet and any custom URLs are correct."
        default:
            message = "Something went wrong (status code \(statusCode))"
        }
        
        return message
    }
    
    static func request(method: String, url: String, headers: [String:String], body: [String: Any?], username: String, password: String, success: @escaping (Data) -> (), failure: ((String) -> ())?) -> URLSessionDataTask? {
        if url.isEmpty {
            failure?("No URL supplied")
            return nil
        }
        URLSession.shared.reset(completionHandler: {})
        let request = NSMutableURLRequest(url: URL(string: url)!,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval:60)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        let credentialData = "\(username):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString()
        request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { data, response, errorzz in
            handleResponse(data, response, errorzz, success: success, failure: failure)
        }
        dataTask.resume()
        return dataTask
    }
    
    static func textToSpeechRequest(text: String,
                                    success: @escaping (Data) -> Void,
                                    failure: ((String) -> Void)?) -> URLSessionDataTask? {
        let headers = [
            "Content-type":"application/json",
            "Accept": "audio/mp3",
            ]
        let body = ["text": text]

        
        return request(method: "POST", url: Settings.voiceSynthesisURL, headers: headers, body: body, username: Settings.voiceSynthesisUsername, password: Settings.voiceSynthesisPassword, success: success, failure: failure)
    }
    
    private static func handleResponse(_ body: Data?, _ response: URLResponse?, _ error: Error?, success: @escaping (Data) -> (), failure: ((String) -> ())?) {
        if let httpResponse = (response as? HTTPURLResponse) {
            if httpResponse.statusCode == 200 {
                if let data = body {
                    success(data)
                } else {
                    failure?("No data returned from server")
                }
            } else {
                failure?(messageForStatus(httpResponse.statusCode))
            }
        } else {
            print(error?.localizedDescription ?? "No error")
            if error?.localizedDescription == "cancelled" {
                failure?("Cancelled")
            } else {
                failure?(messageForStatus(0))
            }
        }
    }
}
