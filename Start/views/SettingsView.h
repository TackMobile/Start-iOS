//
//  SettingsView.h
//  Start
//
//  Created by Nick Place on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsViewDelegate <NSObject>

- (void)hidePlus;
- (void)showPlus;

@end

@interface SettingsView : UIView <UIScrollViewDelegate> {
  UIImageView *bgImage;
  UIButton *tackButton;
  
  UIImageView *underline;
  UIImageView *intro;
  
  UILabel *copyText;
  UILabel *versionText;
  UIScrollView *timePicker;
  
  NSArray *snoozeOptions;
  
  int selectedIndex;
  bool pickingSnooze;
  
  NSArray *labelCopy;
  NSArray *labelIcons;
  NSMutableArray *introLabels;
  
  UIView *instructionsView;
  UIView *introView;
  
  UILabel *tackLabel;
  
  UIImageView *tackLogo;
}

- (void)navigatingAway;
- (void)lockTapped:(id)button;
- (id)initWithDelegate:(id)_delegate frame:(CGRect)frame;

@property (nonatomic, retain) id<SettingsViewDelegate> delegate;

@end
