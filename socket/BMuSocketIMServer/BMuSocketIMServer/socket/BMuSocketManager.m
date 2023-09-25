//
//  BMuSocketManager.m
//  BMuSocketIMServer
//
//  Created by Jashion on 2023/9/22.
//

#import "BMuSocketManager.h"

#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#define kMaxConnectCount 10
#define SocketPort htons(10069)
#define SocketIP inet_addr("127.0.0.1")

@interface BMuSocketManager()

@property (nonatomic, assign) int serverSocketNum;  //监听的socket
@property (nonatomic, assign) int clientSocketNum; //绑定客户端的socket

@end

@implementation BMuSocketManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _serverSocketNum = 0;
        _clientSocketNum = 0;
        [self initSocket];
    }
    return self;
}

#pragma mark - socket
- (void)initSocket {
    int socketId = createSocket();
    if (socketId == -1) {
        perror("socket");
        // 可以通过 strerror 获取错误信息
        char buf[1024];
        strerror_r(errno, buf, sizeof(buf));
        printf("socket failed: %s\n", buf);
        return;
    }
    printf("create socket success!\n");
    self.serverSocketNum = socketId;

    const char *server_id = "127.0.0.1";
    unsigned short server_port = 10069;
    if (bindSocket(_serverSocketNum, server_id, server_port) == -1) {
        perror("bind");
        // 可以通过 strerror 获取错误信息
        char buf[1024];
        strerror_r(errno, buf, sizeof(buf));
        printf("bind failed: %s\n", buf);
        return;
    }
    printf("socket bind success.\n");

    if (listenSocket(_serverSocketNum) == -1) {
        perror("listen");
        // 可以通过 strerror 获取错误信息
        char buf[1024];
        strerror_r(errno, buf, sizeof(buf));
        printf("listen failed: %s\n", buf);
        return;
    }
    printf("socket listen success.\n");

    printf("start a new thread to accept socket.\n ");
    NSThread *thread = [[NSThread alloc] initWithTarget: self selector: @selector(acceptSocket) object: nil];
    [thread start];
}

static int createSocket() {
    return socket(AF_INET, SOCK_STREAM, 0);
}

static int bindSocket(int socket, const char *server_ip, unsigned short server_port) {
    struct sockaddr_in sAddr;
    sAddr.sin_family = AF_INET;
    sAddr.sin_port = htons(server_port);
    
    struct in_addr socketIn_addr;
    socketIn_addr.s_addr = inet_addr(server_ip);  //INADDR_ANY
    
    sAddr.sin_addr = socketIn_addr;
        
    //创建socket如果不绑定端口系统会随机分配端口
    return bind(socket, (const struct sockaddr *)&sAddr, sizeof(sAddr));
}

static int listenSocket(int addr) {
    return listen(addr, kMaxConnectCount);
}

#pragma mark - send receive
- (void)sendMsg:(NSString *)msg {
    const char *sendMsg = [msg UTF8String];
    send(self.clientSocketNum, sendMsg, strlen(sendMsg), 0);
}

- (void)receiveMsg {
    while (1) {
        char recvMsg[1024] = {0};
        recv(self.clientSocketNum, &recvMsg, sizeof(recvMsg), 0);
        printf("%s\n", recvMsg);
    }
}

- (void)acceptSocket {
    struct sockaddr_in client_address;
    socklen_t address_len = sizeof(client_address);
    int socketId = accept(self.serverSocketNum, (struct sockaddr *)&client_address, &address_len);
    if (socketId == -1) {
        perror("accept");
        // 可以通过 strerror 获取错误信息
        char buf[1024];
        strerror_r(errno, buf, sizeof(buf));
        printf("accept failed: %s\n", buf);
    } else {
        self.clientSocketNum = socketId;
        [self receiveMsg];
    }
}

- (void)close {
    close(self.clientSocketNum);
}

@end
