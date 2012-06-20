//
//  SelectDurationView.h
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectDurationView;

@protocol SelectDurationViewDelegate <NSObject>
-(void) durationDidChange:(SelectDurationView *)selectDuration;
@optional
-(void) durationDidBeginChanging:(SelectDurationView *)selectDuration;
-(void) durationDidEndChanging:(SelectDurationView *)selectDuration;


@end

enum SelectDurationHandleSelected {
    SelectDurationNoHandle = 0,
    SelectDurationOuterHandle,
    SelectDurationInnerHandle,
    SelectDurationCenterHandle
};
enum SelectDurationDraggingOrientation {
    SelectDurationDraggingNone = 0,
    SelectDurationDraggingVert,
    SelectDurationDraggingHoriz,
};

@interface SelectDurationView : UIView {    
    float outerRadius;
    float innerRadius;
    float centerRadius;
    
    int draggingOrientation;
    
    CGRect originalFrame;
        
    CGPoint center;
}
@property int handleSelected;

@property float outerAngle;
@property float innerAngle;

@property (strong, nonatomic) id<SelectDurationViewDelegate> delegate;

-(NSTimeInterval) getTimeInterval;
-(id) initWithFrame:(CGRect)frame delegate:(id<SelectDurationViewDelegate>)aDelegate;

@end
