//
//  JHPreferencePaneWindowController.m
//  jaml-editor
//
//  Created by Jedd Haberstro on 1/2/12.
//  Copyright (c) 2012 Student. All rights reserved.
//

#import "JHPreferencePaneWindowController.h"
#import "ThemePreferenceViewController.h"

@implementation JHPreferencePaneWindowController

@synthesize themeController = _themeController;

- (id)initWithThemeController:(ThemePreferenceViewController *)themeController
{
    if (self = [super initWithViewControllers:[NSArray arrayWithObject:themeController] title:@"Preferences"]) {
        _themeController = themeController;
    }
    
    return self;
}

@end
