//
//  SLNavigationSubtitleView.m
//  SLNavigationSubtitleView
//
//  Created by Sebastian Ludwig on 10.07.15.
//  Copyright (c) 2015 Sebastian Ludwig. All rights reserved.
//

#import "SLNavigationSubtitleView.h"

@implementation SLNavigationSubtitleView
{
    UINavigationBar *navigationBar;
    UILabel *titleLabel;
    UILabel *subtitleLabel;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
        [self applyDefaults];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self applyDefaults];
}

- (void)initialize
{
    self.backgroundColor = [UIColor clearColor];
    self.spacing = 1;
    self.animateChanges = YES;
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
//    self.backgroundColor = [UIColor blueColor];
//    titleLabel.backgroundColor = [UIColor redColor];
//    subtitleLabel.backgroundColor = [UIColor greenColor];
    
    [self addSubview:titleLabel];
    [self addSubview:subtitleLabel];
}

- (void)applyDefaults
{
    self.regularTitleFont = self.regularTitleFont ?: [UIFont boldSystemFontOfSize:17];
    self.compactTitleFont = self.compactTitleFont ?: [UIFont boldSystemFontOfSize:17];
    self.regularSubtitleFont = self.regularSubtitleFont ?: [UIFont systemFontOfSize:12];
    self.compactSubtitleFont = self.compactSubtitleFont ?: [UIFont systemFontOfSize:12];
    self.titleColor = self.titleColor ?: [UIColor blackColor];
    self.subtitleColor = self.subtitleColor ?: [UIColor lightGrayColor];
}

- (void)findNavigationBar {
    if (navigationBar) {
        return;
    }
    
    if (!navigationBar) {
        UIView *parent = self.superview;
        while (parent && ![parent isKindOfClass:[UINavigationBar class]]) {
            parent = parent.superview;
        }
        
        navigationBar = (UINavigationBar *)parent;
    }
}

- (void)setFrame:(CGRect)frame
{
    [self findNavigationBar];
    
    if (navigationBar) {
        frame.origin.y = 0;
        frame.size.height = navigationBar.frame.size.height;
        
        [super setFrame:CGRectIntegral(frame)];
    } else {
        [super setFrame:frame];
    }
}

- (CGRect)xAlignFrame:(CGRect)frame navigationBarFrame:(CGRect)navigationBarFrame
{
    CGFloat centerOffsetX = CGRectGetMidX(navigationBarFrame) - CGRectGetMidX(self.frame);
    
    frame.size.width = MIN(frame.size.width, self.frame.size.width);
    
    // center
    frame.origin.x = (self.frame.size.width - frame.size.width) / 2 + centerOffsetX;
    
    // constrain right edge
    CGFloat rightOverflow = CGRectGetMaxX(frame) - self.frame.size.width;    // if the label is too large, offset it so it's right edge is still inside this view
    frame.origin.x -= MAX(0, rightOverflow);
    
    // constrain left edge
    frame.origin.x = MAX(0, frame.origin.x);
    
    return CGRectIntegral(frame);
}

- (void)layoutSubviews
{
    BOOL titleLabelWasInvisible = CGRectEqualToRect(titleLabel.frame, CGRectZero);
    BOOL subtitleLabelWasInvisible = CGRectEqualToRect(subtitleLabel.frame, CGRectZero);
    
    [super layoutSubviews];
    
    [self findNavigationBar];
    
    CGRect navigationBarFrame = navigationBar ? navigationBar.frame : self.frame;
    
    BOOL navigationBarIsCompact = navigationBarFrame.size.height < 43;
    titleLabel.font = navigationBarIsCompact ? self.compactTitleFont : self.regularTitleFont;
    subtitleLabel.font = navigationBarIsCompact ? self.compactSubtitleFont : self.regularSubtitleFont;

    titleLabel.textColor = self.titleColor;
    subtitleLabel.textColor = self.subtitleColor;
    
    [titleLabel sizeToFit];
    [subtitleLabel sizeToFit];
    
    CGRect titleFrame = titleLabel.frame;
    CGRect subtitleFrame = subtitleLabel.frame;
    
    // vertical positioning
    if (!subtitleLabel.text) {
        titleFrame.origin.y = (self.frame.size.height - titleFrame.size.height) / 2;
        if (navigationBarIsCompact) {
            titleFrame.origin.y -= 1;
        }
    } else {
        titleFrame.origin.y = (self.frame.size.height - (titleFrame.size.height + subtitleFrame.size.height + self.spacing)) / 2;
        titleFrame.origin.y = MAX(0, titleFrame.origin.y);    // prevent top overflow: align no further down than justified with the top edge
        
        subtitleFrame.origin.y = CGRectGetMaxY(titleFrame) + self.spacing;
        subtitleFrame.origin.y = MIN(subtitleFrame.origin.y, self.frame.size.height - subtitleFrame.size.height);   // prevent bottom overflow: align bottom edge justified with parent frame
    }

    // horizontal positioning
    titleFrame = [self xAlignFrame:titleFrame navigationBarFrame:navigationBarFrame];
    subtitleFrame = [self xAlignFrame:subtitleFrame navigationBarFrame:navigationBarFrame];
    
    
    // animations
    
    if (titleLabelWasInvisible || !self.animateChanges) {
        titleLabel.frame = titleFrame;
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            titleLabel.frame = titleFrame;
        }];
    }
    
    // was visible
        // will become invisible
        // will become invisible animated
        // will change frame
        // will change frame animated
    
    // was not visible
        // will become visible
        // will become visible animated

    BOOL shouldBeVisible = self.subtitle != nil;

    if (!subtitleLabel.hidden) {        // was visible
        if (!shouldBeVisible) {             // will become invisible
            if (self.animateChanges) {          // animated
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     subtitleLabel.alpha = 0;
                                 } completion:^(BOOL finished) {
                                     subtitleLabel.hidden = YES;
                                 }];
            } else {                            // without animation
                subtitleLabel.alpha = 0;
                subtitleLabel.hidden = YES;
            }
        } else {                                                        // will cahnge frame
            if (subtitleLabelWasInvisible || !self.animateChanges) {        // without animated
                subtitleLabel.frame = subtitleFrame;
            } else {                                                        // animation
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     subtitleLabel.frame = subtitleFrame;
                                 }];
            }
        }
    } else if (shouldBeVisible) {   // was not visible
        subtitleLabel.frame = subtitleFrame;
        subtitleLabel.alpha = 0;
        subtitleLabel.hidden = NO;
        if (self.animateChanges) {
            [UIView animateWithDuration:0.3 animations:^{
                subtitleLabel.alpha = 1;
            }];
        } else {
            subtitleLabel.alpha = 1;
        }
    }
}

- (NSString *)title
{
    return titleLabel.text;
}

- (void)setTitle:(NSString *)text
{
    titleLabel.text = text;
    [self setNeedsLayout];
}

- (NSString *)subtitle
{
    return subtitleLabel.text;
}

- (void)setSubtitle:(NSString *)text
{
    subtitleLabel.text = text;
    [self setNeedsLayout];
}

@end
