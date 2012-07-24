//
//  SelectActionView.m
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectActionView.h"

@implementation SelectActionView
@synthesize delegate;
@synthesize actions, actionTableView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setClipsToBounds:YES];
        compressedFrame = frame;
        selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        needsQuickSelect = NO;
        
        // views
        CGRect screenBounds = [[UIScreen mainScreen] applicationFrame];
        CGRect actionTableRect = CGRectMake(0, 0, self.frame.size.width, screenBounds.size.height);
        
        actionTableView = [[NPTableView alloc] initWithFrame:actionTableRect style:UITableViewStylePlain];
        [actionTableView setDelegate:self];
        [actionTableView setDataSource:self];
        [actionTableView setUserInteractionEnabled:NO];
        [actionTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [actionTableView setRowHeight:50];
        [actionTableView setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:actionTableView];
        
        // TESTING
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame delegate:(id<SelectActionViewDelegate>)aDelegate actions:(NSArray *)theActions {
    actions = theActions;
    delegate = aDelegate;
    return [self initWithFrame:frame];
}

- (void) selectActionWithID:(NSNumber *)aID {
    int actionID = [aID intValue];
    selectedIndexPath = [NSIndexPath indexPathForRow:actionID inSection:0];
    needsQuickSelect = YES;
}

#pragma mark - Positioning

- (void) actionSelectedAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *actionID = [NSNumber numberWithInt:indexPath.row];
    
    if ([delegate respondsToSelector:@selector(actionSelected:)])
        [delegate actionSelected:actionID];
    
    [actionTableView setUserInteractionEnabled:NO];
    
    // hide cells above and below
    ActionCell *showCell = (ActionCell *)[actionTableView cellForRowAtIndexPath:selectedIndexPath];
    [UIView animateWithDuration:.2 animations:^{
        for (UITableViewCell *visibleCell in [actionTableView visibleCells])
            [visibleCell setAlpha:(visibleCell == showCell)?1:0];
        [showCell.actionTitle setAlpha:0];
    }];
}

- (void) viewTapped {
    if ([delegate respondsToSelector:@selector(expandSelectActionView)])
        if ([delegate expandSelectActionView]) {
            [actionTableView setUserInteractionEnabled:YES];
            
            // show surrounding cells
            [UIView animateWithDuration:.2 animations:^{
                for (ActionCell *visibleCell in [actionTableView visibleCells]) {
                    [visibleCell setAlpha:1];
                    [visibleCell.actionTitle setAlpha:1];
                }
            }];
        }
}

- (void) quickSelectCell {
    [self tableView:actionTableView didSelectRowAtIndexPath:selectedIndexPath];
}

#pragma mark - Touches
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch.tapCount >= 1) {
        [self viewTapped];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [actions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    static NSString *NormalActionCell = @"NormalActionCell";
    
    ActionCell *cell = (ActionCell *)[tableView dequeueReusableCellWithIdentifier:NormalActionCell];
    if (cell == nil) {
        cell = [[ActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NormalActionCell];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    NSDictionary *action = [actions objectAtIndex:indexPath.row];
    cell.actionTitle.text = [action objectForKey:@"title"];
    [cell.icon setImage:[UIImage imageNamed:[action objectForKey:@"iconFilename"]]];
    
    [cell setAlpha:1];
    [cell.actionTitle setAlpha:1];
    if ([selectedIndexPath compare:indexPath] == NSOrderedSame)
        [cell.actionTitle setAlpha:0];
    else
        [cell setAlpha:0];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0)
        return compressedFrame.size.height;
    return tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
    CGRect bottomRect = [tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:[tableView numberOfRowsInSection:[tableView numberOfSections]-1]-1 inSection:[tableView numberOfSections]-1]];
    
    /* center the cell*/
    float centerOffset = (compressedFrame.size.height-cellRect.size.height)/2;
    CGRect contentRect = CGRectMake(0, cellRect.origin.y-centerOffset, tableView.frame.size.width, tableView.frame.size.height);
    
    // extend rect
    float bottom = contentRect.origin.y + contentRect.size.height;
    float maxBottom = bottomRect.origin.y + bottomRect.size.height;
    if (bottom >= maxBottom)
        [tableView setContentSize:CGSizeMake(tableView.frame.size.width, bottom)];
    else
        [tableView setContentSize:CGSizeMake(tableView.contentSize.width, maxBottom)];
    
    selectedIndexPath = indexPath;
    [actionTableView scrollRectToVisible:contentRect animated:YES];
    [self actionSelectedAtIndexPath:indexPath];
}

#pragma mark - NPTableViewDelegate
- (void)willReloadData {
}
- (void)didReloadData {
}
- (void)willLayoutSubviews {
}
- (void)didLayoutSubviews {    
    if (needsQuickSelect) {
        [self quickSelectCell];
        needsQuickSelect = NO;
    }
}

@end
