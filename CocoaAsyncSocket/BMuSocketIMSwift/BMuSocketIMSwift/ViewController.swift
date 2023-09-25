//
//  ViewController.swift
//  BMuSocketIMSwift
//
//  Created by Jashion on 2023/9/23.
//

import UIKit
import CocoaAsyncSocket

class ViewController: UIViewController, GCDAsyncSocketDelegate {
    
    @IBOutlet weak var textField: UITextField!
    var gcdSocket: GCDAsyncSocket?
    let kHost: String = "127.0.0.1"
    let kPort: UInt16 = 10069
    let kTag = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        gcdSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
    }
    
    func recevieMsg() {
        //-1阻塞，永远监听，不会超时，但是只接收一次消息
        //需要每次接收得消息还要调用
        gcdSocket?.readData(withTimeout: -1, tag: kTag)
    }

    @IBAction func sendMsg(_ sender: Any) {
        guard let data = textField.text else {
            return
        }
        
        guard !data.isEmpty else {
            return
        }
        
        gcdSocket?.write(Data(data.utf8), withTimeout: -1, tag: kTag)
    }
    
    @IBAction func connect(_ sender: Any) {
        do {
            try gcdSocket?.connect(toHost: kHost, onPort: kPort)
        } catch {
            print("Connect error.\n")
        }
    }
    
    @IBAction func disconnect(_ sender: Any) {
        gcdSocket?.disconnect()
    }
    
    //gcdSocket delegate
    //connect
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("socket connect success,host: " + kHost + " port: \(kPort).\n")
        
        self.recevieMsg()
        //这里开始心跳
    }
    
    //disconnect
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("socket disconnect,host: " + kHost + " port: \(kPort).\n")
        //这里开启断线重连
    }
    
    //write data
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("write data to server success.\n")
    }
    
    //read data
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("received message：" + (String.init(data: data, encoding: String.Encoding.utf8) ?? ""))
        //再次调用
        recevieMsg()
    }
    
    //分段读取消息回调
    func socket(_ sock: GCDAsyncSocket, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
        print("received message length：\(partialLength)")
    }
    
    //为上一次设置的读取数据代理续时，如果设置为-1，则不会调用
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        return 10
    }
}

