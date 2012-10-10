//
//  JHJAMLEditorAppDelegate.h
//  jaml-editor
//
//  Created by Jedd Haberstro on 12/13/11.
//  Copyright (c) 2011 Student. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ThemePreferenceViewController;
@class JHPreferencePaneWindowController;
@interface JHJAMLEditorAppDelegate : NSObject < NSApplicationDelegate >

- (IBAction)openPreferences:(id)sender;
- (IBAction)exportCurrentDocumentToPDF:(id)sender;

@property (nonatomic, strong) JHPreferencePaneWindowController *preferenceWindowController;

@end
