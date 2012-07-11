//
//  SelectActionView.h
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionCell.h"

@protocol SelectActionViewDelegate <NSObject>
-(BOOL) expandSelectActionView;
-(void) actionSelected:(NSNumber *)actionID;
@end

@interface SelectActionView : UIView <UITableViewDataSource, UITableViewDelegate> {
    CGRect compressedFrame;
    NSIndexPath *selectedIndexPath;
}

@property (nonatomic, strong) id<SelectActionViewDelegate> delegate;

@property (nonatomic, strong) NSArray *actions;
@property (nonatomic, strong) UITableView *actionTableView;

- (void) quickSelectCell;
- (void) selectActionWithID:(NSNumber *)aID;
- (id) initWithFrame:(CGRect)frame delegate:(id<SelectActionViewDelegate>)aDelegate actions:(NSArray *)theActions;
@end
