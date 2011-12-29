//
//  CSSPreferenceViewController.m
//  jaml-editor
//
//  Created by Jedd Haberstro on 12/13/11.
//  Copyright (c) 2011 Student. All rights reserved.
//

#import "CSSPreferenceViewController.h"

@implementation CSSPreferenceViewController

- (id)init
{
    self = [super initWithNibName:@"CSSPreferenceViewController" bundle:[NSBundle mainBundle]];
    return self;
}

- (NSString *)identifier
{
    return @"CSSPreferenceIdentifier";
}

- (NSString *)toolbarItemLabel
{
    return @"CSSPreference"; //NSLocalizedString("CSSPreference", @"CSS file");
}

- (NSImage *)toolbarItemImage
{
    return nil;
}

- (void)viewWillAppear
{
    
}

@end
