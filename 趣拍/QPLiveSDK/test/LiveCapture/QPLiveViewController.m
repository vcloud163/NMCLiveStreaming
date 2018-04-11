//
//  QPLiveViewController.m
//  DemoQPLive
//
//  Created by yly on 16/3/21.
//  Copyright © 2016年 lyle. All rights reserved.
//


/**
 *  杭州短趣传媒网络技术有限公司
 *  POWERED BY QUPAI
 */

#import "QPLiveViewController.h"
#import <QPLive/QPLive.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface QPLiveViewController ()<QPLiveSessionDelegate>

@property (nonatomic, strong) CTCallCenter *callCenter;

@end

@implementation QPLiveViewController{
    QPLiveSession *_liveSession;
    NSString *_url;
    NSTimer *_timer;
    
    NSFileHandle *_handle;
    AVCaptureDevicePosition _currentPosition;
    NSUInteger _last;
    NSMutableArray *_logArray;
    
    CGFloat _lastPinchDistance;
    
    BOOL _isCTCallStateDisconnected;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSString *)url{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    _url = url;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _logArray = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:gesture];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [self.view addGestureRecognizer:pinch];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeUpdate) userInfo:nil repeats:YES];
    
    [self testPushCapture];
    
    [_segmented removeAllSegments];
    for (int i = 400; i <= 900; i += 100) {
        [_segmented insertSegmentWithTitle:@(i).stringValue atIndex:0 animated:NO];
    }
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"log.txt"];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    _handle = [NSFileHandle fileHandleForWritingAtPath:path];
}

- (void)timeUpdate{
    QPLDebugInfo *i = [_liveSession dumpDebugInfo];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:i.connectStatusChangeTime];
    
    NSMutableString *msg = [[NSMutableString alloc] init];
    [msg appendFormat:@"CycleDelay(%0.2fms)\n",i.cycleDelay];
    [msg appendFormat:@"bitrate(%zd) buffercount(%zd)\n",[_liveSession videoBitRate] ,_liveSession.dumpDebugInfo.localBufferVideoCount];
    [msg appendFormat:@" efc(%zd) pfc(%zd)\n",i.encodeFrameCount, i.pushFrameCount];
    [msg appendFormat:@"%0.2ffps %0.2fKB/s %0.2fKB/s\n", i.fps,i.encodeSpeed, i.speed/1024];
    [msg appendFormat:@"%lluB pushSize(%lluB) status(%zd) %@",i.localBufferSize, i.pushSize, i.connectStatus, date];
    [msg appendFormat:@" %0.2fms\n",i.localDelay];
    [msg appendFormat:@"video_pts:%zd\naudio_pts:%zd\n", i.currentVideoPTS,i.currentAudioPTS];
    
    //    NSLog(@"%@", msg);
    
    _textView.text = msg;
    
    
    
    [_logArray addObject:msg];
    
    //    NSLog(@"%@", i.eventArray);
    
    
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture{
    CGPoint point = [gesture locationInView:self.view];
    CGPoint percentPoint = CGPointZero;
    percentPoint.x = point.x / CGRectGetWidth(self.view.bounds);
    percentPoint.y = point.y / CGRectGetHeight(self.view.bounds);
    [_liveSession focusAtAdjustedPoint:percentPoint autoFocus:YES];
    
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)gesture {
    
    if (_currentPosition == AVCaptureDevicePositionFront) {
        return;
    }
    
    if (gesture.numberOfTouches != 2) {
        return;
    }
    CGPoint p1 = [gesture locationOfTouch:0 inView:self.view];
    CGPoint p2 = [gesture locationOfTouch:1 inView:self.view];
    CGFloat dx = (p2.x - p1.x);
    CGFloat dy = (p2.y - p1.y);
    CGFloat dist = sqrt(dx*dx + dy*dy);
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _lastPinchDistance = dist;
    }
    
    CGFloat change = dist - _lastPinchDistance;
    //    change = change / (CGRectGetWidth(self.view.bounds) * 0.5) * 2.0;
    //
    [_liveSession zoomCamera:(change / 1000 )];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)appResignActive{
    [self destroySession];
    
    // 监听电话
    _callCenter = [[CTCallCenter alloc] init];
    _isCTCallStateDisconnected = NO;
    _callCenter.callEventHandler = ^(CTCall* call) {
        if ([call.callState isEqualToString:CTCallStateDisconnected])
        {
            _isCTCallStateDisconnected = YES;
        }
        else if([call.callState isEqualToString:CTCallStateConnected])
            
        {
            _callCenter = nil;
        }
    };
    
}

- (void)appBecomeActive{
    
    if (_isCTCallStateDisconnected) {
        sleep(2);
    }
    
    [self testPushCapture];
}

