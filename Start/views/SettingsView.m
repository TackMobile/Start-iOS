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
        
            
    
        CGPoint tackCoordinates;
      
        if ([UIScreen mainScreen].applicationFrame.size.height < 500   ) {
            bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grid-background"]];
            intro = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"about"]];
            tackLogo = [[UIImageView alloc] initWithFrame:CGRectMake(177, 349, 30, 30)];
            tackCoordinates = CGPointMake(48, 354);
            
        }else{
            bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grid-background-568h@2x.png"]];
            intro = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"about-568h@2x.png"]];
            tackLogo = [[UIImageView alloc] initWithFrame:CGRectMake(177, 399, 30, 30)];
            tackCoordinates = CGPointMake(48, 403);
        }
        
        
  
        
        
        //tackLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tack-logo"]];
        tackButton = [[UIButton alloc] init];
        underline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search-divider"]];
        copyText = [[UILabel alloc] init];
        versionText = [UILabel new];
        //tackCopy = [[UILabel alloc] init];
        timePicker = [[UIScrollView alloc] init];
        
        createIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 106, 19, 19)];
        createIcon.image = [UIImage imageNamed:@"create-icon"];
        flickDownIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 255, 19, 28)];
        flickDownIcon.image = [UIImage imageNamed:@"flick-down-icon"];
        flickUpIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 196, 19, 28)];
        flickUpIcon.image = [UIImage imageNamed:@"flick-up-icon"];
        pinchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 300, 29, 29)];
        pinchIcon.image = [UIImage imageNamed:@"pinch-icon"];
        setIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 156, 19, 19)];
        setIcon.image = [UIImage imageNamed:@"set-icon"];
        tackLogo.image = [UIImage imageNamed:@"tack-logo"];
    
        
        
        UIFont *introFonts = [UIFont fontWithName:@"Roboto-Thin" size:20];
        UIColor *introColor = [UIColor whiteColor];
        UIColor *backgroundColor = [UIColor clearColor];

        
        
        createLabel = [UILabel new];
        createLabel.text = @"Create a new alarm";
        createLabel.textColor = introColor;
        createLabel.font = introFonts;
        createLabel.backgroundColor = backgroundColor;
        CGSize createSize = [[createLabel text] sizeWithFont:[createLabel font]];
        createLabel.frame = CGRectMake(48, 102, createSize.width, createSize.height);
        flickDownLabel = [UILabel new];
        flickDownLabel.text = @"Flick down for stopwatch";
        flickDownLabel.font = introFonts;
        flickDownLabel.textColor = introColor;
        flickDownLabel.backgroundColor = backgroundColor;
        CGSize flickDownSize = [[flickDownLabel text] sizeWithFont:[flickDownLabel font]];
        flickDownLabel.frame = CGRectMake(48, 253, flickDownSize.width, flickDownSize.height);
        flickUpLabe = [UILabel new];
        flickUpLabe.text = @"Flick up to activate";
        flickUpLabe.font = introFonts;
        flickUpLabe.textColor = introColor;
        flickUpLabe.backgroundColor = backgroundColor;
        CGSize flickUpSize = [[flickUpLabe text] sizeWithFont:[flickUpLabe font]];
        flickUpLabe.frame = CGRectMake(48, 204, flickUpSize.width, flickUpSize.height);
        pinchLabel = [UILabel new];
        pinchLabel.text = @"Pinch to delete";
        pinchLabel.font = introFonts;
        pinchLabel.textColor = introColor;
        pinchLabel.backgroundColor = backgroundColor;
        CGSize pinchSize = [[pinchLabel text] sizeWithFont:[pinchLabel font]];
        pinchLabel.frame = CGRectMake(48, 304, pinchSize.width, pinchSize.height);
        setLabel = [UILabel new];
        setLabel.text = @"Set time, sound and action";
        setLabel.font = introFonts;
        setLabel.textColor = introColor;
        setLabel.backgroundColor = backgroundColor;
        CGSize setSize = [[setLabel text] sizeWithFont:[setLabel font]];
        setLabel.frame = CGRectMake(48, 152, setSize.width, setSize.height);
        tackLabel = [UILabel new];
        tackLabel.text = @"Assembled by";
        tackLabel.font = introFonts;
        tackLabel.textColor= introColor;
        tackLabel.backgroundColor = backgroundColor;
        CGSize tackSize = [[tackLabel text] sizeWithFont:[tackLabel font]];
        tackLabel.frame = CGRectMake(tackCoordinates.x, tackCoordinates.y, tackSize.width, tackSize.height);
        
        
        
        
        
        
        
        
        [self addSubview:bgImage];
        //[self addSubview:tackLogo];
        [self addSubview:underline];
        //[bgImage addSubview:intro];
        //[self addSubview:intro];
        
        [self addSubview:createLabel];
        [self addSubview:createIcon];
        [self addSubview:flickDownLabel];
        [self addSubview:flickDownIcon];
        [self addSubview:flickUpLabe];
        [self addSubview:flickUpIcon];
        [self addSubview:pinchLabel];
        [self addSubview:pinchIcon];
        [self addSubview:setLabel];
        [self addSubview:setIcon];
        [self addSubview:tackLabel];
        [self addSubview:tackLogo];
        
        
        
        [self addSubview:copyText];
        [self addSubview:versionText];
        //[self addSubview:tackCopy];
        [self addSubview:timePicker];
        [self addSubview:tackButton];
        
        
        
                
        [copyText setText:@"Snooze Duration        min"]; // leave the spaces. i know, a hack
        [versionText setText:@"v1.1"];
        //[tackCopy setText:@"Assembled by"];
        //[tackLogo setAlpha:.8];
        
        [tackButton addTarget:self action:@selector(tackTapped:) forControlEvents:UIControlEventTouchUpInside];
                
        [timePicker setDelegate:self];
        [timePicker setShowsVerticalScrollIndicator:NO];
        [timePicker setShowsHorizontalScrollIndicator:NO];
        
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
        [versionText setFont:smlRobotoFont];
        [versionText setTextColor:[UIColor grayColor]];
        [versionText setBackgroundColor:[UIColor clearColor]];
    
        
        //[tackCopy setFont:smlRobotoFont];    [tackCopy setTextColor:textColor];
        //[tackCopy setBackgroundColor:[UIColor clearColor]];
        
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
        [self animateTimePicker];
 
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize frameSize = [[UIScreen mainScreen] applicationFrame].size;
    CGSize introSize;
    CGPoint buttonPosition;
    
    if ([UIScreen mainScreen].applicationFrame.size.height < 500) {
       introSize = CGSizeMake(intro.image.size.width, intro.image.size.height);
        buttonPosition = CGPointMake(40, 330);
    }else{
        introSize = CGSizeMake(262, 323);
        buttonPosition = CGPointMake(40, 380);
    }

    
    
    
    //CGSize tackTextSize = [[tackCopy text] sizeWithFont:[tackCopy font]];
    CGSize copyTextSize = [[copyText text] sizeWithFont:[copyText font]];
    CGSize versionTextSize = [[versionText text] sizeWithFont:[versionText font]];
    
    CGRect bgRect = CGRectMake(0, frameSize.height - bgImage.frame.size.height, frameSize.width, bgImage.frame.size.height);
    //CGRect tackCopyRect = CGRectMake((frameSize.width - (tackTextSize.width+41)) - 25,
      //                               frameSize.height - 40,
        //                             tackTextSize.width, tackTextSize.height);

    //CGRect tackRect = CGRectMake(tackCopyRect.origin.x + tackCopyRect.size.width + 5,
                             //    tackCopyRect.origin.y - 15, 41, 40);
    CGRect tackButtonRect = CGRectMake(buttonPosition.x, buttonPosition.y, 180, 44);
    CGRect copyTextRect = CGRectMake(15, 20, 
                                     copyTextSize.width, copyTextSize.height);
    CGRect versionTextRect = CGRectMake(frameSize.width - versionTextSize.width - 5, frameSize.height - versionTextSize.height - 5, versionTextSize.width, versionTextSize.height);
    
    CGRect underlineRect = CGRectMake(copyTextRect.origin.x,
                                      copyTextRect.origin.y + copyTextRect.size.height + 4,
                                      frameSize.width-(copyTextRect.origin.y*2),
                                      1);
    CGRect introRect= CGRectMake(underlineRect.origin.x, underlineRect.origin.y + 50, 
                                 introSize.width, introSize.height);
    NSLog(@"x, y, %f %f", underlineRect.origin.x, underlineRect.origin.y + 50);
    CGRect scrollRect = CGRectMake(frameSize.width-180, 0, 180,
                                   frameSize.height);
    
    bgImage.frame = bgRect;
    //tackLogo.frame = tackRect;
   // tackCopy.frame = tackCopyRect;
    tackButton.frame = tackButtonRect;
    copyText.frame = copyTextRect;
    versionText.frame = versionTextRect;
    
    underline.frame = underlineRect;
    intro.frame = introRect;
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
    timePicker.showsVerticalScrollIndicator = NO;
    //[timePicker sizeToFit];
}

