//
//  JHPreferencePaneWindowController.h
//  jaml-editor
//
//  Created by Jedd Haberstro on 1/2/12.
//  Copyright (c) 2012 Student. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MASPreferencesWindowController.h"

@class ThemePreferenceViewController;
@interface JHPreferencePaneWindowController : MASPreferencesWindowController

- (id)initWithThemeController:(ThemePreferenceViewController *)themeController;

@property (strong, readonly) ThemePreferenceViewController* themeController;

@end
