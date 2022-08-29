//
//  TT.swift
//  Watch App WatchKit Extension
//
//  Created by SSB4455 on 2022/8/24.
//  Copyright © 2022 SSB4455. All rights reserved.
//

import WatchConnectivity

class WCtest: NSObject {
    @Published var message = ""
    
    
    
    override init() {
        super.init()
        
        configureWCSession()
    }
    
    func sendTestMsg() {
        sendMessageToiPhone(["Message": "test", "Count": arc4random() % 100, "Booleam": true])
    }
    
    func configureWCSession() {
        // Don't need to check isSupport state, because session is always available on WatchOS
        // if WCSession.isSupported() {}
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    func sendMessageToiPhone(_ message: [String: Any]) {
        if !WCSession.default.isReachable {
            print("!WCSession.default.isReachable")
            self.message = "!WCSession.default.isReachable"
            /*let action = WKAlertAction(title: "OK", style: .default) {
                print("OK")
            }
            presentAlert(withTitle: "Failed", message: "Apple Watch is not reachable.", preferredStyle: .alert, actions: [action])*/
            return
        } else {
            // The counterpart is not available for living messageing
        }
        
        //let message = ["title": "Apple Watch send a messge to iPhone", "watchMessage": watchMessage]
        WCSession.default.sendMessage(message, replyHandler: { (replyMessage) in
            print(replyMessage)
            DispatchQueue.main.sync {
                print(replyMessage["replyContent"] as? String ?? "")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}


// MARK: - WCSessionDelegate
extension TT: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if error == nil {
            print("\(activationState)")
        } else {
            print(error!.localizedDescription)
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print(session)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print(#function + "\(message)")
        self.message = "\(message)"
        replyHandler(["title": "received successfully", "replyContent": "This is a reply from watch"])
    }
}
