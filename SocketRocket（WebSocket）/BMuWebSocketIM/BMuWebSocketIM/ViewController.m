//
//  ViewController.m
//  BMuWebSocketIM
//
//  Created by Jashion on 2023/9/24.
//

#import "ViewController.h"
#import "SRWebSocket.h"

@interface ViewController ()<SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *webSocket;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController
{
    NSTimer *heartBeat; //心跳定时器
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - custome hearbeat
- (void)startHeartBeat {
    [self stopHeartBeat];
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self) weakSelf = self;
        //因为NAT刷新缓存是5分钟，所以心跳间隔3分钟左右比较合适
        heartBeat = [NSTimer scheduledTimerWithTimeInterval: 3*60 repeats: YES block:^(NSTimer * _Nonnull timer) {
            //和服务器约定好心跳包，越容易识别，越小越好
            [weakSelf sendMsg: @"heart"];
        }];
    });
}

- (void)stopHeartBeat {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(heartBeat) {
            [heartBeat invalidate];
            heartBeat = nil;
        }
    });
}

#pragma mark - webSocket
- (void)createSocket {
    if (_webSocket) {
        return;
    }

    //如果不设置回调队列，会在主线程回调
    //webSocket操作在异步线程，只是回调在主线程
    self.webSocket = [[SRWebSocket alloc] initWithURLRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: @"ws://127.0.0.0:10069"]]];
    self.webSocket.delegate = self;
    
//    NSOperationQueue *queue = [NSOperationQueue new];
//    queue.maxConcurrentOperationCount = 1;
//    [self.webSocket setDelegateOperationQueue: queue];

    //webSocket开始连接
    [self.webSocket open];
}

- (void)connect {
    //这里初始化一些webSocket要用到的配置数据，比如：重连次数，重连超时时间等等。

    [self createSocket];
}

- (void)reconnect {
    [self disconnect];

    //这里写重连条件限制，比如：次数，超时。
    [self createSocket];
}

- (void)disconnect {
    if (_webSocket) {
        [_webSocket close];
        _webSocket = nil;
    }
}

- (void)sendMsg: (NSString *)msg {
    if (_webSocket) {
        [_webSocket send: msg];
    }
}

//webSocket可以使用ping-pong实现心跳
- (void)sendPing {
    [_webSocket sendPing: nil];
}

#pragma mark - Actions
- (IBAction)send:(id)sender {
    [self sendMsg: _textField.text];
}

- (IBAction)socketConnect:(id)sender {
    [self connect];
}

- (IBAction)socketDisconnect:(id)sender {
    [self disconnect];
}

#pragma mark - webSockt delegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"Connect success.\n");
    //如果自定义心跳，在这开始
    //[self startHeartBeat];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Connect fail: %@\n", error);
    //失败重连
    [self reconnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"WebSocket is close: %@\n", reason);
    //这里可以做判断断开是用户自主触发的还是其他原因
    //用户断开，不再重连，否则开始重连
//    if (user_disconnect) {
//        [self disconnect];
//    } else {
//        [self reconnect];
//    }

    //如果使用了自定义心跳
    //这里要停止心跳
    //[self stopHeartBeat];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"receive message from server: %@\n", message);
}

//ping-pong
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongData {
    NSLog(@"receive pong: %@\n", pongData);
}

@end
