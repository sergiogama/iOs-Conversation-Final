//
//  NativeRecognitionApi
//  Watson Conversation
//
//  Created by Marco Aurélio Bigélli Cardoso on 01/08/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import Speech

class NativeRecognitionApi: RecognitionApi {
    private let recognizer: SFSpeechRecognizer
    private let audioSession: AVAudioSession
    private let audioEngine: AVAudioEngine
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var isRecognizing = false

    init(recognizer: SFSpeechRecognizer) {
        self.recognizer = recognizer
        audioSession = AVAudioSession.sharedInstance()
        audioEngine = AVAudioEngine()
    }
    
    func startRecognition(success: @escaping (String) -> Void,
                          failure: ((String) -> Void)?) {
        isRecognizing = true
        try? audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        try? audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest!.shouldReportPartialResults = true
        let recordingFormat = audioEngine.inputNode!.outputFormat(forBus: 0)
        audioEngine.inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        try? audioEngine.start()
        recognizer.recognitionTask(with: recognitionRequest!, resultHandler: { result, error in
            if self.isRecognizing {
                if let transcription = result?.bestTranscription.formattedString {
                    success(transcription)
                }
                
                if let message = error?.customMessage() {
                    failure?(message)
                }
            }
        })
    }
    
    func stopRecognition() {
        isRecognizing = false
        audioEngine.stop()
        audioEngine.inputNode?.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        try? audioSession.setActive(false)
    }

}
