//
//  ViewController.m
//  App
//
//  Created by mac on 16/3/28.
//  Copyright © 2016年 ZTE. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "MJRefresh.h"
#import <ReactiveCocoa.h>
#import "GKLButtonController.h"

@interface ViewController ()<UIAlertViewDelegate>


@property (strong, nonatomic) IBOutlet UILabel *testLabel;
@property (strong, nonatomic) IBOutlet UIButton *testButton;
@property (strong, nonatomic) IBOutlet UITextField *testField;
/*
 *   账号
 */
@property (weak, nonatomic) IBOutlet UITextField *countInput;
/*
 *   密码
 */
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
/*
 *  点击登录按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *logininButton;
@property (strong,nonatomic)UIAlertView *testAlert;
@property (copy,nonatomic)NSString *test;
/*
 *  连接状态，默认no
 */
@property (assign,nonatomic)NSNumber *isConnected;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.testLabel.text = @"0";
    _test = @"0";
    
    /*
     * KVO成员变量
     */
    [RACObserve(self, test) subscribeNext:^(id x) {
        NSLog(@"成员变量 test 被修改成了：%@", x);
    }];
    
    /*
     * KVO label文本测试
     */
    
    [RACObserve(self, self.testLabel) subscribeNext:^(UILabel* x) {
        NSLog(@"testLabel的值 被修改成了：%@", x.text);
    }];

    /*
     * action -target    button按钮测试
     */
    
    __weak ViewController *wself = self;
    GKLButtonController *bt_ = [[GKLButtonController alloc]init];
    self.testButton.rac_command = [[RACCommand alloc] initWithSignalBlock:
                                   ^RACSignal *(id input) {
                                       
                                       NSLog(@"按钮被点击 %@",input);
                                       
                                       [wself.navigationController pushViewController:bt_ animated:YES];
                                       
                                       return [RACSignal empty];
                                   }];
    
    [[self.testButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"testbutton按钮被点击");
    }];
    
    /*
     * testfiled文本测试
     */
    [[self.testField rac_textSignal] subscribeNext:^(id x) {
        
        NSLog(@"testfield的值被修改成了%@",x);
    }];
    
    [[self.testField rac_signalForControlEvents:UIControlEventAllEditingEvents] subscribeNext:^(UITextField* x) {
        NSLog(@"值被修改成了 %@",x.text);
    }];
    
           //filter是帅选的意思
    [[[self.testField rac_signalForControlEvents:UIControlEventAllEditingEvents] filter:^BOOL(UITextField* x) {
        
        if ([x.text hasPrefix:@"2"]) {
            return YES;
        }else {
            
            return NO;
        }
    }] subscribeNext:^(UITextField* x) {
        
        NSLog(@"条件输出testfield的值%@",x.text);
    }];
    
    
    /*
     *   手势测试
     */
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [[tap rac_gestureSignal] subscribeNext:^(id x) {
        NSLog(@"手势Tap");
        [self.view endEditing:YES];
    }];
    [self.view addGestureRecognizer:tap];
    
    /*
     *    同时监听几个变量
     */
           //登录按钮状态
    RAC(self.logininButton,enabled) = [RACSignal
                                       combineLatest:@[self.countInput.rac_textSignal,
                                                       self.passwordInput.rac_textSignal,
                                                       RACObserve(self, isConnected)
                                                       ]
                                       reduce:^(NSString *count, NSString *password,NSNumber *connected){
                                           return @(count.length > 0 && password.length > 0 && ![connected boolValue] );
                                       }];
          // 账户，密码有值时连接服务器
    [[RACSignal combineLatest:@[
                                    
                                self.countInput.rac_textSignal,
                                    self.passwordInput.rac_textSignal,
                                    RACObserve(self, self.isConnected)
                                    ]
                                  reduce:^(NSString *count, NSString *password,NSNumber*connected){
                                          return @(count.length > 0 && password.length > 0 && ![connected boolValue]);
                
                                  }] subscribeNext:^(NSNumber *x) {
                                      
                                      if ([x boolValue]) {
                                          NSLog(@"连接服务器");
                                      }
                                  }];
    
    /*
     *  alert测试 (简单)
     */

    [self.testAlert show];
    
    /*
     *  delegate方法 alert测试  （把下面斜杠去掉可以测试）
     */
    //[self alert];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(UIAlertView *)testAlert{

    if (!_testAlert) {
        _testAlert = ({
        
            UIAlertView * al = [[UIAlertView alloc]initWithTitle:@"警告" message:@"ALERT测试" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"other", nil];
            [[al rac_buttonClickedSignal] subscribeNext:^(id x) {
               
                NSLog(@"点击的是低%@个按钮",x);
            }];
            al;
        });
    }
    return _testAlert;
}
-(void)alert{

    UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"RAC1" message:@"RAC TEST" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"other", nil];
    UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:@"RAC2" message:@"RAC TEST" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"other", nil];
    [[self rac_signalForSelector:@selector(alertView:clickedButtonAtIndex:) fromProtocol:@protocol(UIAlertViewDelegate)] subscribeNext:^(RACTuple *tuple) {
        if (tuple.first == alertView1) {
            NSLog(@"一");
        }else {
            NSLog(@"二");
        }
        NSLog(@"%@",tuple.first);
        NSLog(@"%@",tuple.second);
        NSLog(@"%@",tuple.third);
    }];
    [alertView1 show];
    [alertView2 show];
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
}

-(void)didReceiveMemoryWarning{
    
    NSLog(@"reiveMenoryWarning");
}
@end
