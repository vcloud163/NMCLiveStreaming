//
//  ViewController.m
//  TestFFmpeg
//
//  Created by yly on 15/4/27.
//  Copyright (c) 2015年 lyle. All rights reserved.
//

#import "ViewController.h"
#import "QPLiveViewController.h"
#import <QPLive/QPLive.h>

@interface ViewController ()
@property(nonatomic, copy) NSString* pushUrl;
@property(nonatomic, copy) NSString* pullUrl;
@property(nonatomic, copy) NSString* recordUrl;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //    [self startButtonClick:nil];
}


#pragma mark - Action

- (IBAction)copyPushUrl:(id)sender {
    if (!self.pushUrl) {
        return;
    }
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    board.string = self.pushUrl;
}

- (IBAction)copyPullUrl:(id)sender {
    if (!self.pullUrl) {
        return;
    }
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    board.string = self.pullUrl;
}


- (IBAction)createLive:(id)sender {
    QPLiveRequest *request = [[QPLiveRequest alloc] init];
    [request requestCreateLiveWithDomain:kQPDomain success:^(NSString *pushUrl, NSString *pullUrl) {
        self.pushUrl = pushUrl;
        self.pullUrl = pullUrl;
        NSLog(@"create live success");
        NSLog(@"pushUrl : %@", pushUrl);
        NSLog(@"pullUrl : %@", pullUrl);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pullLabel.text = pullUrl;
            self.pushLabel.text = pushUrl;
        });
    } failure:^(NSError *error) {
        NSLog(@"create live failed %@", error);
    }];
}

- (IBAction)startButtonClick:(id)sender {
    
    //    self.pushUrl = @"rtmp://192.168.30.69/live/movie";
    
    if (!self.pushUrl) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"未取得推流地址，无法直播" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    QPLiveViewController *live = [[QPLiveViewController alloc] initWithNibName:@"QPLiveViewController" bundle:nil url:self.pushUrl];
    [self presentViewController:live animated:YES completion:nil];
}

@end
