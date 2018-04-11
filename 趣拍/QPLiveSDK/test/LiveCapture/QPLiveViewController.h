//
//  QPLiveViewController.h
//  DemoQPLive
//
//  Created by yly on 16/3/21.
//  Copyright © 2016年 lyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QPLiveViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmented;
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSString *)url;

@end
