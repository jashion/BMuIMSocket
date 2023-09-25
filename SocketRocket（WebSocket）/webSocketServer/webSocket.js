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