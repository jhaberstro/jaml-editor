//
//  JHDocument.m
//  jaml-editor
//
//  Created by Jedd Haberstro on 12/10/11.
//  Copyright (c) 2011 Student. All rights reserved.
//

#import "JHDocument.h"

enum {
    JHJAMLSyntaxAttributeItalic = 1 << 0,
    JHJAMLSyntaxAttributeBold = 1 << 1,
    JHJAMLSyntaxAttributeList = 1 << 2,
    JHJAMLSyntaxAttributeInlineCode = 1 << 3,
    JHJAMLSyntaxAttributeLink = 1 << 4,
    JHJAMLSyntaxAttributeHeader = 1 << 5,
};
typedef NSUInteger JHJAMLSyntaxAttribute;

static NSDictionary* AttributesDictionary(JHDocument* doc, NSFont* sourceFont, JHJAMLSyntaxAttribute attributes) {
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    BOOL bold = attributes & JHJAMLSyntaxAttributeBold;
    BOOL italic = attributes & JHJAMLSyntaxAttributeItalic;
    BOOL list = attributes & JHJAMLSyntaxAttributeList;
    BOOL inlineCode = attributes & JHJAMLSyntaxAttributeInlineCode;
    BOOL link = attributes & JHJAMLSyntaxAttributeLink;
    BOOL header = attributes & JHJAMLSyntaxAttributeHeader;
    
    NSFont* font = [sourceFont copy];
    if (bold)
        font = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSFontBoldTrait];
    if (italic)
        font = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSFontItalicTrait];
    [dictionary setObject:font forKey:NSFontAttributeName];
    
    // The order of the branches defines the precedence
#   define SET_COLOR(color) [dictionary setObject:color forKey:NSForegroundColorAttributeName]
    if (inlineCode)             SET_COLOR([NSColor greenColor]);
    else if (link)              SET_COLOR([NSColor purpleColor]);
    else if (bold || italic)    SET_COLOR([doc italicAndBoldColor]);
    else if (list)              SET_COLOR([NSColor blueColor]);
    else if (header)            SET_COLOR([NSColor magentaColor]);
    else                        SET_COLOR([NSColor textColor]);
    
    return dictionary;
}

@interface JHJAMLSyntaxDelegate : NSObject < JHJAMLParserDelegate >
{
    JHJAMLSyntaxAttribute _attributes;
}

- (void)didParseHorizontalRule;
- (void)didParseLinkWithURL:(NSString *)url name:(NSString *)name info:(NSDictionary *)info;
- (void)didParseInlineCode:(NSString *)inlineCode info:(NSDictionary *)info;
- (void)didBeginElement:(JHElement)element info:(NSDictionary *)info;
- (void)processText:(NSString *)text startLocation:(NSUInteger)locationIndex;
- (void)didEndElement:(JHElement)element info:(NSDictionary *)info;

@property (weak) NSTextStorage* textStorage;
@property (weak) JHDocument* document;
@end

@implementation JHJAMLSyntaxDelegate

@synthesize textStorage = _textStorage;
@synthesize document = _document;

- (id)init
{
    if (self = [super init]) {
        _attributes = 0;
    }
    
    return self;
}

- (void)didParseHorizontalRule { }

- (void)didParseLinkWithURL:(NSString *)url name:(NSString *)name info:(NSDictionary *)info
{
    NSDictionary* attributes = AttributesDictionary(self.document, [self.document defaultFont], _attributes | JHJAMLSyntaxAttributeLink);
    NSRange range = [[info objectForKey:JHElementRange] rangeValue];
    [self.textStorage addAttributes:attributes range:range];
}

- (void)didParseInlineCode:(NSString *)inlineCode info:(NSDictionary *)info
{
    NSDictionary* attributes = AttributesDictionary(self.document, [self.document defaultFont], _attributes | JHJAMLSyntaxAttributeInlineCode);
    NSRange range = [[info objectForKey:JHElementRange] rangeValue];
    [self.textStorage addAttributes:attributes range:range];
}

