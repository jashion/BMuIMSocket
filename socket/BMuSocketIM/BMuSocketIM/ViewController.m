//
//  ViewController.m
//  BMuSocketIM
//
//  Created by Jashion on 2023/9/15.
//

#import "ViewController.h"
#import "BMuSocketManager.h"

@interface ViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (nonatomic, strong) BMuSocketManager *socketManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _socketManager = [BMuSocketManager new];
}

- (IBAction)sendMsg:(id)sender {
    if ([self.inputTextField.text stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceCharacterSet].length == 0) {
        NSLog(@"输入为空!/n");
        return;
    }
    
    [self.socketManager sendMsg: self.inputTextField.text];
}

- (IBAction)connect:(id)sender {
    [self.socketManager connect];
}

- (IBAction)disconnect:(id)sender {
    [self.socketManager disConnect];
}

#pragma mark - UITextFieldDelegate

@end
