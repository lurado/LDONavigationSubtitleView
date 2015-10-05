//
//  LDONavigationSubtitleView.m
//  LDONavigationSubtitleView
//
//  Created by Sebastian Ludwig on 10.07.15.
//  Copyright (c) 2015 Sebastian Ludwig. All rights reserved.
//

#import "LDONavigationSubtitleView.h"

@implementation LDONavigationSubtitleView
{
    UINavigationBar *navigationBar;
    UILabel *titleLabel;
    UILabel *subtitleLabel;
    
    NSString *subtitle;
    
    BOOL needsAnimatedLabelLayout;
    
    BOOL setFrameCalled;
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
    
    self.viewController = _viewController;      // trigger setter logic
}

- (void)initialize
{
    self.backgroundColor = [UIColor clearColor];
    self.spacing = 1;
    self.animateChanges = YES;
    
    setFrameCalled = NO;
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self addSubview:titleLabel];
    [self addSubview:subtitleLabel];
}

- (void)applyDefaults
{
    self.regularTitleFont = self.regularTitleFont ?: [UIFont boldSystemFontOfSize:17];
    self.compactTitleFont = self.compactTitleFont ?: [UIFont boldSystemFontOfSize:16];
    self.regularSubtitleFont = self.regularSubtitleFont ?: [UIFont systemFontOfSize:12];
    self.compactSubtitleFont = self.compactSubtitleFont ?: [UIFont systemFontOfSize:12];
    self.titleColor = self.titleColor ?: [UIColor blackColor];
    self.subtitleColor = self.subtitleColor ?: [UIColor lightGrayColor];
}

- (void)dealloc
{
    [_viewController removeObserver:self forKeyPath:@"title"];
}

- (void)setViewController:(UIViewController *)viewController
{
    [_viewController removeObserver:self forKeyPath:@"title"];
    _viewController = viewController;
    self.title = _viewController.title;
    [_viewController addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"title"]) {
        self.title = change[NSKeyValueChangeNewKey];
    }
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
    setFrameCalled = YES;
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
    [super layoutSubviews];
 
    [self layoutLabelsAnimated:needsAnimatedLabelLayout];
}

- (void)layoutLabelsAnimated:(BOOL)animated
{
    if (!setFrameCalled) {             // this is necessary to prevent an animation when the view is initially added to the navigation bar
        return;
    }
    
    if (animated) {
        needsAnimatedLabelLayout = NO;
    }
    
    BOOL titleLabelWasInvisible = CGRectEqualToRect(titleLabel.frame, CGRectZero);
    BOOL subtitleLabelWasInvisible = CGRectEqualToRect(subtitleLabel.frame, CGRectZero);
    
    [self findNavigationBar];
    
    CGRect navigationBarFrame = navigationBar ? navigationBar.frame : self.frame;
    
    BOOL navigationBarIsCompact = navigationBarFrame.size.height < 43;
    titleLabel.font = navigationBarIsCompact ? self.compactTitleFont : self.regularTitleFont;
    subtitleLabel.font = navigationBarIsCompact ? self.compactSubtitleFont : self.regularSubtitleFont;
    
    titleLabel.textColor = self.titleColor;
    subtitleLabel.textColor = self.subtitleColor;
    
    CGSize titleSize = [titleLabel sizeThatFits:titleLabel.bounds.size];
    CGRect titleFrame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, titleSize.width, titleSize.height);
    
    CGRect subtitleFrame = CGRectZero;
    if (subtitle || !animated) {            // if no subtitle but animated, keep the text until the animation is finished - otherwise (this case) change instantly
        
        // crossfade text change animation, if new subtitle does not contain the old subtitle
        if (animated && subtitle && subtitleLabel.text) {
            BOOL contained = [subtitle rangeOfString:subtitleLabel.text].location != NSNotFound || [subtitleLabel.text rangeOfString:subtitle].location != NSNotFound;
            if (!contained) {
                CATransition *animation = [CATransition animation];
                animation.duration = 1.0;
                animation.type = kCATransitionFade;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [subtitleLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
            }
        }
        
        subtitleLabel.text = subtitle;

        CGSize subtitleSize = [subtitleLabel sizeThatFits:subtitleLabel.bounds.size];
        subtitleFrame = CGRectMake(subtitleFrame.origin.x, subtitleFrame.origin.y, subtitleSize.width, subtitleSize.height);
    }
    
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
    
    if (titleLabelWasInvisible || !animated) {
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
    
    if (subtitleLabel.alpha > 0.9) {    // was visible
        if (!shouldBeVisible) {             // will become invisible
            if (animated) {                     // animated
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     subtitleLabel.alpha = 0;
                                 } completion:^(BOOL finished) {
                                     if (finished) {
                                         subtitleLabel.hidden = YES;
                                         subtitleLabel.text = subtitle;
                                     }
                                 }];
            } else {                            // without animation
                subtitleLabel.alpha = 0;
                subtitleLabel.hidden = YES;
            }
        } else {                                                        // will cahnge frame
            if (subtitleLabelWasInvisible || !animated) {                   // without animated
                subtitleLabel.frame = subtitleFrame;
            } else {                                                        // animation
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     subtitleLabel.frame = subtitleFrame;
                                 }];
            }
        }
    } else if (shouldBeVisible) {       // was not visible
        subtitleLabel.frame = subtitleFrame;
        subtitleLabel.alpha = 0;
        subtitleLabel.hidden = NO;
        if (animated) {
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
    needsAnimatedLabelLayout = self.animateChanges;
    [self setNeedsLayout];
}

- (NSString *)subtitle
{
    return subtitle;
}

- (void)setSubtitle:(NSString *)text
{
    subtitle = text;
    needsAnimatedLabelLayout = self.animateChanges;
    [self setNeedsLayout];
}

@end
