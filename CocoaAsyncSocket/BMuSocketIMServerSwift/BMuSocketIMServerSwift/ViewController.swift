//
//  ViewController.swift
//  BMuSocketIMServerSwift
//
//  Created by Jashion on 2023/9/23.
//

import Cocoa
import CocoaAsyncSocket

class ViewController: NSViewController, GCDAsyncSocketDelegate {
    var gcdSocket: GCDAsyncSocket? = nil
    let kHost = "127.0.0.1"
    let kPort: UInt16 = 10069
    var clientSocket: GCDAsyncSocket? = nil
    let kTag = 100

    @IBOutlet weak var textField: NSTextFieldCell!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gcdSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try gcdSocket?.accept(onPort: kPort)
        } catch {
            print("listen error.\n")
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func sendMsg(_ sender: Any) {
        guard clientSocket != nil else {
            return
        }
        
        clientSocket?.write(Data(textField.stringValue.utf8), withTimeout: -1, tag: kTag)
    }
    
    
    @IBAction func disconnect(_ sender: Any) {
        guard clientSocket != nil else {
            return
        }
        clientSocket?.disconnect()
    }
        
    //gcdSocket delegate
    //accept
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        //this function will be called more times if many clients connect to server
        clientSocket = newSocket
        
        clientSocket?.readData(withTimeout: -1, tag: kTag)
    }
    
    //connect
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("connect success.host: " + (sock.connectedHost ?? "") + " port: \(sock.connectedPort)\n")
    }
    
    //disconnect
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("connect disconnect.host: " + (sock.connectedHost ?? "") + " port: \(sock.connectedPort)\n")
    }
    
    //write
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("server send data to client success. port: " + (sock.connectedHost ?? "") + " port: \(sock.connectedPort)\n")
    }
    
    //read
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("client send data: " + (String.init(data: data, encoding: String.Encoding.utf8) ?? "") + ".\n")
        
        clientSocket?.readData(withTimeout: -1, tag: kTag)
    }
    
    //read partial
    func socket(_ sock: GCDAsyncSocket, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
        
    }
    
    //timeout
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        return 10
    }
}