- (void)processText:(NSString *)text startLocation:(NSUInteger)locationIndex
{
    NSDictionary* attributes = AttributesDictionary(self.document, [self.document defaultFont], _attributes);
    NSRange range = NSMakeRange(locationIndex, [text length]);
    [self.textStorage addAttributes:attributes range:range];
}

- (void)didBeginElement:(JHElement)element info:(NSDictionary *)info
{
    switch (element) {
        case JHEmphasizeElement: {
            _attributes |= JHJAMLSyntaxAttributeItalic;
            NSDictionary* attributes = AttributesDictionary(self.document, [self.document defaultFont], _attributes);            
            NSRange range = NSMakeRange([[info objectForKey:JHElementLocation] unsignedIntegerValue], 1);
            [self.textStorage addAttributes:attributes range:range];
            break;
        }
            
        case JHStrongElement: {
            _attributes |= JHJAMLSyntaxAttributeBold;
            NSDictionary* attributes = AttributesDictionary(self.document, [self.document defaultFont], _attributes);            
            NSRange range = NSMakeRange([[info objectForKey:JHElementLocation] unsignedIntegerValue], 1);
            [self.textStorage addAttributes:attributes range:range];
            break;
        }
            
        case JHHeaderElement: {
            _attributes |= JHJAMLSyntaxAttributeHeader;
            NSDictionary* attributes = AttributesDictionary(self.document, [self.document defaultFont], _attributes);            
            NSRange range = NSMakeRange([[info objectForKey:JHElementLocation] unsignedIntegerValue], [[info objectForKey:JHHeaderStrength] unsignedIntegerValue]);
            [self.textStorage addAttributes:attributes range:range];
            break;
        }
            
        case JHListItemElement: {
            NSDictionary* attributes = AttributesDictionary(self.document, [self.document defaultFont], _attributes | JHJAMLSyntaxAttributeList);
            NSRange range = [[info objectForKey:JHElementRange] rangeValue];
            [self.textStorage addAttributes:attributes range:range];
            break;
        }
            
        default:
            break;
    }
}
- (void)didEndElement:(JHElement)element info:(NSDictionary *)info
{
    switch (element) {
        case JHEmphasizeElement: {
            NSDictionary* attributes = AttributesDictionary(self.document, [self.document defaultFont], _attributes);            
            NSRange range = NSMakeRange([[info objectForKey:JHElementLocation] unsignedIntegerValue], 1);
            [self.textStorage addAttributes:attributes range:range];
            _attributes &= ~JHJAMLSyntaxAttributeItalic;
            break;
        }
            
        case JHStrongElement: {
            NSDictionary* attributes = AttributesDictionary(self.document, [self.document defaultFont], _attributes);            
            NSRange range = NSMakeRange([[info objectForKey:JHElementLocation] unsignedIntegerValue], 1);
            [self.textStorage addAttributes:attributes range:range];
            _attributes &= ~JHJAMLSyntaxAttributeBold;
            break;
        }
            
        case JHHeaderElement: {
            _attributes &= ~JHJAMLSyntaxAttributeHeader;
            break;
        }
            
        default:
            break;
    }
};

@end

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
}

- (NSString *)windowNibName {
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
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
    syntaxDelegate.document = self;
    JHJAMLHTMLDelegate* htmlDelegate = [[JHJAMLHTMLDelegate alloc] init];
    [_jamlParser.delegates addDelegate:syntaxDelegate];
    [_jamlParser.delegates addDelegate:htmlDelegate];
    [_jamlParser parseJAML:self.editorView.string];
    NSArray* cssFiles = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"css" subdirectory:@""];
    NSString* html = [NSString stringWithFormat:@"<head><link rel=\"stylesheet\" href=\"%@\"></head><body>%@</body>", [[cssFiles objectAtIndex:0] absoluteString], htmlDelegate.html];
    //printf("%s\n\n", [html UTF8String]);
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
    return [NSFont fontWithName:@"Menlo" size:12.0];
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
