//
//  JHJAMLSyntaxDelegate.m
//  jaml-editor
//
//  Created by Jedd Haberstro on 12/28/11.
//  Copyright (c) 2011 Student. All rights reserved.
//

#import "JHJAMLSyntaxDelegate.h"
#import "JHDocument.h"

@interface NSDictionary (SyntaxColorData)
- (NSColor *)syntaxColorForKey:(NSString *)key;
@end

@implementation NSDictionary (SyntaxColorData)
- (NSColor *)syntaxColorForKey:(NSString *)key
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:[self objectForKey:key]];
}
@end

enum {
    JHJAMLSyntaxAttributeItalic = 1 << 0,
    JHJAMLSyntaxAttributeBold = 1 << 1,
    JHJAMLSyntaxAttributeList = 1 << 2,
    JHJAMLSyntaxAttributeInlineCode = 1 << 3,
    JHJAMLSyntaxAttributeLink = 1 << 4,
    JHJAMLSyntaxAttributeHeader = 1 << 5,
};
typedef NSUInteger JHJAMLSyntaxAttribute;

static NSDictionary* AttributesDictionary(NSDictionary* colors, NSFont* sourceFont, JHJAMLSyntaxAttribute attributes) {
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
    void (^SetColor) (NSColor*) = ^(NSColor *color) {[dictionary setObject:color forKey:NSForegroundColorAttributeName];};
    if (inlineCode)             SetColor([colors syntaxColorForKey:@"inlineCodeColor"]);
    else if (link)              SetColor([colors syntaxColorForKey:@"linkColor"]);
    else if (bold)              SetColor([colors syntaxColorForKey:@"boldColor"]);
    else if (italic)            SetColor([colors syntaxColorForKey:@"italicColor"]);
    else if (list)              SetColor([colors syntaxColorForKey:@"listColor"]);
    else if (header)            SetColor([colors syntaxColorForKey:@"headerColor"]);
    else                        SetColor([NSColor textColor]);
    
    return dictionary;
}

@implementation JHJAMLSyntaxDelegate
{
    JHJAMLSyntaxAttribute _attributes;
    NSUserDefaultsController* _userDefaultsController;
}

@synthesize textStorage = _textStorage;
@synthesize colors = _colors;
@synthesize font = _font;

- (id)init
{
    if (self = [super init]) {
        _attributes = 0;
        _userDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    }
    
    return self;
}

- (void)_highlightWholeAttribute:(JHJAMLSyntaxAttribute)attribute infoDict:(NSDictionary *)infoDict
{
    NSDictionary* attributes = AttributesDictionary(self.colors, self.font, _attributes | attribute);
    NSRange range = [[infoDict objectForKey:JHElementRange] rangeValue];
    [self.textStorage addAttributes:attributes range:range];
}

- (void)didParseHorizontalRule { }

- (void)didParseLinkWithURL:(NSString *)url name:(NSString *)name info:(NSDictionary *)info
{
    [self _highlightWholeAttribute:JHJAMLSyntaxAttributeLink infoDict:info];
}

- (void)didParseInlineCode:(NSString *)inlineCode info:(NSDictionary *)info
{
    [self _highlightWholeAttribute:JHJAMLSyntaxAttributeInlineCode infoDict:info];
}

- (void)processText:(NSString *)text startLocation:(NSUInteger)locationIndex
{
    NSValue* range = [NSValue valueWithRange:NSMakeRange(locationIndex, [text length])];
    NSDictionary* info = [NSDictionary dictionaryWithObject:range forKey:JHElementRange];
    [self _highlightWholeAttribute:0 infoDict:info];
}

- (void)didBeginElement:(JHElement)element info:(NSDictionary *)info
{
    switch (element) {
        case JHStrongElement:
        case JHEmphasizeElement: {
            _attributes |= (element == JHStrongElement ? JHJAMLSyntaxAttributeBold : JHJAMLSyntaxAttributeItalic);
            NSDictionary* attributes = AttributesDictionary(self.colors, self.font, _attributes);            
            NSRange range = NSMakeRange([[info objectForKey:JHElementLocation] unsignedIntegerValue], 1);
            [self.textStorage addAttributes:attributes range:range];
            break;
        }
            
        case JHHeaderElement: {
            _attributes |= JHJAMLSyntaxAttributeHeader;
            NSDictionary* attributes = AttributesDictionary(self.colors, self.font, _attributes);            
            NSRange range = NSMakeRange([[info objectForKey:JHElementLocation] unsignedIntegerValue], [[info objectForKey:JHHeaderStrength] unsignedIntegerValue]);
            [self.textStorage addAttributes:attributes range:range];
            break;
        }
            
        case JHListItemElement: {
            NSDictionary* attributes = AttributesDictionary(self.colors, self.font, _attributes | JHJAMLSyntaxAttributeList);
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
        case JHStrongElement:
        case JHEmphasizeElement: {            
            NSDictionary* attributes = AttributesDictionary(self.colors, self.font, _attributes);            
            NSRange range = NSMakeRange([[info objectForKey:JHElementLocation] unsignedIntegerValue], 1);
            [self.textStorage addAttributes:attributes range:range];
            _attributes &= ~(element == JHStrongElement ? JHJAMLSyntaxAttributeBold : JHJAMLSyntaxAttributeItalic);
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