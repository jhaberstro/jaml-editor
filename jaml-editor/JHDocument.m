//
//  JHDocument.m
//  jaml-editor
//
//  Created by Jedd Haberstro on 12/10/11.
//  Copyright (c) 2011 Student. All rights reserved.
//

#import "JHDocument.h"
#import "JHJAMLSyntaxDelegate.h"
#import "ThemePreferenceViewController.h"
#import "JHPreferencePaneWindowController.h"
#import "JHJAMLEditorAppDelegate.h"

@interface JHDocument ()
- (void)_forceWebviewRefresh;
@end

@implementation JHDocument {
    JHJAMLParser* _jamlParser;
    NSDate* _lastEdit;
    BOOL _dirty;
    NSString* _temporaryFileContents;
}

@synthesize editorView = _editorView;
@synthesize webView = _webView;

- (id)init {
    self = [super init];
    if (self) {
        _jamlParser = [[JHJAMLParser alloc] init];
        [[NSNotificationCenter defaultCenter] addObserverForName:@"JHNotificationFontChanged"
                                                          object:nil
                                                           queue:[[NSOperationQueue alloc] init]
                                                      usingBlock:[^(NSNotification* note) {
            dispatch_async(dispatch_get_main_queue(), [^{
                [self _forceWebviewRefresh];
            } copy]);
        } copy]];
    }
    
    return self;
}

- (void)awakeFromNib {
    if (_temporaryFileContents != nil) {
        self.editorView.string = _temporaryFileContents;
        _temporaryFileContents = nil;
        [self _forceWebviewRefresh];
    }
    
    NSFont* font = [NSFont fontWithName:@"Menlo" size:12.0];
    [self.editorView setFont:font];
    [self.editorView setTextContainerInset:NSMakeSize(8.0, 0.0)];
}

- (NSString *)windowNibName {
    return @"JHDocument";
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    BOOL writeSuccess = [self.editorView.string writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:outError];
    return writeSuccess;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    _temporaryFileContents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:outError];
    if (outError && *outError) {
        return NO;
    }
    
    return _temporaryFileContents != nil;
}

+ (BOOL)autosavesInPlace {
    return YES;
}

#pragma mark -
#pragma mark - NSTextDelegate methods

- (void)textDidBeginEditing:(NSNotification *)notification {
}

- (void)textDidChange:(NSNotification *)notification {
    _lastEdit = [NSDate dateWithTimeIntervalSinceNow:0];
    _dirty = YES;
    NSDictionary* defaultAttributes = [self defaultAttributes];
    [self.editorView.textStorage setAttributes:defaultAttributes range:NSMakeRange(0, [self.editorView.textStorage.string length])];
    
    JHJAMLSyntaxDelegate* syntaxDelegate = [[JHJAMLSyntaxDelegate alloc] init];
    syntaxDelegate.textStorage = self.editorView.textStorage;
    syntaxDelegate.colors = [[[[NSApp delegate] preferenceWindowController] themeController] selectedTheme];
    syntaxDelegate.font = [self defaultFont];
    JHJAMLHTMLDelegate* htmlDelegate = [[JHJAMLHTMLDelegate alloc] init];
    [_jamlParser.delegates addDelegate:syntaxDelegate];
    [_jamlParser.delegates addDelegate:htmlDelegate];
    [_jamlParser parseJAML:self.editorView.string];
    NSArray* cssFiles = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"css" subdirectory:@""];
    NSString* html = [NSString stringWithFormat:@"<head><link rel=\"stylesheet\" href=\"%@\"></head><body>%@</body>", [[cssFiles objectAtIndex:0] absoluteString], htmlDelegate.html];
    [[self.webView mainFrame] loadHTMLString:html baseURL:nil];
    [_jamlParser.delegates removeDelegate:syntaxDelegate];
    [_jamlParser.delegates removeDelegate:htmlDelegate];
}

#pragma mark -
#pragma mark - Public methods

- (NSString *)documentName {
    if (self.fileURL) {
        return [[self displayName] stringByDeletingPathExtension];
    }
    
    return @"Untitled";
}

- (NSFont *)defaultFont {
    return [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"font"]];
}

- (NSDictionary *)defaultAttributes {
    NSFont* font = [self defaultFont];
    NSColor* textColor = [NSColor textColor];
    return [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, textColor, NSForegroundColorAttributeName, nil];
}

- (NSColor *)italicAndBoldColor {
    return [NSColor redColor];
}

#pragma mark -
#pragma mark - Private methods

- (void)_forceWebviewRefresh {
    [self textDidChange:nil];
}

@end
