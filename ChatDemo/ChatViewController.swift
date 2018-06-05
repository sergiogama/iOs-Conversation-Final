//
//   ViewController.swift
//   FDCConversation
//

import UIKit
import JSQMessages


class ChatViewController: JSQMessagesViewController {
    var watson: Watson?
	var messages = [JSQMessage]()
}

extension ChatViewController {
	
	override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        watson?.answer(question: text)
	}
    
    func newMessage(withMessageText text: String!, senderId: String!, senderDisplayName: String!) {
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        messages.append(message!)
        DispatchQueue.main.async(execute: finishSendingMessage)
    }
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
		let message = messages[indexPath.row]
		let messageUsername = message.senderDisplayName
		
		return NSAttributedString(string: messageUsername!)
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
		return 15
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
		return nil
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
		let bubbleFactory = JSQMessagesBubbleImageFactory()
		
		let message = messages[indexPath.row]
		
		if message.senderId == "1" {
			return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.init(displayP3Red: 0/255, green: 163/255, blue: 241/255, alpha: 1))
		} else {
			return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.init(displayP3Red: 12/255, green: 142/255, blue: 128/255, alpha: 1))
		}
	}
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return messages.count
	}
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        dismissKeyboard()
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapCellAt indexPath: IndexPath!, touchLocation: CGPoint) {
        dismissKeyboard()
    }
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
		return messages[indexPath.row]
	}
}

extension ChatViewController {
	override func viewDidLoad() {
        super.viewDidLoad()
        
		collectionView?.backgroundColor = UIColor.init(displayP3Red: 27/255, green: 38/255, blue: 42/255, alpha: 1)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        collectionView.addGestureRecognizer(tap)
		self.senderId = "1"
		self.senderDisplayName = UIDevice.current.name
		self.inputToolbar.contentView.leftBarButtonItem = nil
	}
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        // Workaround to make chat scroll to bottom
        super.viewDidAppear(true)
    }
    override func viewDidAppear(_ animated: Bool) {
    }
}
