//
//  SpeechRecognizer.swift
//  Watson Conversation
//
//  Created by Marco Aurélio Bigélli Cardoso on 01/08/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import AVFoundation

// - MARK: Interface
protocol SpeechRecognizerInterface {
    func startRecognition(success: @escaping (String) -> (), failure: @escaping (String) -> ())
    func cancel()
}

// - MARK: Implementation

class SpeechRecognizer: NSObject, AVAudioRecorderDelegate, SpeechRecognizerInterface {
    static let allowedTimeSinceStart: Double = 15.0
    static let allowedTimeBetweenWords: Double = 2.0
    
    private var successBlock: ((String) -> ())?
    private var failureBlock: ((String) -> ())?
    
    private let recognitionApi: RecognitionApi
    private var timerGroup: TimerGroup?
    
    private var transcriptedText: String = ""
    
    var isRecognizing: Bool = false
    
    init(recognitionApi: RecognitionApi, timerGroup: TimerGroup) {
        self.recognitionApi = recognitionApi
        self.timerGroup = timerGroup
    }
    
    func startRecognition(success: @escaping (String) -> (),
                          failure: @escaping (String) -> ()) {
        successBlock = success
        failureBlock = failure
        isRecognizing = true
        timerGroup?.newTimer(block: stopRecognition, interval: SpeechRecognizer.allowedTimeSinceStart)
        
        recognitionApi.startRecognition(success: { transcription in
                                            if self.isRecognizing {
                                                print(transcription)
                                                self.transcriptedText = transcription
                                                self.timerGroup?.cancelAll()
                                                self.timerGroup?.newTimer(block: self.stopRecognition, interval: SpeechRecognizer.allowedTimeBetweenWords)
                                            }
                                        },
                                        failure: { error in
                                            print(error)
                                            self.transcriptedText = ""
                                            self.stopRecognition()
                                            if error.contains("RestKit.RestError error 0") {
                                                self.failureBlock?("")
                                            }
                                            self.failureBlock?(error)
                                        }
        )
    }
    
    func cancel() {
        transcriptedText = ""
        stopRecognition()
    }
    
    private func stopRecognition() {
        guard isRecognizing else {
            return
        }
        timerGroup?.cancelAll()
        recognitionApi.stopRecognition()
        if !transcriptedText.isEmpty {
            successBlock?(transcriptedText)
        }
        isRecognizing = false
        transcriptedText = ""
    }
    
}


