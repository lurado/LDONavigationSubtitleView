//
//  SLViewController.m
//  SLNavigationSubtitleView
//
//  Created by Sebastian Ludwig on 10.07.15.
//  Copyright (c) 2015 Sebastian Ludwig. All rights reserved.
//

#import "SLViewController.h"

#import <SLNavigationSubtitleView/SLNavigationSubtitleView.h>

@interface SLViewController () <UITextFieldDelegate>

@end

@implementation SLViewController
{
    IBOutlet SLNavigationSubtitleView *subtitleView;
    IBOutlet UITextField *titleText;
    IBOutlet UITextField *subtitleText;
    IBOutlet UITextField *leftBarButtonText;
    IBOutlet UITextField *rightBarButtonText;
    
    BOOL showSubtitle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    showSubtitle = YES;
    self.title = titleText.text;
}

- (IBAction)updateTitleView
{
    self.title = titleText.text;
    if (![subtitleText.text isEqualToString:@""] && showSubtitle) {
        subtitleView.subtitle = subtitleText.text;
    } else {
        subtitleView.subtitle = nil;
    }
}

- (IBAction)toggleTitleView:(UISegmentedControl *)sender
{
    [self updateTitleView];
    
    if (sender.selectedSegmentIndex == 0) {
        self.navigationItem.titleView = nil;
    } else {
        self.navigationItem.titleView = subtitleView;
    }
}

- (IBAction)toggleSubtitle:(UISwitch *)sender
{
    showSubtitle = sender.on;
    [self updateTitleView];
}

- (IBAction)toggleAnimations:(UISwitch *)sender
{
    subtitleView.animateChanges = sender.on;
}

- (IBAction)barButtonTextDidChange:(UITextField *)sender
{
    if (sender == leftBarButtonText) {
        if (self.navigationItem.leftBarButtonItem) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:leftBarButtonText.text style:UIBarButtonItemStylePlain target:nil action:nil];
        }
    } else {
        if (self.navigationItem.rightBarButtonItem) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:rightBarButtonText.text style:UIBarButtonItemStylePlain target:nil action:nil];
        }
    }
}

- (IBAction)toggleBarButtonItem:(UIButton *)sender
{
    if (sender.tag == 0) {
        if (self.navigationItem.leftBarButtonItem) {
            self.navigationItem.leftBarButtonItem = nil;
            [sender setTitle:@"Show" forState:UIControlStateNormal];
        } else {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:leftBarButtonText.text style:UIBarButtonItemStylePlain target:nil action:nil];
            [sender setTitle:@"Hide" forState:UIControlStateNormal];
        }
    } else {
        if (self.navigationItem.rightBarButtonItem) {
            self.navigationItem.rightBarButtonItem = nil;
            [sender setTitle:@"Show" forState:UIControlStateNormal];
        } else {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:rightBarButtonText.text style:UIBarButtonItemStylePlain target:nil action:nil];
            [sender setTitle:@"Hide" forState:UIControlStateNormal];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self updateTitleView];
    [textField resignFirstResponder];
    return YES;
}

@end
