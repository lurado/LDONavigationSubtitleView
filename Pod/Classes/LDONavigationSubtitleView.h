//
//  LDONavigationSubtitleView.h
//  LDONavigationSubtitleView
//
//  Created by Sebastian Ludwig on 10.07.15.
//  Copyright (c) 2015 Julian Raschke und Sebastian Ludwig GbR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDONavigationSubtitleView : UIView

@property (nonatomic, copy) IBInspectable NSString *title;
@property (nonatomic, copy) IBInspectable NSString *subtitle;

@property (nonatomic) IBInspectable NSInteger spacing;

@property (nonatomic) IBInspectable UIColor *titleColor;
@property (nonatomic) IBInspectable UIColor *subtitleColor;

@property (nonatomic) IBInspectable UIFont *regularTitleFont;
@property (nonatomic) IBInspectable UIFont *compactTitleFont;

@property (nonatomic) IBInspectable UIFont *regularSubtitleFont;
@property (nonatomic) IBInspectable UIFont *compactSubtitleFont;

@property (nonatomic) IBInspectable BOOL animateChanges;


@property (nonatomic) IBOutlet UIView *subtitleView;
@property (nonatomic, weak) IBOutlet UIViewController *viewController;

@end
