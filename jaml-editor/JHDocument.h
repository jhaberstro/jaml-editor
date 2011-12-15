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
{
    JHJAMLParser* _jamlParser;
    NSTimer* _updateTimer;
    NSDate* _lastEdit;
    BOOL _dirty;
    NSString* _temporaryFileContents;
}

- (NSString *)documentName;
- (void)updateWebview;
- (void)updateParagraphStyle;

@property (strong) IBOutlet NSTextView *editorView;
@property (strong) IBOutlet WebView *webView;

@end
