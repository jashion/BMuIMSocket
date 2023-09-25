//
//  BMuSocketManager.m
//  BMuSocketIM
//
//  Created by Jashion on 2023/9/17.
//

#import "BMuSocketManager.h"

#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface BMuSocketManager()

@property (nonatomic, assign) int clientSocketNum;

@end

@implementation BMuSocketManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _clientSocketNum = 0;
    }
    return self;
}

#pragma mark - Socket
//初始化socket
- (void)initClientSocket {
    //先关闭socket
    if (self.clientSocketNum != 0) {
        [self disConnect];
    }
    
    //创建新的socket
    int socketId = createClientSocket();
    if (socketId == -1) {
        perror("socket");
        // 可以通过 strerror 获取错误信息
        char buf[1024];
        strerror_r(errno, buf, sizeof(buf));
        printf("socket failed: %s\n", buf);
        return;
    }
    self.clientSocketNum = socketId;

    //服务器ip
    const char *server_ip = "127.0.0.1";
    //服务器端口
    unsigned short server_port = 10069;
    //如果返回-1则连接失败
    if (connectToServer(self.clientSocketNum, server_ip, server_port) == -1) {
        perror("connect");
        // 可以通过 strerror 获取错误信息
        char buf[1024];
        strerror_r(errno, buf, sizeof(buf));
        printf("socket failed: %s\n", buf);
        return;
    }
    
    NSLog(@"Connect to server success.\n");
    [self startThreadReceiveMsg];
}

//创建socket
static int createClientSocket() {
    //int socket(int domain, int type, int protocol);
    //返回值为Int,表示socket套接字的唯一标识,如果成功则返回套接字的描述符，如果失败则返回INVALID_SOCKET(Linux下失败返回-1，通常会返回>0的整数)
    //domain：AF_INET(IPv4)或者AF_INET6(IPv6)
    //type：SOCK_STREAM(TCP)或者SOCK_DGRAM(UDP)
    //protocol：需要根据第二参数来数据类型来决定选择的协议，比如：IPPROTO_TCP, IPPTOTO_UDP，一般设置为0，系统会自动选择适合的协议
    return socket(AF_INET, SOCK_STREAM, 0);
}

//连接
static int connectToServer(int socket, const char *server_ip, unsigned short server_port) {
    //初始化sockaddr_in结构体
//    struct sockaddr_in {
//        __uint8_t       sin_len;  //
//        sa_family_t     sin_family;  //AF_INET（地址族） PF_INET（协议族）
//        in_port_t       sin_port;  //端口
//        struct  in_addr sin_addr;  //ip
//        char            sin_zero[8];  //没有实际意义，只是为了跟sockaddr结构在内存中对齐
//    };
    struct sockaddr_in sAddr;
    sAddr.sin_len = sizeof(sAddr);
    sAddr.sin_family = AF_INET;
    
    //将整型变量从主机字节顺序转变成网络字节顺序，赋值端口号
    sAddr.sin_port = htons(server_port);
    
    //将一个字符串ip地址转换成一个32位的网络序列ip地址
    //如果转换成功，返回值非零，失败，返回值为零
//    struct in_addr socketIn_addr;
//    socketIn_addr.s_addr = inet_addr(server_ip);
//    sAddr.sin_addr = socketIn_addr;
    inet_aton(server_ip, &sAddr.sin_addr);
        
    //发起连接，会阻塞当前线程，直到服务器返回，这里应该不应该放在主线程
    //如果成功则返回值为0，失败则返回值为-1
    return connect(socket, (struct sockaddr *)&sAddr, sizeof(sAddr));
}

#pragma mark - connect,disconnect,send,receive
- (void)connect {
    [self initClientSocket];
}

- (void)disConnect {
    if (self.clientSocketNum == 0) {
        return;
    }
    close(self.clientSocketNum);
    self.clientSocketNum = 0;
}

//发送数据到服务端
- (void)sendMsg: (NSString *)msg {
    const char *sendMsg = [msg UTF8String];
    //int send(int sockfd,const void * buf,int len,unsigned int flags);
    //TCP发送消息函数：将缓冲区的数据发送出去，如果成功，则返回饭送的字节数，失败则返回SOCKET_ERROR
    //sockfd：套接字
    //buf：包含待发送数据的缓冲区
    //len：缓冲区中的数据长度
    //flags：调用执行方式
    send(self.clientSocketNum, sendMsg, strlen(sendMsg), 0);
}

//从服务端读取数据
- (void)receiveMsg {
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
        printf("%s\n", recvMsg);
    }
}

#pragma mark - 开启新线程接收服务端传过来的消息
- (void)startThreadReceiveMsg {
    dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSThread *thread = [[NSThread alloc] initWithTarget: self selector: @selector(receiveMsg) object: nil];
        [thread start];
    });
}

@end
