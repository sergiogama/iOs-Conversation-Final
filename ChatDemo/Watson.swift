
//  Watson.swift
//  Watson Conversation
//
//  Created by Marco Aurélio Bigélli Cardoso on 19/01/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox

class Watson: NSObject {
    
    weak var delegate: WatsonDelegate?
    var state: WatsonState = .idle
    
    private let speechRecognizer: SpeechRecognizerInterface
    private let classificationApi: ClassificationApi
    private let synthesisApi: SynthesisApi
    
    private var scheduledActions: [() -> Void] = []
    private var lastTranscription = ""
    private var lastAnswer = ""
    
    init(recognizer: SpeechRecognizerInterface,
         classificationApi: ClassificationApi,
         synthesisApi: SynthesisApi) {
        speechRecognizer = recognizer
        self.classificationApi = classificationApi
        self.synthesisApi = synthesisApi
    }
    
    deinit {
        print("Watson deinit")
    }
    
    func start() {
        scheduledActions.append(classify)
        scheduledActions.append(synthesize)
        recognize()
    }
    
    func answer(question: String) {
        lastTranscription = question
        classify()
    }
    
    func test() {
        lastTranscription = "O que é inteligência artificial"
        scheduledActions.append(synthesize)
        classify()
    }
    
    func stop() {
        scheduledActions.removeAll()
        switch state {
        case .idle: break
        case .listening: speechRecognizer.cancel()
        case .classifying: classificationApi.cancel()
        default: synthesisApi.cancel()
        }
        setState(.idle)
    }
    
    fileprivate func setState(_ newState: WatsonState) {
        state = newState
        delegate?.watson(self, didChangeState: newState)
        if state == .idle && !scheduledActions.isEmpty {
            scheduledActions.removeFirst()()
        }
    }
    
    private func recognize() {
        setState(.listening)
        speechRecognizer.startRecognition(success: { transcription in
                                            self.lastTranscription = transcription
                                            self.setState(.idle)
        },
                                          failure: { reason in
                                            self.throwError(module: "Recognition", reason: reason)
        })
    }
    private func classify() {
        setState(.classifying)
        delegate?.watson(self, didSendQuestion: lastTranscription)
        classificationApi.classify(text: lastTranscription,
                                    success: { answer in
                                        self.lastAnswer = answer
                                        self.setState(.idle)
                                        self.delegate?.watson(self, didGetAnswer: answer)
        },
                                    failure: { reason in
                                        self.throwError(module: "Orchestration", reason: reason)
        })
    }
    private func synthesize() {
        setState(.synthesizing)
        synthesisApi.synthesize(text: lastAnswer,
                                    speechStart: { self.setState(.speaking) },
                                    success: { self.setState(.idle) },
                                    failure: { reason in
                                        self.throwError(module: "Synthesis", reason: reason)
        })
    }
    
    private func throwError(module: String, reason: String) {
        stop()
        delegate?.watson(self, didFailAt: module, reason: reason)
    }
}

enum WatsonState {
    case idle
    case listening
    case classifying
    case synthesizing
    case speaking
}

protocol WatsonDelegate: class {
    func watson(_ watson: Watson, didChangeState newState: WatsonState)
    func watson(_ watson: Watson, didSendQuestion question: String)
    func watson(_ watson: Watson, didGetAnswer answer: String)
    func watson(_ watson: Watson, didFailAt module: String, reason: String)
}
