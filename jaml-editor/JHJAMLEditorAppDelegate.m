//
//  JHJAMLEditorAppDelegate.m
//  jaml-editor
//
//  Created by Jedd Haberstro on 12/13/11.
//  Copyright (c) 2011 Student. All rights reserved.
//

#import "JHJAMLEditorAppDelegate.h"
#import "JHPreferencePaneWindowController.h"
#import "ThemePreferenceViewController.h"
#import "JHDocument.h"
#import <WebKit/WebKit.h>

@interface JHJAMLEditorAppDelegate ()
- (void)setUserDefaults;
@end

@implementation JHJAMLEditorAppDelegate

@synthesize preferenceWindowController = _preferenceWindowController;

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [self setUserDefaults];
    self.preferenceWindowController = [[JHPreferencePaneWindowController alloc] initWithThemeController:[[ThemePreferenceViewController alloc] init]];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    NSFont* newFont = [[NSFontManager sharedFontManager] selectedFont];
    [[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:newFont] forKey:@"font"];
}

- (void)setUserDefaults
{
    NSMutableDictionary* defaultTheme = [[NSMutableDictionary alloc] init];
    [defaultTheme setObject:@"Default" forKey:@"name"];
    [defaultTheme setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor redColor]] forKey:@"boldColor"];
    [defaultTheme setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor redColor]] forKey:@"italicColor"];
    [defaultTheme setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor blueColor]] forKey:@"listColor"];
    [defaultTheme setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor magentaColor]] forKey:@"headerColor"];
    [defaultTheme setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor yellowColor]] forKey:@"inlineCodeColor"];
    [defaultTheme setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor purpleColor]] forKey:@"linkColor"];
    NSMutableDictionary* initialValues = [NSMutableDictionary dictionaryWithObject:[NSMutableArray arrayWithObject:defaultTheme] forKey:@"themes"];
    [initialValues setObject:[NSArchiver archivedDataWithRootObject:[NSFont fontWithName:@"Menlo" size:12.0]] forKey:@"font"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:initialValues];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:initialValues];
    //[[NSUserDefaultsController sharedUserDefaultsController] revertToInitialValues:self];
    //NSLog(@"value: %@", [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"themes"]);
    //NSLog(@"initialValues: %@", [[NSUserDefaultsController sharedUserDefaultsController] initialValues]);
    //NSLog(@"defaults: %@", [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] objectForKey:@"themes"]);
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WebKitDeveloperExtras"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
