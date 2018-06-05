//
//  MainViewController.swift
//  PinacoApp
//
//  Created by Gustavo Vicentini on 12/5/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit


private var myContext = 0
//preload gifs

class MainViewController: UIViewController {
    @IBOutlet weak var watsonImage: UIImageView?
    @IBOutlet weak var speechButton: UIButton?

    fileprivate let wIdle = UIImage.gif(name: "watson_idle")
    fileprivate let wQuestion = UIImage.gif(name: "watson_question")
    fileprivate let wAnswer = UIImage.gif(name: "watson_answer")
    fileprivate let wThink = UIImage.gif(name: "watson_think")
        
    var watson: Watson?
    var chatViewController: ChatViewController?
    
    override func viewDidLoad() {
        // Making sure old users get their documents folder cleaned up
        CacheUtils.clearDocuments()
        
        super.viewDidLoad()
        speechButton?.setTitle("Tap to record", for: .normal)
        watsonImage?.image = wIdle
        chatViewController = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        Settings.loadFromDisk()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        watson = Settings.makeWatson()
        chatViewController?.watson = watson
        watson?.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        watson?.stop()
    }
    
    @IBAction func speechButtonTapped(_ sender: AnyObject) {
        if watson?.state == .idle {
//            watson?.test()
            watson?.start()
        } else {
            watson?.stop()
        }
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        show(chatViewController!, sender: self)
    }
}

// MARK: - WatsonDelegate
extension MainViewController: WatsonDelegate {
    func watson(_ watson: Watson, didChangeState newState: WatsonState) {
        DispatchQueue.main.async {
            switch newState {
            case .idle:
                self.speechButton?.setTitle("Tap to record", for: .normal)
                self.watsonImage?.image = self.wIdle
            case .listening:
                self.speechButton?.setTitle("Listening...", for: .normal)
                self.watsonImage?.image = self.wQuestion
            case .classifying:
                self.speechButton?.setTitle("Classifying...", for: .normal)
                self.watsonImage?.image = self.wThink
            case .synthesizing:
                self.speechButton?.setTitle("Synthesizing...", for: .normal)
                self.watsonImage?.image = self.wThink
            case .speaking:
                self.speechButton?.setTitle("Speaking...", for: .normal)
                self.watsonImage?.image = self.wAnswer
            }
        }
    }
    
    func watson(_ watson: Watson, didSendQuestion question: String) {
        chatViewController?.newMessage(withMessageText: question, senderId: "1", senderDisplayName: "User")
    }
    
    func watson(_ watson: Watson, didGetAnswer answer: String) {
        chatViewController?.newMessage(withMessageText: answer, senderId: "2", senderDisplayName: "Watson")
    }
    
    func watson(_ watson: Watson, didFailAt module: String, reason: String) {
        DispatchQueue.main.async {
                UIHelper.simpleAlert(title: module + " Error", text: reason, owner: UIApplication.topViewController()!)
        }
    }
    
    
}
