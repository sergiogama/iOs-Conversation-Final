//
//  VoiceSynthesizer.swift
//  Watson Conversation
//
//  Created by Marco Aurélio Bigélli Cardoso on 20/01/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox

class TextToSpeechApi: NSObject, SynthesisApi, AVAudioPlayerDelegate {
    private var username: String
    private var password: String
    private var language: String
    
    private var speechStartBlock: (() -> Void)?
    private var successBlock: (() -> Void)?
    private var errorBlock: ((String) -> Void)?
    
    private var player: AVAudioPlayer?
    
    private var cacheOn = true
    var currentRequest: URLSessionDataTask?
    var currentText = ""
    var filename: String {
        let prefix = Settings.useTextToSpeech ? Settings.textToSpeechVoice : Settings.voiceSynthesisURL
        return String(prefix.hash) + "_" + String(currentText.lowercased().hash) + ".mp3"
    }
    
    init(username: String = Settings.speechRecognitionUsername,
         password: String = Settings.speechRecognitionPassword,
         language: String = Settings.speechToTextLanguage) {
        self.username = username
        self.password = password
        self.language = language
    }
    
    func synthesize(text: String,
                    speechStart: (() -> Void)?,
                    success: (() -> Void)?,
                    failure error: ((String) -> Void)?) {
        
        currentText = text
        speechStartBlock = speechStart
        successBlock = success
        errorBlock = error
        
        if text == "" {
            successBlock?()
            return
        }
        
        if let data = CacheUtils.read(from: filename) {
            play(audio: data)
            return
        }
        
        currentRequest = RestUtils.textToSpeechRequest(text: text,
            success: { data in
                self.play(audio: data)
                if self.cacheOn {
                    CacheUtils.write(to: self.filename, data: data)
                }
                self.cacheOn = true
            }, failure: errorBlock)
    }
    
    func cancel() {
        cacheOn = false
        currentRequest?.cancel()
        player?.stop()
        player = nil
    }
    
    func play(audio: Data) {
        speechStartBlock?()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(data: audio, fileTypeHint: AVFileTypeWAVE)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
            
        } catch let error {
            print(error.localizedDescription)
            if error.localizedDescription == "The operation couldn’t be completed. (OSStatus error 1954115647.)" {
                errorBlock?("Invalid audio file format. Only MP3 is supported in this app.")
            } else if error.localizedDescription == "The operation couldn’t be completed. (OSStatus error -39.)" {
                // Audio is empty, not really an error
            } else {
                errorBlock?(error.localizedDescription)
            }
        }
    }
    
    
    // MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        successBlock?()
        self.player = nil
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print(error?.localizedDescription ?? "No error")
    }
    
}
