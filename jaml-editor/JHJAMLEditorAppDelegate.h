//
//  JHJAMLEditorAppDelegate.h
//  jaml-editor
//
//  Created by Jedd Haberstro on 12/13/11.
//  Copyright (c) 2011 Student. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHJAMLEditorAppDelegate : NSObject < NSApplicationDelegate >

- (IBAction)openPreferences:(id)sender;
- (IBAction)exportCurrentDocumentToPDF:(id)sender;

@property (nonatomic, strong) NSWindowController *preferenceWindowController;

@end
