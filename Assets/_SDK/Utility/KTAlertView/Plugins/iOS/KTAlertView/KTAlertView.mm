#import "AlertViewPlugin.h"

extern "C" {
    void setupKTAlertView(const char* title, const char* message, const char* cancelButton, const char* buttons[], int tag, const char* objectName,int totalButtons,const char* callbackName) {
      
        NSString *titleString = nil;
        NSString *messageString = nil;
        NSString *cancelButtonString = nil;
        NSString *objectNameString = nil;
        
        if (title != NULL) {
            titleString = [NSString stringWithUTF8String:title];
        }
        if (message != NULL) {
            messageString = [NSString stringWithUTF8String:message];
        }
        if (cancelButton != NULL) {
            cancelButtonString = [NSString stringWithUTF8String:cancelButton];
        }
        if (objectName != NULL) {
            objectNameString = [NSString stringWithUTF8String:objectName];
        }
        
        NSMutableArray *btnsArray = [NSMutableArray array];
        if (buttons == NULL) {
            btnsArray = nil;
        }
        else {
            for (int i = 0 ; i < totalButtons ; i++) {
                const char *btn = buttons[i];
                if ([[NSString stringWithUTF8String:btn] isEqualToString:@""]) {
                    continue;
                }
                [btnsArray addObject:[NSString stringWithUTF8String:btn]];
            }
            
            if ([btnsArray count] == 0) {
                btnsArray = nil;
            }
        }
        
        [[AlertViewPlugin sharedController] showAlertViewWithTitle:titleString Message:messageString CancelButton:cancelButtonString Buttons:btnsArray Tag:tag ObjectName:objectNameString CallbackName:[NSString stringWithUTF8String:callbackName]];
    }
}