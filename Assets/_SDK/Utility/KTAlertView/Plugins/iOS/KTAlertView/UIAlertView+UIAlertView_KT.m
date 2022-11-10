//
//  UIAlertView+UIAlertView_KT.m
//  AlertViewPlugin
//
//  Created by Kashif Tasneem on 30/01/2014.
//  Copyright (c) 2014 Kashif Tasneem. All rights reserved.
//

#import "UIAlertView+UIAlertView_KT.h"
#import <objc/runtime.h>

NSString * const propertyKey = @"kNewPropertyKey";
NSString * const propertyKeyFunc = @"kNewPropertyKeyFunc";

@implementation UIAlertView (UIAlertView_KT)

- (NSString *)objectName {
    return objc_getAssociatedObject(self, propertyKey);
}

- (void) setObjectName:(NSString *)objectName {
    objc_setAssociatedObject(self, propertyKey, objectName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)callbackName {
    return objc_getAssociatedObject(self, propertyKeyFunc);
}

- (void) setCallbackName:(NSString *)callbackName {
    objc_setAssociatedObject(self, propertyKeyFunc, callbackName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
