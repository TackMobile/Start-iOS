//
//  SettingsView.h
//  Start
//
//  Created by Nick Place on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsView : UIView <UITextFieldDelegate> {
    UIImageView *bgImage;
}

@property (nonatomic, strong) UITextField *snoozeTimeField;

-(void) navigatingAway;
-(void) snoozeTimeDidChange:(id)textfield;
@end
