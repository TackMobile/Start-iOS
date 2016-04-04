//
//  SettingsView.m
//  Start
//
//  Created by Nick Place on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsView.h"
#import "Constants.h"
#import "LocalizedStrings.h"

@implementation SettingsView
@synthesize delegate;

const float optionHeight = 40;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        
        pickingSnooze = NO;
        selectedIndex = 0;
      
        if ([UIScreen mainScreen].applicationFrame.size.height < 500   ) {
            bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grid-background"]];
            tackLogo = [[UIImageView alloc] initWithFrame:CGRectMake(220, 420, 30, 30)];
        }else{
            bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grid-background-568h@2x.png"]];
            tackLogo = [[UIImageView alloc] initWithFrame:CGRectMake(220, 506, 30, 30)];
        }
        
        
        tackButton = [[UIButton alloc] init];
        underline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search-divider"]];
        copyText = [[UILabel alloc] init];
        versionText = [UILabel new];
        timePicker = [[UIScrollView alloc] init];
        
        UIFont *introFonts = [UIFont fontWithName:StartFontName.robotoThin size:20];
        UIColor *introColor = [UIColor whiteColor];
        UIColor *backgroundColor = [UIColor clearColor];
        
        labelCopy = @[
                     [LocalizedStrings createANewSpace],
                     [LocalizedStrings tapToSwitch],
                     [LocalizedStrings setTimeSoundAction],
                     [LocalizedStrings flickUpToActivate],
                     [LocalizedStrings flickDownStopwatch],
                     [LocalizedStrings pinchToDelete],
                     [LocalizedStrings keepOpenForMusic],
                     ];
        
        labelIcons = @[
                      [UIImage imageNamed:@"create-icon"],
                      [UIImage imageNamed:@"tap-icon"],
                      [UIImage imageNamed:@"set-icon"],
                      [UIImage imageNamed:@"flick-up-icon"],
                      [UIImage imageNamed:@"flick-down-icon"],
                      [UIImage imageNamed:@"pinch-icon"],
                      [UIImage imageNamed:@"song-icon"],
                      ];
        
        float introSpacing = 47;
        float iconCenterX = 27;
        float introStart = underline.frame.origin.y + 85;
        
        instructionsView = [[UIView alloc] initWithFrame:(CGRect){{0,0}, self.frame.size}];
        
        [self addSubview:bgImage];
        [instructionsView addSubview:underline];
        
        introLabels = [NSMutableArray new];
        for (int i=0; i<labelCopy.count; i++) {
            UIImage *labelIcon = [labelIcons objectAtIndex:i];
            NSString *labelText = [labelCopy objectAtIndex:i];
            
            UILabel *introLabel = [[UILabel alloc] init];
            UIImageView *introIconView = [[UIImageView alloc] initWithImage:labelIcon];
            
            [introIconView sizeToFit];
            
            introLabel.text = labelText;
            introLabel.textColor = introColor;
            introLabel.font = introFonts;
            introLabel.backgroundColor = backgroundColor;
            
            CGSize labelSize = [introLabel.text sizeWithAttributes:@{NSFontAttributeName: introLabel.font}];
            CGSize iconSize = introIconView.frame.size;
            
            CGRect labelRect = (CGRect){
                {48, floorf((introStart + (introSpacing * i)))},
                labelSize};
            
            CGRect iconRect = (CGRect){
                {floorf(iconCenterX - (iconSize.width/2)),
                    floorf((labelRect.origin.y + labelSize.height/2) - (iconSize.height/2))},
                iconSize};
            
            [introLabel setFrame:labelRect];
            [introIconView setFrame:iconRect];
            
            [instructionsView addSubview:introLabel];
            [instructionsView addSubview:introIconView];
            
            [introLabels addObject:introLabel];
            [introLabels addObject:introIconView];
            

        }

        tackLabel = [UILabel new];
        tackLabel.text = [LocalizedStrings assembledBy];
        tackLabel.font = [UIFont fontWithName:introFonts.fontName size:15];
        tackLabel.textColor= introColor;
        tackLabel.backgroundColor = backgroundColor;
        CGSize tackSize = [tackLabel.text sizeWithAttributes:@{NSFontAttributeName: tackLabel.font}];
        
        tackLabel.frame = (CGRect){{tackLogo.frame.origin.x - (tackSize.width + 8),
            (tackLogo.frame.origin.y+tackLogo.frame.size.height/2) - tackSize.height/2 + 3},
            tackSize};
        
        tackLogo.image = [UIImage imageNamed:@"tack-logo"];

        [self addSubview:tackLabel];
        [self addSubview:tackLogo];
        
        [instructionsView addSubview:copyText];
        [self addSubview:versionText];
        [instructionsView addSubview:timePicker];
        
        [self addSubview:instructionsView];
        [self addSubview:tackButton];

        
        
        // add the time picker
        [copyText setText:@"Snooze Duration        min"]; // leave the spaces. i know, a hack
        [versionText setText:version];
        
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
        UIFont *lgRobotoFont = [UIFont fontWithName:StartFontName.robotoThin size:26];
        UIFont *smlRobotoFont = [UIFont fontWithName:StartFontName.robotoThin size:17];
                
        UIColor *textColor = [UIColor whiteColor];
        
        [copyText setFont:lgRobotoFont];    [copyText setTextColor:textColor];
        [copyText setBackgroundColor:[UIColor clearColor]];
        [versionText setFont:smlRobotoFont];
        [versionText setTextColor:[UIColor colorWithWhite:1 alpha:.8]];
        [versionText setBackgroundColor:[UIColor clearColor]];
        
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
        if (![[NSUserDefaults standardUserDefaults] objectForKey:StartUserDefaultKey.snoozeTime]) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:10] forKey:StartUserDefaultKey.snoozeTime];
            selectedIndex = 0;
        } else {
            NSNumber *savedSnooze = [[NSUserDefaults standardUserDefaults] objectForKey:StartUserDefaultKey.snoozeTime];
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

- (id) initWithDelegate:(id)_delegate frame:(CGRect)frame {
    self.delegate = _delegate;
    return [self initWithFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize frameSize = [[UIScreen mainScreen] applicationFrame].size;
    CGSize introSize;
    
    if ([UIScreen mainScreen].applicationFrame.size.height < 500) {
       introSize = CGSizeMake(intro.image.size.width, intro.image.size.height);
    }else{
        introSize = CGSizeMake(262, 323);
    }

    
    CGSize copyTextSize = [copyText.text sizeWithAttributes:@{NSFontAttributeName: copyText.font}];
    CGSize versionTextSize = [versionText.text sizeWithAttributes:@{NSFontAttributeName: versionText.font}];
    
    CGRect bgRect = CGRectMake(0, frameSize.height - bgImage.frame.size.height, frameSize.width, bgImage.frame.size.height);
    
    CGRect tackButtonRect = (CGRect){{tackLabel.frame.origin.x, tackLogo.frame.origin.y}, {tackLogo.frame.origin.x + tackLogo.frame.size.width - tackLabel.frame.origin.x, tackLogo.frame.size.height}};
    
    CGRect copyTextRect = CGRectMake(15, 20, 
                                     copyTextSize.width, copyTextSize.height);
    CGRect versionTextRect = CGRectMake(frameSize.width - versionTextSize.width - 19   ,
                                        floorf(frameSize.height - (versionTextSize.height + 14)), versionTextSize.width, versionTextSize.height);
    
    CGRect underlineRect = CGRectMake(copyTextRect.origin.x,
                                      copyTextRect.origin.y + copyTextRect.size.height + 4,
                                      frameSize.width-(copyTextRect.origin.y*2),
                                      1);
    CGRect introRect= CGRectMake(underlineRect.origin.x, underlineRect.origin.y + 50, 
                                 introSize.width, introSize.height);
    CGRect scrollRect = CGRectMake(frameSize.width-180, 0, 180,
                                   frameSize.height);
    
    bgImage.frame = bgRect;
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
}

#pragma mark - UI

-(void) snoozeTimeSelected:(UIButton *)button {
    if (pickingSnooze) {
        selectedIndex = (int)roundf( button.frame.origin.y / optionHeight);
    }
    pickingSnooze = NO;
    tackLabel.alpha = 1;
    tackLogo.alpha = 1;
    [self animateTimePicker];
}

-(void)tackTapped:(id)button {
    NSURL* tackURL = [NSURL URLWithString:TackMobileURL];
    if ([[UIApplication sharedApplication] canOpenURL:tackURL])
        [[UIApplication sharedApplication] openURL:tackURL];
}

-(void)lockTapped:(id)button {
    [UIView animateWithDuration:.3 animations:^{
        [introView setFrame:CGRectOffset(introView.frame, -30, 0)];
        introView.alpha = 0;
        [instructionsView setFrame:CGRectOffset(instructionsView.frame, -30, 0)];
        instructionsView.alpha = 1;
    }];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:StartUserDefaultKey.seenIntro];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([delegate respondsToSelector:@selector(showPlus)]) {
        [delegate showPlus];
    }
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
        
    if (!pickingSnooze && CGRectContainsPoint(CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, copyText.frame.size.height + copyText.frame.origin.y), touchLoc)) {
        pickingSnooze = YES;
        //fade the background
        for (UIView *label in introLabels) {
            [label setAlpha:.3];
        }
        [self animateTimePicker];
    }
}

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
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pickingSnooze = NO;
    [self animateTimePicker];
}

-(void) animateTimePicker {
    if (!pickingSnooze) {
        // save snooze time
        [[NSUserDefaults standardUserDefaults] setValue:[snoozeOptions objectAtIndex:selectedIndex]
                                                 forKey:StartUserDefaultKey.snoozeTime];
        
        float roundedOffset = (selectedIndex * optionHeight) - timePicker.contentInset.top;
        [timePicker setUserInteractionEnabled:NO];
        [UIView animateWithDuration:.1 animations:^{
            if (timePicker.contentOffset.y != roundedOffset)
                timePicker.contentOffset = CGPointMake(0, roundedOffset);
            
            [bgImage setAlpha:1];
            for (UIView *label in introLabels) {
                [label setAlpha:1];
            }

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

@end
