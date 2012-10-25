//
//  SettingsView.h
//  Start
//
//  Created by Nick Place on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsView : UIView <UIScrollViewDelegate> {
    UIImageView *bgImage;
    
   // UILabel *tackCopy;
    //UIImageView *tackLogo;
    UIButton *tackButton;
    
    UIImageView *underline;
    UIImageView *intro;
    
    UILabel *copyText;
    UILabel *versionText;
    UIScrollView *timePicker;
    
    NSArray *snoozeOptions;
    
    int selectedIndex;
    bool pickingSnooze;
    
    UILabel *createLabel;
    UILabel *flickDownLabel;
    UILabel *flickUpLabe;
    UILabel *pinchLabel;
    UILabel *setLabel;
    UILabel *tackLabel;
    
    UIImageView *createIcon;
    UIImageView *flickDownIcon;
    UIImageView *flickUpIcon;
    UIImageView *pinchIcon;
    UIImageView *setIcon;
    UIImageView *tackLogo;
}

-(void) navigatingAway;
@end
