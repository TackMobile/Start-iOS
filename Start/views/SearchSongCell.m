//
//  SearchhSongCell.m
//  Start
//
//  Created by Nick Place on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchSongCell.h"

@implementation SearchSongCell
@synthesize delegate, textField, searchImage, clearTextButton, searchDivider;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        isEditing = NO;
        
        UIFont *textFieldFont = [UIFont fontWithName:@"Roboto-Thin" size:30];
        CGRect clearTextRect = CGRectMake(0, 0, 20, 20);
        
        textField = [[UITextField alloc] init];
        searchImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search-icon"]];
        clearTextButton = [[UIButton alloc] initWithFrame:clearTextRect];
        searchDivider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search-divider"]];
        
        [clearTextButton setImage:[UIImage imageNamed:@"clear-icon"] forState:UIControlStateNormal];
        [textField setDelegate:self];
        [textField setFont:textFieldFont];
        [textField setText:@"Search"];
        [textField setTextColor:[UIColor whiteColor]];
        [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [textField setReturnKeyType:UIReturnKeyDone];
        [textField setKeyboardAppearance:UIKeyboardAppearanceAlert];
        
        [clearTextButton addTarget:self action:@selector(clearButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:textField];
        [self addSubview:clearTextButton];
        [self addSubview:searchImage];
        [self addSubview:searchDivider];
        
        [clearTextButton setAlpha:0];
        
        // notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(id<SearchSongCellDelegate>)aDelegate {
    delegate = aDelegate;
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier];
}
-(void) alertDelegateChangedText:(NSTimer*)timer {
    if ([delegate respondsToSelector:@selector(textChanged:)])
        [delegate textChanged:textField];
    alertDelTimer = nil;
}
#pragma mark - button delegate
- (void) clearButtonTapped:(id)button {
    if ([[textField text] isEqualToString:@""]) {
        [textField resignFirstResponder];
        [self textFieldDidEndEditing:textField];
    }
    isEditing = YES;
    [textField setText:@""];
    isEditing = NO;
}

#pragma mark - Positioning
- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGSize textFieldSize = [@"Search" sizeWithFont:[textField font]];
    CGSize imageSize = searchImage.frame.size;
    CGSize clearTextSize = clearTextButton.frame.size;
    
    CGRect imageRect = CGRectMake(7, (self.frame.size.height-imageSize.height)/2 -3, imageSize.width, imageSize.height);
    CGRect clearTextRect = CGRectMake(self.frame.size.width-clearTextSize.width-20, (self.frame.size.height-clearTextSize.height)/2 -3, clearTextSize.width, clearTextSize.height);
    CGRect textFieldRect = CGRectMake(imageRect.origin.x+imageSize.width+7, (self.frame.size.height-textFieldSize.height)/2 -3, self.frame.size.width-imageRect.size.width-15, textFieldSize.height);
    CGRect searchDivRect = CGRectMake(0, self.frame.size.height-11, self.frame.size.width, 1);
    
    [searchImage setFrame:imageRect];
    [textField setFrame:textFieldRect];
    [clearTextButton setFrame:clearTextRect];
    [searchDivider setFrame:searchDivRect];
}

#pragma mark - textfield delegate
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    if ([delegate respondsToSelector:@selector(shouldBeginSearching)])
        if ([delegate shouldBeginSearching])
            return YES;
    return NO;
}
-(void) textFieldDidChange:(NSDictionary *)userInfo {
    if (!isEditing) {
        return;
    }
    
    if (!alertDelTimer)
        alertDelTimer = [NSTimer scheduledTimerWithTimeInterval:.7 target:self selector:@selector(alertDelegateChangedText:) userInfo:nil repeats:NO];
    else
        [alertDelTimer setFireDate:[NSDate dateWithTimeInterval:.7 sinceDate:[NSDate date]]];
}
-(void) textFieldDidBeginEditing:(UITextField *)aTextField {
    if ([textField.text isEqualToString:@"Search"])
        [textField setText:@""];
    
    isEditing = YES;
    
    [clearTextButton setAlpha:1];
    if ([delegate respondsToSelector:@selector(didBeginSearching)])
        [delegate didBeginSearching];
}
-(void) textFieldDidEndEditing:(UITextField *)aTextField {
    isEditing = NO;
    if ([textField.text isEqualToString:@""]) {
        [textField setText:@"Search"];
        [clearTextButton setAlpha:0];
        if ([delegate respondsToSelector:@selector(didEndSearchingWithText:)])
            [delegate didEndSearchingWithText:[aTextField text]];
    }
}
-(BOOL) textFieldShouldReturn:(UITextField *)aTextField {
    [textField resignFirstResponder];
    if ([delegate respondsToSelector:@selector(didEndSearchingWithText:)])
        [delegate didEndSearchingWithText:[aTextField text]];
    return YES;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
