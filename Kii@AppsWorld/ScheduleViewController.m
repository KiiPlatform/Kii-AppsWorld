//
//  ScheduleViewController.m
//  Kii@AppsWorld
//
//  Created by Chris on 10/10/13.
//  Copyright (c) 2013 Kii Corporation. All rights reserved.
//

#import "ScheduleViewController.h"

#import "NSString+KTUtilities.h"
#import "UIColor+KTUtilities.h"
#import "SessionDetailViewController.h"
#import <KiiSDK/Kii.h>

#import "KiiToolkit.h"

#define HOUR_HEIGHT         360
#define COLUMN_WIDTH        200
#define FIRST_DAY_LENGTH    12.5
#define DAY_BREAK_HEIGHT    50
#define PADDING_VERTICAL    26
#define PADDING_HORIZONTAL  10
#define FIRST_DAY_START     09.00f
#define SECOND_DAY_START    09.00f

#define BACKGROUND_COLOR    [UIColor colorWithHex:@"eeeeee"]

@interface ScheduleViewController() {
    NSMutableArray *_categories;
    NSMutableArray *_sessions;
}

@end

@implementation ScheduleViewController

@synthesize categoryView = _categoryView;
@synthesize contentView = _contentView;

- (void) buildCategoryView
{
    _categories = [[NSMutableArray alloc] init];
    
    NSArray *downloadedCategories = [[NSUserDefaults standardUserDefaults] objectForKey:BUCKET_SCHEDULE_CATEGORIES];
    for(NSDictionary *category in downloadedCategories) {
        [_categories addObject:category];
        NSLog(@"Category: %@", category);
    }

    _categoryView.contentOffset = CGPointZero;
    
    int ndx = 0;
    for(NSDictionary *category in _categories) {
        
        CGFloat width = 200.f;
        CGFloat x = ndx * width;
        CGFloat barHeight = 4.f;
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(x, _categoryView.frame.size.height-barHeight, width, barHeight)];
        v.backgroundColor = [UIColor colorWithHex:[category objectForKey:@"color"]];
        [_categoryView addSubview:v];
        
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, width, _categoryView.frame.size.height-barHeight)];
        l.backgroundColor = [UIColor clearColor];
        l.textColor = [UIColor colorWithHex:[category objectForKey:@"color"]];
        l.text = [category objectForKey:@"name"];
        l.textAlignment = NSTextAlignmentCenter;
        [_categoryView addSubview:l];
        
        _categoryView.contentSize = CGSizeMake(x+width, _categoryView.frame.size.height);
        
        ++ndx;
    }
    
}

- (void) sessionTapped:(UITapGestureRecognizer*)gesture
{
    // figure out column
    int categoryIndex = floor(gesture.view.frame.origin.x / COLUMN_WIDTH);
    
    // then the session
    int sessionIndex = gesture.view.tag;
    
    NSLog(@"Tapped: %d, %d", categoryIndex, sessionIndex);
    
    NSDictionary *category = [_categories objectAtIndex:categoryIndex];
    NSString *categoryURI = [category objectForKey:@"uri"];
    NSDictionary *session = nil;
    
    for(NSDictionary *s in _sessions) {
        if([[s objectForKey:@"category"] isEqualToString:categoryURI]) {
            if([[s objectForKey:@"sessionIndex"] intValue] == sessionIndex) {
                session = s;
                break;
            }
        }
    }
    
    if(session != nil) {
        // push the view controller with the session information
        SessionDetailViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SessionDetailViewController"];
        vc.hidesBottomBarWhenPushed = YES;
        vc.category = category;
        vc.session = session;
        [self.navigationController pushViewController:vc animated:TRUE];
    }
    
    
}

