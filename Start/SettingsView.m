//
//  SettingsView.m
//  Start
//
//  Created by Nick Place on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsView.h"

@implementation SettingsView

const float optionHeight = 40;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        pickingSnooze = NO;
        selectedIndex = 0;
        
        bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]];
        tackLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tack-logo"]];
        tackButton = [[UIButton alloc] init];
        underline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search-divider"]];
        copyText = [[UILabel alloc] init];
        tackCopy = [[UILabel alloc] init];
        timePicker = [[UIScrollView alloc] init];
        
        [self addSubview:bgImage];
        [self addSubview:tackLogo];
        [self addSubview:underline];
        [self addSubview:copyText];
        [self addSubview:tackCopy];
        [self addSubview:tackButton];
        [self addSubview:timePicker];
                
        [copyText setText:@"Sleep Duration:           min"]; // leave the spaces. i know, a hack
        [tackCopy setText:@"Assembled by"];
        
        [tackButton addTarget:self action:@selector(tackTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [timePicker setDelegate:self];
        
        [self setBackgroundColor:[UIColor blackColor]];
        
        snoozeOptions = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:10],
                         [NSNumber numberWithInt:15],
                         [NSNumber numberWithInt:20],
                         [NSNumber numberWithInt:25],
                         [NSNumber numberWithInt:30],
                         [NSNumber numberWithInt:45],
                         [NSNumber numberWithInt:60], nil];
        
        // fonts
        UIFont *lgRobotoFont = [UIFont fontWithName:@"Roboto-Thin" size:26];
        UIFont *smlRobotoFont = [UIFont fontWithName:@"Roboto-Thin" size:17];
                
        UIColor *textColor = [UIColor whiteColor];
        
        [copyText setFont:lgRobotoFont];    [copyText setTextColor:textColor];
        [copyText setBackgroundColor:[UIColor clearColor]];
        
        [tackCopy setFont:smlRobotoFont];    [tackCopy setTextColor:textColor];
        [tackCopy setBackgroundColor:[UIColor clearColor]];
        
        // time picker
        [timePicker setDecelerationRate:UIScrollViewDecelerationRateFast];
        for (int i=0; i<[snoozeOptions count]; i++) {
            UIButton *snoozeOptionButton = [[UIButton alloc] init];
            [snoozeOptionButton.titleLabel setFont:lgRobotoFont];
            [snoozeOptionButton.titleLabel setTextColor:textColor];
            [snoozeOptionButton.titleLabel setBackgroundColor:[UIColor clearColor]];
            [snoozeOptionButton setTitle:[NSString stringWithFormat:@"%@",[snoozeOptions objectAtIndex:i]]
                                forState:UIControlStateNormal];
            [timePicker addSubview:snoozeOptionButton];
            
            [snoozeOptionButton addTarget:self action:@selector(snoozeTimeSelected:) 
                         forControlEvents:UIControlEventTouchUpInside];
        }
  
        // is it already set?
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"snoozeTime"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:10] forKey:@"snoozeTime"];
            selectedIndex = 0;
        } else {
            NSNumber *savedSnooze = [[NSUserDefaults standardUserDefaults] objectForKey:@"snoozeTime"];
            for (int i=0; i<[snoozeOptions count]; i++) {
                if ([[snoozeOptions objectAtIndex:i] isEqualToNumber:savedSnooze]) {
                    selectedIndex = i;
                    break;
                }
            }
        }
        [timePicker setClipsToBounds:YES];
        [self animateTimePicker];
 
    }
    return self;
}

