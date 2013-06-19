//
//  SearchhSongCell.h
//  Start
//
//  Created by Nick Place on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol SearchSongCellDelegate <NSObject>
-(void) textChanged:(UITextField *)textField;
-(void) textCleared:(UITextField *)textField;
-(bool) shouldBeginSearching;
-(void) didBeginSearching;
-(void) didEndSearchingWithText:(NSString*)text;

@end

@interface SearchSongCell : UITableViewCell <UITextFieldDelegate> {
    NSTimer *alertDelTimer;
    
    bool isEditing;
}

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIImageView *searchImage;
@property (nonatomic, strong) UIButton *clearTextButton;
@property (nonatomic, strong) UIImageView *searchDivider;

@property (nonatomic, strong) id<SearchSongCellDelegate> delegate;


-(void) alertDelegateChangedText:(NSTimer*)timer;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier delegate:(id<SearchSongCellDelegate>)aDelegate;
@end
