//
//  AlertViewPlugin.h
//  AlertViewPlugin
//
//  Created by Kashif Tasneem on 30/01/2014.
//  Copyright (c) 2014 Kashif Tasneem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AlertViewPlugin : NSObject<UIAlertViewDelegate>
{
    
}

+(AlertViewPlugin*) sharedController;

-(void) initialize;
-(void) showAlertViewWithTitle:(NSString*) title Message:(NSString*) msg CancelButton:(NSString*) cancelButton Buttons:(NSArray*) btns Tag:(int) tag ObjectName:(NSString*) name CallbackName:(NSString*) callbackFunc;

@end