- (void)layoutSubviews {
    CGSize frameSize = [[UIScreen mainScreen] applicationFrame].size;
    
    CGSize tackTextSize = [[tackCopy text] sizeWithFont:[tackCopy font]];
    CGSize copyTextSize = [[copyText text] sizeWithFont:[copyText font]];
    
    CGRect bgRect = CGRectMake(0, frameSize.height - bgImage.frame.size.height, frameSize.width, bgImage.frame.size.height);
    CGRect tackCopyRect = CGRectMake((frameSize.width - (tackTextSize.width+41))/2,
                                     frameSize.height - 70, 
                                     tackTextSize.width, tackTextSize.height);

    CGRect tackRect = CGRectMake(tackCopyRect.origin.x + tackCopyRect.size.width + 5, 
                                 tackCopyRect.origin.y - 15, 41, 40);
    CGRect tackButtonRect = CGRectMake(0, tackRect.origin.y - 5, 
                                       frameSize.width, frameSize.height-(tackRect.origin.y-5));
    CGRect copyTextRect = CGRectMake(15, 20, 
                                     copyTextSize.width, copyTextSize.height);
    CGRect underlineRect = CGRectMake(copyTextRect.origin.x, 
                                      copyTextRect.origin.y + copyTextRect.size.height + 4,
                                      frameSize.width-(copyTextRect.origin.y*2),
                                      1);
    CGRect scrollRect = CGRectMake(frameSize.width-180, 0, 180,
                                   frameSize.height);
    
    bgImage.frame = bgRect;
    tackLogo.frame = tackRect;
    tackCopy.frame = tackCopyRect;
    tackButton.frame = tackButtonRect;
    copyText.frame = copyTextRect;
    underline.frame = underlineRect;
    timePicker.frame = scrollRect;
    
    // time picker
    NSArray *timeSubviews = [timePicker subviews];
    for (int i=0; i<[timeSubviews count]; i++) {
        CGRect subviewFrame = CGRectMake(0, optionHeight*i, scrollRect.size.width, optionHeight);
        [[timeSubviews objectAtIndex:i] setFrame:subviewFrame];
    }
    timePicker.contentSize = CGSizeMake(scrollRect.size.width, optionHeight * [snoozeOptions count]);
    [timePicker setContentInset:
     UIEdgeInsetsMake(copyTextRect.origin.y - (optionHeight - copyTextSize.height)/2, 
                      0, 
                      scrollRect.size.height-(copyTextRect.origin.y + copyTextRect.size.height)
                      - (optionHeight - copyTextSize.height)/2
                      , 0)];
    
    // scroll to selected
    float roundedOffset = (selectedIndex * optionHeight) - timePicker.contentInset.top;
    timePicker.contentOffset = CGPointMake(0, roundedOffset);
    timePicker.showsVerticalScrollIndicator = YES;
    timePicker.indicatorStyle = UIScrollViewIndicatorStyleWhite;

    [timePicker sizeToFit];
}

-(void) snoozeTimeSelected:(UIButton *)button {
    if (pickingSnooze) {
        selectedIndex = (int)roundf( button.frame.origin.y / optionHeight);
    }
    pickingSnooze = NO;
    [self animateTimePicker];
}

-(void)tackTapped:(id)button {
    NSURL* tackURL = [NSURL URLWithString:@"http://tackmobile.com"];
    if ([[UIApplication sharedApplication] canOpenURL:tackURL])
        [[UIApplication sharedApplication] openURL:tackURL];
}

-(void) navigatingAway {
    pickingSnooze= NO;
    [self animateTimePicker];
}

#pragma mark - touches
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (pickingSnooze) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLoc = [touch locationInView:self];
    
    if (!pickingSnooze && CGRectContainsPoint(CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width,
                                                         copyText.frame.size.height + copyText.frame.origin.y), touchLoc)) {
        pickingSnooze = YES;
        [self animateTimePicker];
    }
}
/*save    if (![[textField text] isEqualToString:@""]) {
        NSNumber *snoozeDur = [NSNumber numberWithInt:[[textField text] intValue]];
        [[NSUserDefaults standardUserDefaults] setObject:snoozeDur forKey:@"snoozeTime"];
        [textField resignFirstResponder];
        return YES;
    }
    return NO;
}*/

#pragma mark - scrollview delegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pickingSnooze = YES;
    [self animateTimePicker];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_5_0) {
    int newIndex = (int)roundf(targetContentOffset->y / optionHeight);
    selectedIndex = newIndex;
    
    float roundedOffset = (newIndex * optionHeight) - scrollView.contentInset.top;
    targetContentOffset->y = roundedOffset;
    NSLog(@"%f", targetContentOffset->y);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pickingSnooze = NO;
    [self animateTimePicker];
}

-(void) animateTimePicker {
    if (!pickingSnooze) {
        // save snooze time
        [[NSUserDefaults standardUserDefaults] setValue:[snoozeOptions objectAtIndex:selectedIndex]
                                                 forKey:@"snoozeTime"];
        
        float roundedOffset = (selectedIndex * optionHeight) - timePicker.contentInset.top;
        [timePicker setUserInteractionEnabled:NO];
        [UIView animateWithDuration:.1 animations:^{
            if (timePicker.contentOffset.y != roundedOffset)
                timePicker.contentOffset = CGPointMake(0, roundedOffset);
            
            [bgImage setAlpha:1];

            for (int i=0; i<[snoozeOptions count]; i++) {
                if (i != selectedIndex)
                    [[[timePicker subviews] objectAtIndex:i] setAlpha:0];
            }
        }];
    } else {
        [timePicker setUserInteractionEnabled:YES];
        [UIView animateWithDuration:.1 animations:^{
            [bgImage setAlpha:.3];
            for (int i=0; i<[snoozeOptions count]; i++) {
                [[[timePicker subviews] objectAtIndex:i] setAlpha:1];
            }
        }];
    }
}








//goto;











































































@end