- (void) createSession:(NSDictionary*)sessionInfo
{
    double startTimeExact = [[sessionInfo objectForKey:@"startTimeExact"] doubleValue];
    double endTimeExact = 0;
    BOOL lastSession = FALSE;
    BOOL end_of_day = [[sessionInfo objectForKey:@"end_of_day"] intValue] == 1;
    BOOL networking_break = [[sessionInfo objectForKey:@"networking_break"] intValue] == 1;
    
    if([sessionInfo objectForKey:@"endTimeExact"] != nil) {
        endTimeExact =[[sessionInfo objectForKey:@"endTimeExact"] doubleValue];
    } else {
        endTimeExact = startTimeExact + 0.17;
        lastSession = TRUE;
    }
    
    NSString *startTimeString = [sessionInfo objectForKey:@"startTimeString"];
    NSString *endTimeString = [sessionInfo objectForKey:@"endTimeString"];
    
    int day = [[sessionInfo objectForKey:@"day"] intValue];
    
//    NSLog(@"Creating session[%d/%g-%g][%@] => %@", day, startTimeExact, endTimeExact, categoryID, [sessionInfo objectForKey:@"title"]);
    
    CGFloat y = 0;
    CGFloat x = 0;
    CGFloat height = (endTimeExact - startTimeExact) * HOUR_HEIGHT;
    CGFloat width = COLUMN_WIDTH - 2*PADDING_HORIZONTAL;
    
    if(day == 1) {
        y = PADDING_VERTICAL + (startTimeExact - FIRST_DAY_START) * HOUR_HEIGHT;
    } else {
        y = PADDING_VERTICAL + HOUR_HEIGHT * FIRST_DAY_LENGTH + (startTimeExact - SECOND_DAY_START) * HOUR_HEIGHT;
    }
    
    // get the category index
    int ndx = -1;
    
    int trackingIndex = 0;
    for(NSDictionary *category in _categories) {
        if([[sessionInfo objectForKey:@"category"] isEqualToString:[category objectForKey:@"uri"]]) {
            ndx = trackingIndex;
            break;
        }
        ++trackingIndex;
    }

    x = PADDING_HORIZONTAL + ndx * COLUMN_WIDTH;
    
    CGFloat textPadding = 5.0f;
    CGFloat borderWidth = 4.0f;
    
    UIColor *backgroundColor = [UIColor whiteColor];
    UIColor *leftBarBackground = [UIColor lightGrayColor];
    if(end_of_day) {
        backgroundColor = [UIColor darkGrayColor];
        leftBarBackground = [UIColor clearColor];
    } else if(networking_break) {
        backgroundColor = [UIColor colorWithHex:@"90EE90"];
        leftBarBackground = [UIColor colorWithHex:@"90EE90"];
    }
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    v.backgroundColor = backgroundColor;
    v.tag = [[sessionInfo objectForKey:@"sessionIndex"] intValue];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sessionTapped:)];
    [v addGestureRecognizer:tap];
    
    [_contentView addSubview:v];

    
    UIView *leftBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, borderWidth, v.frame.size.height)];
    leftBar.backgroundColor = leftBarBackground;
    [v addSubview:leftBar];
    
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, height-borderWidth, width, borderWidth)];
    bottomBar.backgroundColor = BACKGROUND_COLOR;
    [v addSubview:bottomBar];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(borderWidth+textPadding, textPadding, width-borderWidth-textPadding*2, 40)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.numberOfLines = 3;
    titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    titleLabel.textAlignment = end_of_day ? NSTextAlignmentCenter : NSTextAlignmentLeft;
    titleLabel.text = [sessionInfo objectForKey:@"title"];

    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(titleLabel.frame.size.width, FLT_MAX);
    CGSize expectedLabelSize = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:maximumLabelSize lineBreakMode:titleLabel.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = titleLabel.frame;
    newFrame.size.height = MIN(expectedLabelSize.height, 40.0f/*max height*/);
    titleLabel.frame = newFrame;
    
    CGFloat fontSize = [titleLabel.text fontSizeWithFont:titleLabel.font constrainedToSize:titleLabel.frame.size];
    titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];

    maximumLabelSize = CGSizeMake(titleLabel.frame.size.width, FLT_MAX);
    expectedLabelSize = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:maximumLabelSize lineBreakMode:titleLabel.lineBreakMode];
    
    //adjust the label the the new height.
    newFrame = titleLabel.frame;
    newFrame.size.height = MIN(expectedLabelSize.height, 40.0f/*max height*/);
    titleLabel.frame = newFrame;
    
    [v addSubview:titleLabel];
    
    [titleLabel setAdjustsFontSizeToFitWidth:TRUE];
    
    NSString *timeText = startTimeString;
    if(!lastSession) {
        timeText = [NSString stringWithFormat:@"%@-%@", startTimeString, endTimeString];
    }
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(width-67, height-19, 63, 15)];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.textColor = [UIColor lightGrayColor];
    timeLabel.text = timeText;
    if(!lastSession) {
        [v addSubview:timeLabel];
    } else {
        CGRect f = v.frame;
        f.size.height = 40.f;
        v.frame = f;
        
        f = titleLabel.frame;
        f.origin.x = 0;
        f.origin.y = 0;
        f.size.height = 40.f;
        f.size.width = v.frame.size.width;
        titleLabel.frame = f;
    }

    
    CGFloat descriptionY = titleLabel.frame.size.height+titleLabel.frame.origin.y;
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(borderWidth+textPadding, descriptionY, width-borderWidth-textPadding*2, timeLabel.frame.origin.y - descriptionY)];
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.font = [UIFont systemFontOfSize:12.0f];
    descriptionLabel.numberOfLines = 100;
    descriptionLabel.lineBreakMode = NSLineBreakByCharWrapping;
    descriptionLabel.textColor = [UIColor blackColor];
    descriptionLabel.text = [sessionInfo objectForKey:@"description"];
    
    maximumLabelSize = CGSizeMake(descriptionLabel.frame.size.width, descriptionLabel.frame.size.height);
    expectedLabelSize = [descriptionLabel.text sizeWithFont:descriptionLabel.font constrainedToSize:maximumLabelSize lineBreakMode:descriptionLabel.lineBreakMode];
    
    //adjust the label the the new height.
    newFrame = descriptionLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    descriptionLabel.frame = newFrame;
    
    [v addSubview:descriptionLabel];

    
    // update the content size (if needed)
    CGFloat maxX = 0.f;
    CGFloat maxY = 0.f;
    
    for(UIView *v in _contentView.subviews) {
        if(v.frame.origin.x + v.frame.size.width > maxX) {
            maxX = v.frame.origin.x + v.frame.size.width + PADDING_HORIZONTAL;
        }
        
        if(v.frame.origin.y + v.frame.size.height > maxY) {
            maxY = v.frame.origin.y + v.frame.size.height;
        }
    }
    
    _contentView.contentSize = CGSizeMake(maxX, maxY);
}

