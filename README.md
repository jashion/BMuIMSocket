# BMuIMSocket

These are some simple socket demos.

#### Demo1:

This client demo is implemented using socket.

###### Client:

Create socket

```objectivec
//int socket(int domain, int type, int protocol);
//返回值为Int,表示socket套接字的唯一标识,如果成功则返回套接字的描述符，如果失败则返回INVALID_SOCKET(Linux下失败返回-1，通常会返回>0的整数)
//domain：AF_INET(IPv4)或者AF_INET6(IPv6)
//type：SOCK_STREAM(TCP)或者SOCK_DGRAM(UDP)
//protocol：需要根据第二参数来数据类型来决定选择的协议，比如：IPPROTO_TCP, IPPTOTO_UDP，一般设置为0，系统会自动选择适合的协议
int clientSocketNum = socket(AF_INET, SOCK_STREAM, 0);
if (socketId == -1) {
    perror("socket"); //perror函数是C库中的一个函数，用于将上一个函数发生错误的原因输出到标准错误设备(stderr)。
    // 可以通过 strerror 获取错误信息
    char buf[1024];
    strerror_r(errno, buf, sizeof(buf));
    printf("socket failed: %s\n", buf);
    return;
}
```

Connect to server

```objectivec
//服务器ip
const char *server_ip = "127.0.0.1"; //本地地址
//服务器端口
unsigned short server_port = 10069;
//初始化sockaddr_in结构体
//    truct sockaddr_in {
//        __uint8_t       sin_len;  //
//        sa_family_t     sin_family;  //AF_INET（地址族） PF_INET（协议族）
//        in_port_t       sin_port;  //端口
//        struct  in_addr sin_addr;  //ip
//        char            sin_zero[8];  //没有实际意义，只是为了跟sockaddr结构在内存中对齐
//    };
struct sockaddr_in sAddr;
sAddr.sin_len = sizeof(sAddr);
sAddr.sin_family = AF_INET;

//将一个字符串ip地址转换成一个32位的网络序列ip地址
//如果转换成功，返回值非零，失败，返回值为零
//    struct in_addr socketIn_addr;
//    socketIn_addr.s_addr = inet_addr(server_ip);
//    sAddr.sin_addr = socketIn_addr;
inet_aton(server_ip, &sAddr.sin_addr);

//将整型变量从主机字节顺序转变成网络字节顺序，赋值端口号
sAddr.sin_port = htons(server_port);

//发起连接，会阻塞当前线程，直到服务器返回，这里应该不应该放在主线程
//如果成功则返回值为0，失败则返回值为-1
int connectId = connect(socket, (struct sockaddr *)&sAddr, sizeof(sAddr));
if (connectId == -1) {
    perror("connect");
    // 可以通过 strerror 获取错误信息
    char buf[1024];
    strerror_r(errno, buf, sizeof(buf));
    printf("socket failed: %s\n", buf);
    return;
}
```

Send message to server

```objectivec
const char *sendMsg = [msg UTF8String];
//int send(int sockfd,const void * buf,int len,unsigned int flags);
//TCP发送消息函数：将缓冲区的数据发送出去，如果成功，则返回饭送的字节数，失败则返回SOCKET_ERROR
//sockfd：套接字
//buf：包含待发送数据的缓冲区
//len：缓冲区中的数据长度
//flags：调用执行方式
send(self.clientSocketNum, sendMsg, strlen(sendMsg), 0);
```

Receive message from server

```objectivec
//需要循环读取，因为数据有可以会被拆分
while (1) {
   char recvMsg[1024] = {0};
   //int recv(int sockfd,void *buf,int len,unsigned int flags);
   //TCP接收消息函数：从缓冲区读取内容，成功则返回读取内容的字节数，失败则返回SOCKET_ERROR，0则代表已经读完缓冲区的内容
   //sockfd：套接字
   //buf：缓冲区
   //len：缓冲区长度
   //flags：接受方式，0表示阻塞，必须等待服务器返回数据，一般设为0
   recv(self.clientSocketNum, recvMsg, sizeof(recvMsg), 0);
}
```

Disconnect socket to server.

```objectivec
close(self.clientSocketNum);
```

###### Server:

```javascript
var net = require('net');  //引入net库
var HOST = '127.0.0.1';  
var PORT = 10069;  

// 创建一个TCP服务器实例，调用listen函数开始监听指定端口  
// 传入net.createServer()的回调函数将作为”connection“事件的处理函数  
// 在每一个“connection”事件中，该回调函数接收到的socket对象是唯一的  
net.createServer(function(sock) {  

    //连接成功进来该回调函数，sock为连接的客户端的socket实例，不是监听的socket 
    console.log('CONNECTED: ' +  
        sock.remoteAddress + ':' + sock.remotePort);  

    sock.write('服务端发出：连接成功');  

    //为这个socket实例添加一个"data"事件处理函数，接收客户端发送的数据  
    sock.on('data', function(data) {  
        console.log('DATA ' + sock.remoteAddress + ': ' + data);  
        // 回发该数据，客户端将收到来自服务端的数据  
        sock.write('You said "' + data + '"');  
    });  

    // 为这个socket实例添加一个"close"事件处理函数，接收客服端发送的断开连接  
    sock.on('close', function(data) {  
        console.log('CLOSED: ' +  
        sock.remoteAddress + ' ' + sock.remotePort);  
    });  

}).listen(PORT, HOST);  

console.log('Server listening on ' + HOST +':'+ PORT);  
```

