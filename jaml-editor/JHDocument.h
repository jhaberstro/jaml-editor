//
//  JHDocument.h
//  jaml-editor
//
//  Created by Jedd Haberstro on 12/10/11.
//  Copyright (c) 2011 Student. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "JHJAMLParser.h"
#import "JHJAMLHTMLDelegate.h"

@interface JHDocument : NSDocument < NSTextDelegate >

- (NSString *)documentName;
- (NSFont *)defaultFont;
- (NSDictionary *)defaultAttributes;
- (NSColor *)italicAndBoldColor;

@property (strong) IBOutlet NSTextView *editorView;
@property (strong) IBOutlet WebView *webView;

@end
