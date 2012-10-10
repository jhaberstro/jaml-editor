//
//  ThemePreferenceViewController.m
//  jaml-editor
//
//  Created by Jedd Haberstro on 12/13/11.
//  Copyright (c) 2011 Student. All rights reserved.
//

#import "ThemePreferenceViewController.h"

@interface ThemePreferenceViewController ()
- (void)setFont:(NSFont *)font;
@end

@implementation ThemePreferenceViewController

@synthesize themesTableView = _themesTableView;
@synthesize themeArrayController = _themeArrayController;
@synthesize fontField = _fontField;

- (id)init
{
    self = [super initWithNibName:@"ThemePreferenceViewController" bundle:[NSBundle mainBundle]];
    return self;
}

- (void)awakeFromNib
{
    id fontDefault = [[NSUserDefaults standardUserDefaults] objectForKey:@"font"];
    [self setFont:[NSUnarchiver unarchiveObjectWithData:fontDefault]];
}

- (NSDictionary *)selectedTheme
{
    id value = [[NSUserDefaultsController sharedUserDefaultsController] values];
    NSUInteger selectedRow = self.themesTableView.selectedRow;
    return [[value valueForKey:@"themes"] objectAtIndex:selectedRow];
}

- (IBAction)addTheme:(id)sender
{
    NSMutableDictionary* defaultTheme = [[NSMutableDictionary alloc] init];
    [defaultTheme setObject:[NSString stringWithFormat:@"Theme %i", self.themesTableView.numberOfRows + 1, nil] forKey:@"name"];
    [defaultTheme setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor redColor]] forKey:@"boldColor"];
    [defaultTheme setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor redColor]] forKey:@"italicColor"];
    [defaultTheme setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor blueColor]] forKey:@"listColor"];
    [defaultTheme setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor magentaColor]] forKey:@"headerColor"];
    [defaultTheme setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor yellowColor]] forKey:@"inlineCodeColor"];
    [defaultTheme setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor purpleColor]] forKey:@"linkColor"]; 
    [self.themeArrayController addObject:defaultTheme];
}

- (IBAction)openFontPanel:(id)sender
{
    NSFontManager* fontManager = [NSFontManager sharedFontManager];
    [fontManager setTarget:self];
    [[fontManager fontPanel:YES] makeKeyAndOrderFront:self];
}

- (void)setFont:(NSFont *)newFont
{
    self.fontField.stringValue = [NSString stringWithFormat:@"%@, %.1f", [newFont displayName], [newFont pointSize], nil];
    [self.fontField setFont:newFont];
}

- (void)changeFont:(id)sender
{
    NSFont* newFont = [sender convertFont:[sender selectedFont]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:newFont] forKey:@"font"];
    [self setFont:newFont];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JHNotificationFontChanged" object:self];
}

- (NSString *)identifier
{
    return @"ThemePreferenceIdentifier";
}

- (NSString *)toolbarItemLabel
{
    return @"ThemePreference";
}

- (NSImage *)toolbarItemImage
{
    return nil;
}

- (void)viewWillAppear
{
}

@end