#### Demo2:

The client code is the same as demo1, but the server is different.

###### Server:

```shell
nc -lk 10069
//启动一个netcat进程，监听本地的10069端口，等待远程主机的连接。
//参数“l”表示监听模式，“k”表示在客户端断开连接后继续监听。
```

#### Demo3:

The client code is the same as demo1, but the server is using Mac app.

###### Server:

Declare two socket variables.One socket is listening server port, another socket is communicating with client.

```objectivec
//服务端需要创建两个socket
//一个是用来监听某个端口
//另一个是和客户端发起请求组成连接的socket，从accept函数返回
@property (nonatomic, assign) int serverSocketNum;  //监听的socket
@property (nonatomic, assign) int clientSocketNum; //绑定客户端的socket
```

Create server socket.

```objectivec
self.serverSocketNum = socket(AF_INET, SOCK_STREAM, 0);
```

Server socket binds the local port.

```objectivec
struct sockaddr_in sAddr;
sAddr.sin_family = AF_INET;
sAddr.sin_port = htons(server_port);

struct in_addr socketIn_addr;
socketIn_addr.s_addr = inet_addr(server_ip);

sAddr.sin_addr = socketIn_addr;

//创建socket如果不绑定端口系统会随机分配端口
int bindId = bind(socket, (const struct sockaddr *)&sAddr, sizeof(sAddr));;
```

Server socket listens the local port.

```objectivec
int listenId = listen(addr, kMaxConnectCount); 
//kMaxConnectCount=10，最大可以和服务端建立通信的客户端连接数
```

Accept client link and create a new socket to link client socket.

```objectivec
struct sockaddr_in client_address;
socklen_t address_len = sizeof(client_address);
//阻塞，直到有客户端连接来到，然后生成新的socket和客户端socket连接
int socketId = accept(self.serverSocketNum, (struct sockaddr *)&client_address, &address_len);
```

The send, receiver and close futhions are the same as the demo1.

`Tips:`

`1.If you use mac app as a server,you must to check:`

`Incoming Connection(Server) and Outgoing Connection(Client), otherwise the socket can't bind the local port.`

`2.use: lsof -i :10069, to check the local port which has been used.`

#### Demo4:

This demo is using CocoaAsyncSocket which using Socket API to implement.

###### Client:

Create socket.

```swift
//delegateQueue只的是回调队列，不是执行队列，不用担心阻塞主线程，一般设置为主队列
let gcdSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
```

Connect socket to server.

```swift
//因为connect函数会抛出异常，所以需要用try-catch捕获异常
do {
    try gcdSocket?.connect(toHost: kHost, onPort: kPort)
} catch {
    print("Connect error.\n")
}
```

Send message to server.

```swift
//发送的是data，timeout=-1是指不会超时
gcdSocket?.write(Data(data.utf8), withTimeout: -1, tag: kTag)
```

Receive message from server.

```swift
//-1阻塞，永远监听，不会超时，但是只接收一次消息
//需要每次接收得消息还要调用
gcdSocket?.readData(withTimeout: -1, tag: kTag)
```

Disconnect socket to server.

```swift
gcdSocket?.disconnect()
```

###### Server:

Create server socket.

```swift
var gcdSocket: GCDAsyncSocket? = nil
var clientSocket: GCDAsyncSocket? = nil

let kHost = "127.0.0.1"
let kPort: UInt16 = 10069
let kTag = 100


gcdSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
```

Server socket bind, listen local port and call accept function.

```swift
//CocoaAsyncSocket在accept方法里面包装了bind, listen和accept方法。
do {
    try gcdSocket?.accept(onPort: kPort)
} catch {
    print("listen error.\n")
}
```

Server socket accept client socket and create a new socket to link with client.

```swift
//accept
func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
    //this function will be called more times if many clients connect to server
    clientSocket = newSocket

    clientSocket?.readData(withTimeout: -1, tag: kTag)
}
```

The send, receiver and close futhions are the same as the client code.

#### Demo5:

This demo is using SocketRocket which using WebSocket protocol to implement.

###### Client:

Creat webSocket.

```objectivec
self.webSocket = [[SRWebSocket alloc] initWithURLRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: @"ws://127.0.0.0:10069"]]];
self.webSocket.delegate = self;
```

Connect socket to servre.

```objectivec
//webSocket开始连接
[self.webSocket open];
```

Send message to server.

```objectivec
[_webSocket send: msg];
```

Receive message from server.

```objectivec
//SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"receive message from server: %@\n", message);
}
```

Disconnect  socket to server.

```objectivec
[_webSocket close];
_webSocket = nil;
```

###### Server:

The SocketRocket library is only implement webSocket client.So we use node.js as server.

```js
var WebSocketServer = require('ws').Server,

wss = new WebSocketServer({ port: 10069 });
wss.on('connection', function (ws) {
    console.log('client connected');

    //收到消息回调
    ws.on('message', function (message) {
        console.log(message);
        //回写给客户端
        ws.send('收到:'+message);  
    });

    //关闭连接
    ws.on('close', function(close) {  
        console.log('退出连接了');  
    });  
});
console.log('开始监听10069端口');
```

#### Summary:

We can use newer libraries to implement socket communicate.CocoaAsyncSocket and SocketRocket are no longer maintain.We can use Socket.io or Network.framwork to implemet socket communicate.At last, we also can use Easemob to implement our IM project at first.
