//
//  JHJAMLSyntaxDelegate.h
//  jaml-editor
//
//  Created by Jedd Haberstro on 12/28/11.
//  Copyright (c) 2011 Student. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHJAMLParser.h"

@class JHDocument;
@interface JHJAMLSyntaxDelegate : NSObject < JHJAMLParserDelegate >

- (void)didParseHorizontalRule;
- (void)didParseLinkWithURL:(NSString *)url name:(NSString *)name info:(NSDictionary *)info;
- (void)didParseInlineCode:(NSString *)inlineCode info:(NSDictionary *)info;
- (void)didBeginElement:(JHElement)element info:(NSDictionary *)info;
- (void)processText:(NSString *)text startLocation:(NSUInteger)locationIndex;
- (void)didEndElement:(JHElement)element info:(NSDictionary *)info;

@property (weak) NSTextStorage* textStorage;
@property (weak) JHDocument* document;
@end