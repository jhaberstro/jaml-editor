//
//  ThemePreferenceViewController.h
//  jaml-editor
//
//  Created by Jedd Haberstro on 12/13/11.
//  Copyright (c) 2011 Student. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"

@interface ThemePreferenceViewController : NSViewController < MASPreferencesViewController >

- (NSDictionary *)selectedTheme;

- (IBAction)addTheme:(id)sender;
- (IBAction)openFontPanel:(id)sender;

@property (assign) IBOutlet NSTableView* themesTableView;
@property (assign) IBOutlet NSArrayController* themeArrayController;
@property (assign) IBOutlet NSTextField* fontField;

@end