- (void) populateSessions
{
    _sessions = [[NSMutableArray alloc] init];
    
    NSArray *downloadedSessions = [[NSUserDefaults standardUserDefaults] objectForKey:BUCKET_SCHEDULE_SESSIONS];
    for(NSDictionary *session in downloadedSessions) {
        [self createSession:session];
        [_sessions addObject:session];
    }
    
    [_contentView setContentOffset:CGPointMake(0, 0)];
    _timeLabel.text = @"Day 1 - 0900";
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];

}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _contentView.backgroundColor = BACKGROUND_COLOR;
    
    NSArray *results = [[NSUserDefaults standardUserDefaults] objectForKey:BUCKET_SCHEDULE_CATEGORIES];
    NSArray *sessionResults = [[NSUserDefaults standardUserDefaults] objectForKey:BUCKET_SCHEDULE_SESSIONS];
    
    // if we don't have anything yet
    if(results == nil || sessionResults == nil) {
        
        [KTLoader showLoader:@"Downloading Categories"];
        
        // load the sessions
        KiiBucket *bucket = [Kii bucketWithName:BUCKET_SCHEDULE_CATEGORIES];
        KiiQuery *query = [KiiQuery queryWithClause:nil];
        [query sortByAsc:@"priority"];
        [bucket executeQuery:query
                   withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
                       
                       if(error == nil) {

                           // generate a string of arrays from the results
                           NSMutableArray *dictArrays = [NSMutableArray array];
                           for(KiiObject *o in results) {
                               NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:[o dictionaryValue]];
                               [newDict setObject:[o objectURI] forKey:@"uri"];
                               [newDict setObject:[o uuid] forKey:@"uuid"];
                               [dictArrays addObject:(NSDictionary*)newDict];
                           }
                           
                           // store the string to prefs
                           [[NSUserDefaults standardUserDefaults] setObject:dictArrays forKey:BUCKET_SCHEDULE_CATEGORIES];
                           [[NSUserDefaults standardUserDefaults] synchronize];
                           
                           [self buildCategoryView];
                           
                           // now load the sessions
                           [KTLoader showLoader:@"Downloading Sessions"];
                           
                           KiiBucket *sessionBucket = [Kii bucketWithName:BUCKET_SCHEDULE_SESSIONS];
                           KiiQuery *sessionQuery = [KiiQuery queryWithClause:nil];
                           [sessionBucket executeQuery:sessionQuery
                                             withBlock:^(KiiQuery *query, KiiBucket *bucket, NSArray *results, KiiQuery *nextQuery, NSError *error) {
                                                 
                                                 if(error == nil) {

                                                     // generate a string of arrays from the results
                                                     NSMutableArray *dictArrays = [NSMutableArray array];
                                                     for(KiiObject *o in results) {
                                                         NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:[o dictionaryValue]];
                                                         [newDict setObject:[o objectURI] forKey:@"uri"];
                                                         [newDict setObject:[o uuid] forKey:@"uuid"];
                                                         [dictArrays addObject:(NSDictionary*)newDict];
                                                     }
                                                     
                                                     // store the string to prefs
                                                     [[NSUserDefaults standardUserDefaults] setObject:dictArrays forKey:BUCKET_SCHEDULE_SESSIONS];
                                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                                     
                                                     // and reload the table
                                                     [self populateSessions];

                                                     [KTLoader hideLoader];
                                                 }
                                                 
                                                 else {
                                                     
                                                     [KTLoader showLoader:@"Error loading!"
                                                                 animated:TRUE
                                                            withIndicator:KTLoaderIndicatorError
                                                          andHideInterval:KTLoaderDurationAuto];
                                                     
                                                 }
                                                 
                                                 
                                             }];

                       }
                       
                       else {
                           
                           [KTLoader showLoader:@"Error loading!"
                                       animated:TRUE
                                  withIndicator:KTLoaderIndicatorError
                                andHideInterval:KTLoaderDurationAuto];

                       }
                       
                   }];
        
    } else {
        
        [self buildCategoryView];
        [self populateSessions];
        
    }

}

#pragma mark - UIScrollViewDelegate
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    _categoryView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    _contentView.contentOffset = CGPointMake(scrollView.contentOffset.x, _contentView.contentOffset.y);
    
    CGFloat firstDayHeight = HOUR_HEIGHT * FIRST_DAY_LENGTH;
    
    int day = (scrollView.contentOffset.y > firstDayHeight) ? 2 : 1;
    CGFloat hr = (day == 1) ? scrollView.contentOffset.y / HOUR_HEIGHT : (scrollView.contentOffset.y - firstDayHeight) / HOUR_HEIGHT;
    hr += FIRST_DAY_START;
    
    NSString *base = [NSString stringWithFormat:@"%04d", (int)(hr*100)];
    NSString *hour = [base substringToIndex:2];
    NSString *min = [base substringFromIndex:2];
    
    int minFloat = [min intValue] * 60 / 100;
    
    _timeLabel.text = [NSString stringWithFormat:@"Day %d - %@%02d", day, hour, minFloat];
}

@end
