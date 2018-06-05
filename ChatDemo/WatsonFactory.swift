//
//  WatsonFactory.swift
//  ChatDemo
//
//  Created by Marco Aurélio Bigélli Cardoso on 03/08/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import Speech

class WatsonFactory {
    func makeWatson(config: WatsonConfig) -> Watson {
        let recognitionApi: RecognitionApi
        let timerGroup = TimerGroup()
        if config.useSpeechToText {
            recognitionApi = SpeechToTextApi(username: config.speechRecognitionUsername,
                                             password: config.speechRecognitionPassword,
                                             language: config.speechToTextLanguage)
        } else {
            let recognizer = SFSpeechRecognizer(locale: Locale(identifier: config.nativeRecognitionLanguage))
            recognitionApi = NativeRecognitionApi(recognizer: recognizer!)
        }
        let speechRecognizer = SpeechRecognizer(recognitionApi: recognitionApi, timerGroup: timerGroup)
        
        let classificationApi = ConversationApi(username: config.orchestratorUsername,
                                                password: config.orchestratorPassword,
                                                url: config.messageURL)
        
        let synthesisApi: SynthesisApi
        if config.useNativeSynthesis {
            synthesisApi = NativeSynthesisApi(language: config.nativeSynthesisVoice)
        } else {
            synthesisApi = TextToSpeechApi(username: config.voiceSynthesisUsername,
                                           password: config.voiceSynthesisPassword,
                                           language: config.textToSpeechVoice)
        }
        
        return Watson(recognizer: speechRecognizer,
                      classificationApi: classificationApi,
                      synthesisApi: synthesisApi)
    }
}

class WatsonConfig {
    var speechRecognitionUsername = ""
    var speechRecognitionPassword = ""
    var useSpeechToText = false
    var useNativeRecognition = true
    var speechToTextLanguage = ""
    var nativeRecognitionLanguage = ""
    
    var orchestratorUsername = ""
    var orchestratorPassword = ""
    var useConversation = true
    var conversationWorkspace = ""
    var customOrchestratorURL = ""
    var messageURL: String {
        if useConversation {
            return "https://gateway.watsonplatform.net/conversation/api/v1/workspaces/\(conversationWorkspace)/message?version=2017-04-21"
        } else {
            return customOrchestratorURL
        }
    }
    
    var voiceSynthesisUsername = ""
    var voiceSynthesisPassword = ""
    var useTextToSpeech = false
    var useNativeSynthesis = true
    var textToSpeechVoice = ""
    var nativeSynthesisVoice = ""
    var customVoiceSynthesisURL = ""
    var voiceSynthesisURL: String {
        if useTextToSpeech {
            return "https://stream.watsonplatform.net/text-to-speech/api/v1/synthesize?voice=\(textToSpeechVoice)"
        } else {
            return customVoiceSynthesisURL
        }
    }
    
    func saveToDisk() {
        UserDefaults.standard.set(speechRecognitionUsername, forKey: "speechRecognitionUsername")
        UserDefaults.standard.set(speechRecognitionPassword, forKey: "speechRecognitionPassword")
        UserDefaults.standard.set(useSpeechToText, forKey: "useSpeechToText")
        UserDefaults.standard.set(useNativeRecognition, forKey: "useNativeRecognition")
        UserDefaults.standard.set(speechToTextLanguage, forKey: "speechToTextLanguage")
        UserDefaults.standard.set(nativeRecognitionLanguage, forKey: "nativeRecognitionLanguage")
        
        UserDefaults.standard.set(orchestratorUsername, forKey: "orchestratorUsername")
        UserDefaults.standard.set(orchestratorPassword, forKey: "orchestratorPassword")
        UserDefaults.standard.set(useConversation, forKey: "useConversation")
        UserDefaults.standard.set(conversationWorkspace, forKey: "conversationWorkspace")
        UserDefaults.standard.set(customOrchestratorURL, forKey: "customOrchestratorURL")
        
        UserDefaults.standard.set(voiceSynthesisUsername, forKey: "voiceSynthesisUsername")
        UserDefaults.standard.set(voiceSynthesisPassword, forKey: "voiceSynthesisPassword")
        UserDefaults.standard.set(useTextToSpeech, forKey: "useTextToSpeech")
        UserDefaults.standard.set(useNativeSynthesis, forKey: "useNativeSynthesis")
        UserDefaults.standard.set(textToSpeechVoice, forKey: "textToSpeechVoice")
        UserDefaults.standard.set(nativeSynthesisVoice, forKey: "nativeSynthesisVoice")
        UserDefaults.standard.set(customVoiceSynthesisURL, forKey: "customVoiceSynthesisURL")
    }
    
    func loadFromDisk() {
        speechRecognitionUsername = UserDefaults.standard.value(forKey: "speechRecognitionUsername") as? String ?? ""
        speechRecognitionPassword = UserDefaults.standard.value(forKey: "speechRecognitionPassword") as? String ?? ""
        useSpeechToText = UserDefaults.standard.value(forKey: "useSpeechToText") as? Bool ?? false
        useNativeRecognition = UserDefaults.standard.value(forKey: "useNativeRecognition") as? Bool ?? true
        speechToTextLanguage = UserDefaults.standard.value(forKey: "speechToTextLanguage") as? String ?? "en-US_BroadbandModel"
        nativeRecognitionLanguage = UserDefaults.standard.value(forKey: "nativeRecognitionLanguage") as? String ?? "en-US"
        
        orchestratorUsername = UserDefaults.standard.value(forKey: "orchestratorUsername") as? String ?? ""
        orchestratorPassword = UserDefaults.standard.value(forKey: "orchestratorPassword") as? String ?? ""
        useConversation = UserDefaults.standard.value(forKey: "useConversation") as? Bool ?? true
        conversationWorkspace = UserDefaults.standard.value(forKey: "conversationWorkspace") as? String ?? ""
        customOrchestratorURL = UserDefaults.standard.value(forKey: "customOrchestratorURL") as? String ?? ""
        
        voiceSynthesisUsername = UserDefaults.standard.value(forKey: "voiceSynthesisUsername") as? String ?? ""
        voiceSynthesisPassword = UserDefaults.standard.value(forKey: "voiceSynthesisPassword") as? String ?? ""
        useTextToSpeech = UserDefaults.standard.value(forKey: "useTextToSpeech") as? Bool ?? false
        useNativeSynthesis = UserDefaults.standard.value(forKey: "useNativeSynthesis") as? Bool ?? true
        textToSpeechVoice = UserDefaults.standard.value(forKey: "textToSpeechVoice") as? String ?? "en-US_MichaelVoice"
        nativeSynthesisVoice = UserDefaults.standard.value(forKey: "nativeSynthesisVoice") as? String ?? "en-US"
        customVoiceSynthesisURL = UserDefaults.standard.value(forKey: "customVoiceSynthesisURL") as? String ?? ""
    }
}
