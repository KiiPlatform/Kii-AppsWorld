//
//  ScheduleViewController.h
//  Kii@AppsWorld
//
//  Created by Chris on 10/10/13.
//  Copyright (c) 2013 Kii Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleViewController : UIViewController
<UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *categoryView;
@property (nonatomic, strong) IBOutlet UIScrollView *contentView;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

@end
