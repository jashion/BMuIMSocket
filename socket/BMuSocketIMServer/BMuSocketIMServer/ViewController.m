//
//  ViewController.m
//  BMuSocketIMServer
//
//  Created by Jashion on 2023/9/16.
//

#import "ViewController.h"
#import "BMuSocketManager.h"

@interface ViewController()

@property (nonatomic, strong) BMuSocketManager *manager;
@property (weak) IBOutlet NSTextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [BMuSocketManager new];
}

- (void)viewDidAppear {
    [super viewDidAppear];
}

- (IBAction)sendMsgToClient:(id)sender {
    if ([self.textField.stringValue stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceCharacterSet].length <= 0) {
        NSLog(@"输入为空。\n");
        return;
    }
    
    [self.manager sendMsg: self.textField.stringValue];
}

- (IBAction)disconnectClientSocket:(id)sender {
    [self.manager close];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
