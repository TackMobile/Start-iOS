//
//  SettingsView.m
//  Start
//
//  Created by Nick Place on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsView.h"

@implementation SettingsView

@synthesize snoozeTimeField;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect bgRect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        CGRect snoozeFieldRect = CGRectMake(bgRect.size.width/2, bgRect.size.height/2, 70, 40);
        
        bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"about"]];
        snoozeTimeField = [[UITextField alloc] initWithFrame:snoozeFieldRect];
        [snoozeTimeField setDelegate:self];
        [bgImage setFrame:bgRect];
        
        [self addSubview:bgImage];
        [self addSubview:snoozeTimeField];
        [self setBackgroundColor:[UIColor blueColor]];
        
        [snoozeTimeField setDelegate:self];
        [snoozeTimeField setBackgroundColor:[UIColor whiteColor]];
        [snoozeTimeField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
        [snoozeTimeField setReturnKeyType:UIReturnKeyDone];
        [snoozeTimeField addTarget:self action:@selector(snoozeTimeDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"snoozeTime"])
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:10] forKey:@"snoozeTime"];
 
        [snoozeTimeField setText:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"snoozeTime"]]];
    }
    return self;
}

-(void) navigatingAway {
    [snoozeTimeField setText:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"snoozeTime"]]];
    [snoozeTimeField resignFirstResponder];
    
}

#pragma mark - textField delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![[textField text] isEqualToString:@""]) {
        NSNumber *snoozeDur = [NSNumber numberWithInt:[[textField text] intValue]];
        [[NSUserDefaults standardUserDefaults] setObject:snoozeDur forKey:@"snoozeTime"];
        [textField resignFirstResponder];
        return YES;
    }
    return NO;
}

-(void) snoozeTimeDidChange:(id)textfield {
    // replace textfield with intvalue
    if (![snoozeTimeField.text isEqualToString:[NSString stringWithFormat:@"%i",[[snoozeTimeField text] intValue]]])
        [snoozeTimeField setText:[NSString stringWithFormat:@"%i",[[snoozeTimeField text] intValue]]];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
