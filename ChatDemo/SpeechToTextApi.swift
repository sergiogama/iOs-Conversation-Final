//
//  SpeechToTextApi.swift
//  ChatDemo
//
//  Created by Marco Aurélio Bigélli Cardoso on 01/08/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import SpeechToTextV1

class SpeechToTextApi: RecognitionApi {
    let sdkInstance: SpeechToText
    let language: String
    
    init(username: String,
         password: String,
         language: String) {
        self.sdkInstance = SpeechToText(username: username, password: password)
        self.language = language
    }
    
    func startRecognition(success: @escaping (String) -> Void,
                          failure: ((String) -> Void)?) {
        
        sdkInstance.recognizeMicrophone(settings: defaultSettings(),
                                        model: language,
                                        customizationID: nil,
                                        learningOptOut: false,
                                        compress: true,
                                        failure: { error in
                                            failure?((error as Error).customMessage()!)
                                        },
                                        success: { results in
                                            success(results.bestTranscript)
                                        }
        )
    }
    
    func stopRecognition() {
        sdkInstance.stopRecognizeMicrophone()
    }
    
    private func defaultSettings() -> RecognitionSettings {
        var settings = RecognitionSettings(contentType: .opus)
        settings.interimResults = true
        // settings.continuous = true
        return settings
    }
}
