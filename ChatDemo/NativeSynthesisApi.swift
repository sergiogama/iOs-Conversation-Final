//
//  NativeVoiceSynthesizer.swift
//  Watson Conversation
//
//  Created by Marco Aurélio Bigélli Cardoso on 27/04/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import Speech

class NativeSynthesisApi: NSObject, SynthesisApi, AVSpeechSynthesizerDelegate {
    
    let synthesizer = AVSpeechSynthesizer()
    
    private var language: String
    private var speechStartBlock: (() -> Void)?
    private var successBlock: (() -> Void)?

    init(language: String = Settings.nativeSynthesisVoice) {
        self.language = language
        super.init()
        synthesizer.delegate = self
    }
    
    func synthesize(text: String,
                    speechStart: (() -> Void)?,
                    success: (() -> Void)?,
                    failure: ((String) -> Void)?) {
        speechStartBlock = speechStart
        successBlock = success

        try? AVAudioSession.sharedInstance().setActive(true, with: .notifyOthersOnDeactivation)
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        
        synthesizer.speak(utterance)
    }

    func cancel() {
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
    }
    
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        speechStartBlock?()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        successBlock?()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        successBlock?()
    }
    
}
