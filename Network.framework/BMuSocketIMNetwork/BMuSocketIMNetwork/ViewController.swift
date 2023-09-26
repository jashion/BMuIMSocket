//
//  ViewController.swift
//  BMuSocketIMNetwork
//
//  Created by Jashion on 2023/9/25.
//

import UIKit
import Network

class ViewController: UIViewController {
    var connection:NWConnection?
    var receivedData:Data?
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func initConnect() {
        guard connection == nil else {
            return
        }
        let paramters = NWParameters.tcp
        paramters.prohibitedInterfaceTypes = [.wifi, .cellular]
        //使用ipv6
//        if let option = paramters.defaultProtocolStack.internetProtocol as? NWProtocolIP.Options {
//            option.version = .v6
//        }
        paramters.preferNoProxies = true

        connection = NWConnection(host: NWEndpoint.Host("127.0.0.1"), port: NWEndpoint.Port(integerLiteral: 10069), using: paramters)
    }
    
    func connect() {
        initConnect()
        connection?.stateUpdateHandler = {[weak self] (newState) in
            switch(newState) {
            case .setup:
                print("connection is setup.\n")
            case .preparing:
                print("connection is preparing.\n")
            case .ready:
                print("connection established.\n")
            case .cancelled:
                print("cancel connection.\n")
                self?.disconnect()
            case .waiting(let error):
                //Handle connection waiting for network.
                print("waiting error: \(error).\n")
            case .failed(let error):
                //Handle fatal connection error
                print("fail error: \(error).\n")
                self?.disconnect()
            default:
                break
            }
        }
        receive()
        connection?.start(queue: DispatchQueue.main)
    }
    
    func disconnect() {
        guard connection != nil else {
            return
        }
        connection?.cancel()
        connection = nil
    }
    
    func receive() {
        //receive called before connect
        //and only call once
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 8096, completion: {[weak self] content, contentContext, isComplete, error in
            if let error = error {
                print(error)
                return
            }
            
            if let data = content, !data.isEmpty {
                print(String(data: data, encoding: .utf8)!)
            }
            
            //完成
            if isComplete {
                print("read finish.\n")
                return
            }
            
            self?.receive()

        })
        //This function will be called after server is closed.
//        connection?.receiveMessage(completion: {[weak self] completeContent, contentContext, isComplete, error in
//        })
    }
    
    func send(message: String) {
        connection?.send(content: message.data(using: .utf8), completion: .contentProcessed({ error in
            if let error = error {
                print("send message error: \(error).\n")
            } else {
                print("send message success.\n")
            }
        }))
    }
    
    func reconnect() {
        disconnect()
        connect()
    }
    
    @IBAction func connectAction(_ sender: Any) {
        connect()
    }
    
    @IBAction func disconnectAction(_ sender: Any) {
        disconnect()
    }
    
    @IBAction func sendAction(_ sender: Any) {
        if let text = textField.text, !text.isEmpty {
            send(message: text)
        }
    }
}