- (void)testPushCapture{
    
    //    _url = @"rtmp://192.168.30.69/live/movie";
    
    //        _url = @"rtmp://push.lss.qupai.me/qupai-live/qupai-live-wyj99?auth_key=4466400545-0-0-1d54a5911b70caccfce6983bced975e8";
    
    QPLConfiguration *configuration = [[QPLConfiguration alloc] init];
    configuration.url = _url;
    configuration.videoMaxBitRate = 1500 * 1000;
    configuration.videoBitRate = 600 * 1000;
    configuration.videoMinBitRate = 400 * 1000;
    configuration.audioBitRate = 64 * 1000;
    configuration.videoSize = CGSizeMake(360, 640);// 横屏状态宽高不需要互换
    configuration.fps = 20;
    configuration.preset = AVCaptureSessionPresetiFrame1280x720;
    configuration.screenOrientation = 0;
    
    // 水印
    configuration.waterMaskImage = [UIImage imageNamed:@"watermask"];
    configuration.waterMaskLocation = 0;
    configuration.waterMaskMarginX = 20;
    configuration.waterMaskMarginY = 20;
    
    if (_currentPosition) {
        configuration.position = _currentPosition;
    } else {
        configuration.position = AVCaptureDevicePositionFront;
        _currentPosition = AVCaptureDevicePositionFront;
    }
    
    _liveSession = [[QPLiveSession alloc] initWithConfiguration:configuration];
    _liveSession.delegate = self;
    
    [_liveSession startPreview];
    
    [_liveSession updateConfiguration:^(QPLConfiguration *configuration) {
        configuration.videoMaxBitRate = 1500 * 1000;
        configuration.videoBitRate = 600 * 1000;
        configuration.videoMinBitRate = 400 * 1000;
        configuration.audioBitRate = 64 * 1000;
        configuration.fps = 20;
    }];
    [_liveSession connectServer];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view insertSubview:[_liveSession previewView] atIndex:0];
    });
    
}

- (void)destroySession{
    
    [_liveSession disconnectServer];
    
    [_liveSession stopPreview];
    [_liveSession.previewView removeFromSuperview];
    
    _liveSession = nil;
}


- (void)liveSession:(QPLiveSession *)session error:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *msg = [NSString stringWithFormat:@"%zd %@",error.code, error.localizedDescription];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Live Error" message:msg delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"重新连接", nil];
        alertView.delegate = self;
        [alertView show];
    });
}


- (void)liveSessionNetworkSlow:(QPLiveSession *)session{
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        _textView.text = @"网络很差，不建议直播";
    //    });
    NSLog(@"网络太差");
}

- (void)liveSessionConnectSuccess:(QPLiveSession *)session {
    
    NSLog(@"connect success!");
}

- (void)openAudioSuccess:(QPLiveSession *)session {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"YES" message:@"麦克风打开成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    });
}

- (void)openVideoSuccess:(QPLiveSession *)session {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"YES" message:@"摄像头打开成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    });
}


- (void)liveSession:(QPLiveSession *)session openAudioError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"麦克风获取失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    });
}

- (void)liveSession:(QPLiveSession *)session openVideoError:(NSError *)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"摄像头获取失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    });
}

- (void)liveSession:(QPLiveSession *)session encodeAudioError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"音频编码初始化失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    });
    
}

- (void)liveSession:(QPLiveSession *)session encodeVideoError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"视频编码初始化失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    });
}

- (void)liveSession:(QPLiveSession *)session bitrateStatusChange:(QP_LIVE_BITRATE_STATUS)bitrateStatus {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"YES" message:[NSString stringWithFormat:@"%ld", (long)bitrateStatus] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [_liveSession connectServer];
    }
}

- (IBAction)buttonCloseClick:(id)sender {
    [self destroySession];
    [_timer invalidate];
    _timer = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cameraButtonClick:(UIButton *)button {
    button.selected = !button.isSelected;
    _liveSession.devicePosition = button.isSelected ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    _currentPosition = _liveSession.devicePosition;
}

- (IBAction)skinButtonClick:(UIButton *)button {
    button.selected = !button.isSelected;
    [_liveSession setEnableSkin:button.isSelected];
}
- (IBAction)flashButtonClick:(UIButton *)button {
    button.selected = !button.isSelected;
    _liveSession.torchMode = button.isSelected ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
}


- (IBAction)disconnectButtonClick:(id)sender {
    if (_liveSession.dumpDebugInfo.connectStatus == QPLConnectStatusNone) {
        [_liveSession connectServer];
    }else{
        [_liveSession disconnectServer];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_handle closeFile];
}
@end
