//
//  CountdownView.h
//  Start
//
//  Created by Nick Place on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountdownView : UIView {
  bool shouldFlash;
}

@property (nonatomic, strong) UILabel *countdownLabel;

- (void)updateWithDate:(NSDate *)newDate;

@end