-(void) snoozeTimeSelected:(UIButton *)button {
    if (pickingSnooze) {
        selectedIndex = (int)roundf( button.frame.origin.y / optionHeight);
    }
    pickingSnooze = NO;
    createLabel.alpha = 1;
    setLabel.alpha = 1;
    flickUpLabe.alpha = 1;
    flickDownLabel.alpha = 1;
    pinchLabel.alpha = 1;
    createIcon.alpha = 1;
    setIcon.alpha = 1;
    flickUpIcon.alpha = 1;
    flickDownIcon.alpha = 1;
    pinchIcon.alpha = 1;
    tackLabel.alpha = 1;
    tackLogo.alpha = 1;
    [self animateTimePicker];
}

-(void)tackTapped:(id)button {
    NSURL* tackURL = [NSURL URLWithString:@"http://tackmobile.com/products/start?ref=start"];
    if ([[UIApplication sharedApplication] canOpenURL:tackURL])
        [[UIApplication sharedApplication] openURL:tackURL];
}

-(void) navigatingAway {
    pickingSnooze= NO;
    [self animateTimePicker];
    NSLog(@"navigatingaway");
}

#pragma mark - touches
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (pickingSnooze) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLoc = [touch locationInView:self];
    
    if (!pickingSnooze && CGRectContainsPoint(CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, copyText.frame.size.height + copyText.frame.origin.y), touchLoc)) {
        pickingSnooze = YES;
        //fade the background
        createLabel.alpha = 0.3;
        setLabel.alpha = 0.3;
        flickUpLabe.alpha = 0.3;
        flickDownLabel.alpha = 0.3;
        pinchLabel.alpha = 0.3;
        createIcon.alpha = 0.3;
        setIcon.alpha = 0.3;
        flickUpIcon.alpha = 0.3;
        flickDownIcon.alpha = 0.3;
        pinchIcon.alpha = 0.3;
        tackLabel.alpha = 0.3;
        tackLogo.alpha = 0.3;
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
            createLabel.alpha = 1;
            flickUpLabe.alpha = 1;
            flickDownLabel.alpha = 1;
            setLabel.alpha = 1;
            pinchLabel.alpha = 1;
            createIcon.alpha = 1;
            setIcon.alpha = 1;
            flickUpIcon.alpha = 1;
            flickDownIcon.alpha = 1;
            pinchIcon.alpha = 1;
            tackLabel.alpha = 1;
            tackLogo.alpha = 1;

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
