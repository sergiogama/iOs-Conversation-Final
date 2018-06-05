//
//  ConversationApi.swift
//  ChatDemo
//
//  Created by Marco Aurélio Bigélli Cardoso on 01/08/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

class ConversationApi: ClassificationApi {
    let username: String
    let password: String
    let url: String
    var currentRequest: URLSessionDataTask?
    var lastContext: [String : Any?] = [:]
    
    init(username: String,
         password: String,
         url: String) {
        self.username = username
        self.password = password
        self.url = url
    }
    func classify(text: String,
                  success: @escaping (String) -> (),
                  failure: ((String) -> ())?) {
        let headers = ["Content-type":"application/json"]
        let body = ["input": ["text": text], "context": lastContext]
        currentRequest = RestUtils.request(method: "POST",
                                           url: url,
                                           headers: headers,
                                           body: body,
                                           username: username,
                                           password: password,
                                           success: { data in
                                            if let (answer, context) = self.parseConversationResponse(data) {
                                                self.lastContext = context
                                                success(answer)
                                            } else {
                                                failure?("Parsing error. If using a custom server, make sure it conforms to the corresponding Watson service interface")
                                            }
        },
                                           failure: { error in
                                            print(error)
                                            failure?(error)
        }
        )
    }
    
    func cancel() {
        
    }
    
    private func parseConversationResponse(_ data: Data?) -> (String, [String: Any?])? {
        if let dict = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any?],
            let output = dict?["output"] as? [String: Any?],
            let answerArray = output["text"] as? [String],
            let context = dict?["context"] as? [String: Any?] {
            return (answerArray.joined(separator: " "), context)
        }
        return nil
    }
    
}
