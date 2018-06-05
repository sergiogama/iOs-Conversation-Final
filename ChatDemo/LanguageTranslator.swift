//
//  LanguageTranslator.swift
//  ChatDemo
//
//  Created by Marco Aurélio Bigélli Cardoso on 28/08/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

// - MARK: Interface
protocol LanguageTranslatorInterface {
    func translate(text: String,
                  success: @escaping (String) -> (),
                  failure: @escaping (String) -> ())
    func cancel()
}


// - MARK: Implementation
class LanguageTranslator: LanguageTranslatorInterface {

    let username: String
    let password: String
    let source: String
    let target: String
    
    init(username: String, password: String,
         source: String, target: String) {
        self.username = username
        self.password = password
        self.source = source
        self.target = target
    }
    
    func translate(text: String, success: @escaping (String) -> (), failure: @escaping (String) -> ()) {

    }
    
    func cancel() {
        
    }
    
}

protocol TranslationApi {
    func translate(text: String,
                   source: String,
                   target: String,
                   success: @escaping (String) -> (),
                   failure: @escaping (String) -> ())
}

class WatsonTranslator: TranslationApi {
    func translate(text: String, source: String, target: String, success: @escaping (String) -> (), failure: @escaping (String) -> ()) {
        
    }

    
}
