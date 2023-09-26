//
//  ViewController.swift
//  BMuSocketIMNetworkServer
//
//  Created by Jashion on 2023/9/26.
//

import Cocoa
import Network

class ViewController: NSViewController {

    @IBOutlet weak var textField: NSTextField!
    var listener: NWListener?
    private var connection: NWConnection?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initServer()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func initServer() {
        listener = try! NWListener(using: .tcp, on: NWEndpoint.Port(integerLiteral: 10069))
        
        listener?.stateUpdateHandler = {(newState) in
            switch newState {
            case .ready:
                print("Server ready.\n")
            case .failed(let error):
                print("Server failure, error: \(error.localizedDescription)\n")
                exit(EXIT_FAILURE)
            default:
                break
            }
        }
        listener?.newConnectionHandler = {[weak self] (connection) in
            self?.connection = connection
            connection.stateUpdateHandler = {(newState) in
                switch(newState) {
                case .waiting(let error):
                    print("Connection failure, error: \(error.localizedDescription)\n")
                case .ready:
                    print("Connection ready.\n")
                case .failed(let error):
                    print("Connection failure, error: \(error.localizedDescription)\n")
                    exit(EXIT_FAILURE)
                default:
                    break
                }
            }
            self?.receive()
            connection.start(queue: .main)
//            connection.send(content: "welcome to server".data(using: .utf8), completion: .contentProcessed({ error in
//                if let error = error {
//                    print("error : \(error.localizedDescription)")
//                    return
//                }
//                print("send sucess.")
//            }))
        }
        listener?.start(queue: .main)
    }
    
    func receive() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 8096) {[weak self] data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                let message = String(data: data, encoding: .utf8)
                print("connection did receive, data \(message ?? "")")
                self?.connection?.send(content: data, completion: .contentProcessed({ error in
                    if let error = error {
                        print("error : \(error.localizedDescription)")
                        return
                    }
                    print("send data: \(data)")
                }))
            }
            
            if let error = error {
                print("error : \(error.localizedDescription)")
                return
            }
            
            if isComplete {
                return
            }
            self?.receive()
        }

    }

    @IBAction func sendAction(_ sender: Any) {
        guard connection != nil else {
            return
        }
        
        let message = textField.stringValue
        if !message.isEmpty {
            connection?.send(content: message.data(using: .utf8), completion: .contentProcessed({ error in
                if let error = error {
                    print("error : \(error.localizedDescription)")
                    return
                }
                print("send sucess, message: \(message)")
            }))
        }
    }
    
    @IBAction func disconnectAction(_ sender: Any) {
    }
}

