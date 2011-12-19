//
//  JHDocument.m
//  jaml-editor
//
//  Created by Jedd Haberstro on 12/10/11.
//  Copyright (c) 2011 Student. All rights reserved.
//

#import "JHDocument.h"

@interface JHDocument ()
- (void)_forceWebviewRefresh;
@end

@implementation JHDocument

@synthesize editorView = _editorView;
@synthesize webView = _webView;

- (id)init
{
    self = [super init];
    if (self) {
        _jamlParser = [[JHJAMLParser alloc] init];
        _updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 15.0
                                                        target:self
                                                      selector:@selector(updateWebview)
                                                      userInfo:nil
                                                       repeats:YES];
    }
    return self;
}

- (void)awakeFromNib
{
    if (_temporaryFileContents != nil) {
        self.editorView.string = _temporaryFileContents;
        _temporaryFileContents = nil;
        [self _forceWebviewRefresh];
    }
    
    [self updateParagraphStyle];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"JHDocument";
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    BOOL writeSuccess = [self.editorView.string writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:outError];
    return writeSuccess;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    _temporaryFileContents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:outError];
    if (outError && *outError) {
        return NO;
    }
    
    return _temporaryFileContents != nil;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

#pragma mark -
#pragma mark - NSTextDelegate methods

- (void)textDidBeginEditing:(NSNotification *)notification
{
    [self updateParagraphStyle];
}

- (void)textDidChange:(NSNotification *)notification
{
    _lastEdit = [NSDate dateWithTimeIntervalSinceNow:0];
    _dirty = YES;
}

#pragma mark -
#pragma mark - Public methods

- (NSString *)documentName
{
    if (self.fileURL) {
        return [[self displayName] stringByDeletingPathExtension];
    }
    
    return @"Untitled";
}

- (void)updateWebview
{
    if (_dirty) {
        NSDate* now = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval change = [now timeIntervalSinceDate:_lastEdit];
        if (change > 0.04) {
            JHJAMLHTMLDelegate* delegate = [[JHJAMLHTMLDelegate alloc] init];
            _jamlParser.delegate = delegate;
            [_jamlParser parseJAML:self.editorView.string];
            NSArray* cssFiles = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"css" subdirectory:@""];
            NSString* html = [NSString stringWithFormat:@"<head><link rel=\"stylesheet\" href=\"%@\"></head><body>%@</body>", [[cssFiles objectAtIndex:0] absoluteString], delegate.html];
            [[self.webView mainFrame] loadHTMLString:html baseURL:nil];
            //printf("%s\n\n", [html UTF8String]);
            _dirty = NO;
        }
    }
}

- (void)updateParagraphStyle
{
    NSFont* font = [NSFont fontWithName:@"Menlo" size:12.0];
    [self.editorView setFont:font];
    NSMutableParagraphStyle* paragraphStyle = [[self.editorView defaultParagraphStyle] mutableCopy];
    if (paragraphStyle == nil) {
        paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    }
    
    assert(paragraphStyle != nil);
    [self.editorView setDefaultParagraphStyle:paragraphStyle];
    
    
    /*NSMutableParagraphStyle* paragraphStyle = [[self.editorView defaultParagraphStyle] mutableCopy];
    
    if (paragraphStyle == nil) {
        paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    }
    
    float charWidth = [[[self.editorView font] screenFontWithRenderingMode:NSFontDefaultRenderingMode] advancementForGlyph:(NSGlyph) ' '].width;
    [paragraphStyle setDefaultTabInterval:(charWidth * 4)];
    [paragraphStyle setTabStops:[NSArray array]];
    
    [self.editorView setDefaultParagraphStyle:paragraphStyle];
    
    NSMutableDictionary* typingAttributes = [[self.editorView typingAttributes] mutableCopy];
    [typingAttributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [self.editorView setTypingAttributes:typingAttributes];*/
}

#pragma mark -
#pragma mark - Private methods

- (void)_forceWebviewRefresh
{
    _lastEdit = [NSDate dateWithTimeIntervalSinceNow:0];
    _dirty = YES;
}

@end
