//
//  JHJAMLEditorAppDelegate.m
//  jaml-editor
//
//  Created by Jedd Haberstro on 12/13/11.
//  Copyright (c) 2011 Student. All rights reserved.
//

#import "JHJAMLEditorAppDelegate.h"
#import "MASPreferencesWindowController.h"
#import "CSSPreferenceViewController.h"
#import "JHDocument.h"
#import <WebKit/WebKit.h>

@implementation JHJAMLEditorAppDelegate

@synthesize preferenceWindowController = _preferenceWindowController;

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WebKitDeveloperExtras"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    CSSPreferenceViewController* cssPreferenceViewController = [[CSSPreferenceViewController alloc] init];
    self.preferenceWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:[NSArray arrayWithObject:cssPreferenceViewController] title:@"Preferences"];
}

- (IBAction)openPreferences:(id)sender
{
    [self.preferenceWindowController showWindow:sender];
}

- (IBAction)exportCurrentDocumentToPDF:(id)sender
{
    JHDocument* currentDocument = [[NSDocumentController sharedDocumentController] currentDocument];
    if (currentDocument) {
        NSSavePanel* savePanel = [NSSavePanel savePanel];
        [savePanel setAllowedFileTypes:[NSArray arrayWithObjects:@"pdf", @"PDF", nil]];
        [savePanel setAllowsOtherFileTypes:NO];
        [savePanel setCanCreateDirectories:YES];
        [savePanel setCanSelectHiddenExtension:YES];
        [savePanel setExtensionHidden:NO];
        [savePanel setNameFieldStringValue:[currentDocument documentName]];
        [savePanel beginWithCompletionHandler:^(NSInteger result) {
            if (result) {
                NSView* exportView = [[[currentDocument.webView mainFrame] frameView] documentView];                
                NSPrintInfo *printInfo = [[NSPrintInfo alloc] initWithDictionary:
                                      [NSDictionary dictionaryWithObjectsAndKeys:
                                       [[savePanel URL] path] , NSPrintSavePath, nil]];
                [printInfo setVerticalPagination:NSAutoPagination];
                [printInfo setJobDisposition:NSPrintSaveJob];
                NSPrintOperation *op = [NSPrintOperation printOperationWithView:exportView printInfo:printInfo];
                [op setShowsPrintPanel:NO];
                BOOL success = [op runOperation];
                assert(success == YES);
            }
        }];
    }
}

@end
