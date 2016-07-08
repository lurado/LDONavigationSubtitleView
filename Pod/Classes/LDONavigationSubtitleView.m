//
//  LDONavigationSubtitleView.m
//  LDONavigationSubtitleView
//
//  Created by Sebastian Ludwig on 10.07.15.
//  Copyright (c) 2015 Julian Raschke und Sebastian Ludwig GbR. All rights reserved.
//

#import "LDONavigationSubtitleView.h"

@interface LDONavigationSubtitleView ()

@property (nonatomic) UINavigationBar *navigationBar;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *subtitleLabel;
    
@property (nonatomic) BOOL needsAnimatedLabelLayout;
    
@property (nonatomic) BOOL setFrameCalled;

@property (nonatomic) NSArray<NSString *> *watchedKeyPaths;
@property (nonatomic) BOOL observingKeyPaths;

@end

@implementation LDONavigationSubtitleView

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

- (void)initialize
{
    self.watchedKeyPaths = @[
                             @"title",
                             @"navigationItem.title",
                             @"navigationItem.leftBarButtonItem",
                             @"navigationItem.leftBarButtonItems",
                             @"navigationItem.rightBarButtonItem",
                             @"navigationItem.rightBarButtonItems"
                             ];
    self.backgroundColor = [UIColor clearColor];
    _spacing = 1;
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _subtitleView = _subtitleLabel;
    
    [self addSubview:_titleLabel];
    [self addSubview:_subtitleLabel];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self applyDefaults];
    
    self.viewController = _viewController;      // trigger setter logic
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

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    [self removeKVO];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    [self addKVO];
}

- (void)removeKVO
{
    if (!self.observingKeyPaths) {
        return;
    }
    
    for (NSString *keyPath in self.watchedKeyPaths) {
        [self.viewController removeObserver:self forKeyPath:keyPath];
    }
    self.observingKeyPaths = NO;
}

- (void)addKVO
{
    if (self.observingKeyPaths || !self.viewController) {
        return;
    }
    
    for (NSString *keyPath in self.watchedKeyPaths) {
        [self.viewController addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    }
    self.observingKeyPaths = YES;
}

- (void)setSubtitleView:(UIView *)subtitleView
{
    _subtitleView = subtitleView;
    if (subtitleView) {
        [self.subtitleLabel removeFromSuperview];
        [self addSubview:subtitleView];
    } else {
        [self.subtitleView removeFromSuperview];
        [self addSubview:self.subtitleLabel];
    }
}

- (void)setViewController:(UIViewController *)viewController
{
    [self removeKVO];
    _viewController = viewController;
    self.title = _viewController.title ?: _viewController.navigationItem.title;
    [self addKVO];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"title"]) {
        self.title = change[NSKeyValueChangeNewKey];
    } else {
        [self setNeedsLayout];
    }
}

- (void)findNavigationBar {
    if (self.navigationBar) {
        return;
    }
    
    
    UIView *parent = self.superview;
    while (parent && ![parent isKindOfClass:[UINavigationBar class]]) {
        parent = parent.superview;
    }
    
    self.navigationBar = (UINavigationBar *)parent;
}

