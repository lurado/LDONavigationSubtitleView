//
//  LDOViewController.m
//  LDONavigationSubtitleView
//
//  Created by Sebastian Ludwig on 10.07.15.
//  Copyright (c) 2015 Julian Raschke und Sebastian Ludwig GbR. All rights reserved.
//

#import "ViewController.h"

#import <LDONavigationSubtitleView/LDONavigationSubtitleView.h>

@interface ViewController () <UITextFieldDelegate>

@end

@implementation ViewController
{
    IBOutlet LDONavigationSubtitleView *navigationView;
    IBOutlet UITextField *titleText;
    IBOutlet UITextField *subtitleText;
    IBOutlet UITextField *leftBarButtonText;
    IBOutlet UITextField *rightBarButtonText;
    
    IBOutlet UISwitch *showSubtitle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = titleText.text;
    navigationView.animateChanges = YES;
}

- (IBAction)updateTitleView
{
    self.title = titleText.text;
    if (![subtitleText.text isEqualToString:@""] && showSubtitle.on) {
        navigationView.subtitle = subtitleText.text;
    } else {
        navigationView.subtitle = nil;
    }
}

- (IBAction)toggleTitleView:(UISegmentedControl *)sender
{
    [self updateTitleView];
    
    if (sender.selectedSegmentIndex == 0) {
        self.navigationItem.titleView = nil;
    } else {
        self.navigationItem.titleView = navigationView;
    }
}

- (IBAction)toggleSubtitle:(UISwitch *)sender
{
    [self updateTitleView];
}

- (IBAction)toggleAnimations:(UISwitch *)sender
{
    navigationView.animateChanges = sender.on;
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
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:rightBarButtonText.text style:UIBarButtonItemStylePlain target:nil action:nil];
            [self.navigationItem setRightBarButtonItem:item animated:YES];
            [navigationView setNeedsLayout];
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
