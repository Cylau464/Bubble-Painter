//
//  AlertViewPlugin.m
//  AlertViewPlugin
//
//  Created by Kashif Tasneem on 30/01/2014.
//  Copyright (c) 2014 Kashif Tasneem. All rights reserved.
//

#import "AlertViewPlugin.h"
#import "UIAlertView+UIAlertView_KT.h"

static AlertViewPlugin *sharedInstance_ = nil;

@implementation AlertViewPlugin

+(AlertViewPlugin*) sharedController
{
    if (sharedInstance_ == nil) {
        sharedInstance_ = [[self alloc] init];
    }
    return sharedInstance_;
}

-(id) init
{
    if (self = [super init]) {
        
    }
    return self;
}

-(void) initialize
{
    
}

-(void) showAlertViewWithTitle:(NSString*) title Message:(NSString*) msg CancelButton:(NSString*) cancelButton Buttons:(NSArray*) btns Tag:(int) tag ObjectName:(NSString *)name CallbackName:(NSString *)callbackFunc
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cancelButton otherButtonTitles:nil];
    for (NSString *btn in btns) {
        [alertView addButtonWithTitle:btn];
    }
    [alertView setCallbackName:callbackFunc];
    [alertView setObjectName:name];
    [alertView setTag:tag];
    [alertView show];
    [alertView release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* tagString = [NSString stringWithFormat:@"%ld",(long)[alertView tag]];
    NSString *clickedIndexString = [NSString stringWithFormat:@"%d",buttonIndex];
    NSString *finalString = [NSString stringWithFormat:@"%@_%@",tagString,clickedIndexString];
    NSString *name = [alertView objectName];
    NSString *funcName = [alertView callbackName];
    UnitySendMessage([name UTF8String],[funcName UTF8String],[finalString UTF8String]);
}

-(void) dealloc
{
    if (sharedInstance_ != nil) {
        [sharedInstance_ release];
        sharedInstance_ = nil;
    }
    [super dealloc];
}

@end