- (void)setFrame:(CGRect)frame
{
    self.setFrameCalled = YES;
    [self findNavigationBar];
    
    if (self.navigationBar) {
        frame.origin.y = 0;
        frame.size.height = self.navigationBar.frame.size.height;
        
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
 
    [self layoutLabelsAnimated:self.needsAnimatedLabelLayout];
}

- (void)layoutLabelsAnimated:(BOOL)animated
{
    if (!self.setFrameCalled) {             // this is necessary to prevent an animation when the view is initially added to the navigation bar
        return;
    }
    
    if (animated) {
        self.needsAnimatedLabelLayout = NO;
    }
    
    BOOL titleLabelWasInvisible = CGRectEqualToRect(self.titleLabel.frame, CGRectZero);
    BOOL subtitleViewWasInvisible = CGRectEqualToRect(self.subtitleView.frame, CGRectZero);
    
    [self findNavigationBar];
    
    CGRect navigationBarFrame = self.navigationBar ? self.navigationBar.frame : self.frame;
    
    BOOL navigationBarIsCompact = navigationBarFrame.size.height < 43;
    self.titleLabel.font = navigationBarIsCompact ? self.compactTitleFont : self.regularTitleFont;
    self.subtitleLabel.font = navigationBarIsCompact ? self.compactSubtitleFont : self.regularSubtitleFont;
    
    self.titleLabel.textColor = self.titleColor;
    self.subtitleLabel.textColor = self.subtitleColor;
    
    CGSize titleSize = [self.titleLabel sizeThatFits:self.titleLabel.bounds.size];
    CGRect titleFrame = CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y, titleSize.width, titleSize.height);
    
    BOOL customSubtitleView = self.subtitleView != self.subtitleLabel;
    CGRect subtitleFrame = CGRectZero;
    if (customSubtitleView) {
        subtitleFrame = self.subtitleView.frame;
    } else if (self.subtitle || !animated) {            // if no subtitle but animated, keep the text until the animation is finished - otherwise (this case) change instantly
        
        // crossfade text change animation, if new subtitle does not contain the old subtitle
        if (animated && self.subtitle && self.subtitleLabel.text) {
            BOOL contained = [self.subtitle rangeOfString:self.subtitleLabel.text].location != NSNotFound || [self.subtitleLabel.text rangeOfString:self.subtitle].location != NSNotFound;
            if (!contained) {
                CATransition *animation = [CATransition animation];
                animation.duration = 1.0;
                animation.type = kCATransitionFade;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [self.subtitleLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
            }
        }
        
        self.subtitleLabel.text = self.subtitle;

        CGSize subtitleSize = [self.subtitleLabel sizeThatFits:self.subtitleLabel.bounds.size];
        subtitleFrame = CGRectMake(0, 0, subtitleSize.width, subtitleSize.height);
    }
    
    // vertical positioning
    if (self.subtitleLabel.text || customSubtitleView) {
        titleFrame.origin.y = (self.frame.size.height - (titleFrame.size.height + subtitleFrame.size.height + self.spacing)) / 2;
        titleFrame.origin.y = MAX(0, titleFrame.origin.y);    // prevent top overflow: align no further down than justified with the top edge
        
        subtitleFrame.origin.y = CGRectGetMaxY(titleFrame) + self.spacing;
        subtitleFrame.origin.y = MIN(subtitleFrame.origin.y, self.frame.size.height - subtitleFrame.size.height);   // prevent bottom overflow: align bottom edge justified with parent frame
    } else {
        titleFrame.origin.y = (self.frame.size.height - titleFrame.size.height) / 2;
        if (navigationBarIsCompact) {
            titleFrame.origin.y -= 1;
        }
    }
    
    // horizontal positioning
    titleFrame = [self xAlignFrame:titleFrame navigationBarFrame:navigationBarFrame];
    subtitleFrame = [self xAlignFrame:subtitleFrame navigationBarFrame:navigationBarFrame];
    
    
    // animations
    
    if (titleLabelWasInvisible || !animated) {
        self.titleLabel.frame = titleFrame;
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.titleLabel.frame = titleFrame;
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
    
    BOOL shouldBeVisible = self.subtitle != nil || customSubtitleView;
    
    if (self.subtitleView.alpha > 0.9) {    // was visible
        if (!shouldBeVisible) {             // will become invisible
            if (animated) {                     // animated
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     self.subtitleView.alpha = 0;
                                 } completion:^(BOOL finished) {
                                     if (finished) {
                                         self.subtitleView.hidden = YES;
                                         self.subtitleLabel.text = self.subtitle;
                                     }
                                 }];
            } else {                            // without animation
                self.subtitleView.alpha = 0;
                self.subtitleView.hidden = YES;
            }
        } else {                                                        // will cahnge frame
            if (subtitleViewWasInvisible || !animated) {                   // without animated
                self.subtitleView.frame = subtitleFrame;
            } else {                                                        // animation
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     self.subtitleView.frame = subtitleFrame;
                                 }];
            }
        }
    } else if (shouldBeVisible) {       // was not visible
        self.subtitleView.frame = subtitleFrame;
        self.subtitleView.alpha = 0;
        self.subtitleView.hidden = NO;
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^{
                self.subtitleView.alpha = 1;
            }];
        } else {
            self.subtitleView.alpha = 1;
        }
    }
}

- (NSString *)title
{
    return self.titleLabel.text;
}

- (void)setTitle:(NSString *)text
{
    self.titleLabel.text = text;
    self.needsAnimatedLabelLayout = self.animateChanges;
    [self setNeedsLayout];
}

- (void)setSubtitle:(NSString *)text
{
    _subtitle = text;
    self.needsAnimatedLabelLayout = self.animateChanges;
    [self setNeedsLayout];
}

@end
