//
//  SelectAlarmView.m
//  Start
//
//  Created by Nick Place on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectAlarmView.h"

int MAX_ALARMS = 6;
int ALARM_SPACING = 5;

@interface SelectAlarmView()

@property (nonatomic, strong) UIView *alarmContainer;
@property (nonatomic, strong) UIButton *plusButton;
@property (nonatomic, strong) NSMutableArray *alarmButtons;
@property (nonatomic) int numAlarms;
@property (nonatomic) float restedY;

@end

@implementation SelectAlarmView

const float setAlarmY = 15;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _alarmButtons = [[NSMutableArray alloc] init];
    
    CGRect plusRect = CGRectMake(7, 7, 38, 38);
    CGRect alarmContainerRect = CGRectMake(plusRect.origin.x + plusRect.size.width + ALARM_SPACING, plusRect.origin.y, self.frame.size.width - plusRect.origin.x - plusRect.size.width - ALARM_SPACING, plusRect.size.height);
    
    _plusButton = [[UIButton alloc] initWithFrame:plusRect];
    _alarmContainer = [[UIView alloc] initWithFrame:alarmContainerRect];
    
    [_plusButton addTarget:self action:@selector(plusButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_alarmContainer];
    _restedY = _alarmContainer.frame.size.height/2 - 1;
    [_plusButton setImage:[UIImage imageNamed:@"plusButton"] forState:UIControlStateNormal];
    
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<SelectAlarmViewDelegate>)aDelegate {
  self.delegate = aDelegate;
  return [self initWithFrame:frame];
}

#pragma mark - Actions

- (void)plusButtonTapped:(id)button {
  // return if there are already max_alarms
  if (self.numAlarms == MAX_ALARMS) {
    return;
  }
  
  if ([self.delegate respondsToSelector:@selector(alarmAdded)]) {
    [self.delegate alarmAdded];
  }
}

- (void)deleteAlarm:(NSInteger)index {
  self.numAlarms--;
  [self animateRemoveAlarmAtIndex:self.numAlarms - index];
  return;
}

- (void)addAlarmAnimated:(bool)animated {
  self.numAlarms++;
  
  // Position new alarmbutton
  CGRect newAlarmRect = CGRectMake(0, self.restedY, 0, 2);
  UIView *newAlarm = [[UIView alloc] initWithFrame:newAlarmRect];
  [newAlarm setBackgroundColor:[UIColor whiteColor]];
  [self.alarmContainer addSubview:newAlarm];
  [self.alarmButtons insertObject:newAlarm atIndex:0];
  
  // Animate the insert of new alarm button
  if (animated) {
    [self animateArrangeButtons];
  } else {
    [self arrangeButtons];
  }
}

- (void)makeAlarmActiveAtIndex:(NSInteger)index {
  NSInteger buttonIndex = self.numAlarms - 1 - index;
  for (UIView *alarmButton in self.alarmButtons) {
    [alarmButton setAlpha:.7];
  }
  [[self.alarmButtons objectAtIndex:buttonIndex] setAlpha:1];
}

- (void)makeAlarmSetAtIndex:(NSInteger)index percent:(float)percent {
  NSInteger buttonIndex = self.numAlarms - 1 - index;
  UIView *alarmButton = [self.alarmButtons objectAtIndex:buttonIndex];
  CGRect alarmButtonSetRect = CGRectMake(alarmButton.frame.origin.x, self.restedY - (percent * setAlarmY), alarmButton.frame.size.width, alarmButton.frame.size.height);
  
  if (percent == 1 || percent == 0) {
    [UIView animateWithDuration:.2 animations:^{
      [alarmButton setFrame:alarmButtonSetRect];
    }];
  } else {
    alarmButton.frame = alarmButtonSetRect;
  }
}

#pragma mark - Animations

- (void)animateArrangeButtons {
  [UIView animateWithDuration:.1 animations:^{
    [self arrangeButtons];
  }];
}

- (void)animateRemoveAlarmAtIndex:(NSInteger)index {
  float buttonWidth = (self.alarmContainer.frame.size.width - ALARM_SPACING*self.numAlarms) / self.numAlarms;
  
  [UIView animateWithDuration:.1 animations:^{
    for (NSInteger i=self.alarmButtons.count-1; i>=0; i--) { // faster than iterating upwards
      UIView *alarmButton = [self.alarmButtons objectAtIndex:i];
      CGRect newButtonFrame;
      
      if (i == index)
      newButtonFrame = CGRectMake((buttonWidth+ALARM_SPACING)*i, alarmButton.frame.origin.y, 0, alarmButton.frame.size.height);
      else if (i > index)
      newButtonFrame = CGRectMake((buttonWidth+ALARM_SPACING)*(i-1), alarmButton.frame.origin.y, buttonWidth, alarmButton.frame.size.height);
      else
      newButtonFrame = CGRectMake((buttonWidth+ALARM_SPACING)*i, alarmButton.frame.origin.y, buttonWidth, alarmButton.frame.size.height);
      
      [[self.alarmButtons objectAtIndex:i] setFrame:newButtonFrame];
    }
  } completion:^(BOOL finished) {
    [self.alarmButtons removeObjectAtIndex:index];
    NSInteger switchIndex = index==0?0:index-1;
    if ([self.delegate respondsToSelector:@selector(switchAlarmWithIndex:)])
    [self.delegate switchAlarmWithIndex:self.numAlarms - 1 - switchIndex];
  }];
}

#pragma mark - Touches
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.numAlarms == 0) {
    return;
  }
  UITouch *touch = [touches anyObject];
  CGPoint touchLoc = [touch locationInView:self.alarmContainer];
  
  int touchIndex = self.numAlarms - 1 - floorf(touchLoc.x/ (self.alarmContainer.frame.size.width/self.numAlarms));
  
  if ([self.delegate respondsToSelector:@selector(switchAlarmWithIndex:)]) {
    [self.delegate switchAlarmWithIndex:touchIndex];
  }
}

#pragma mark - Drawing

- (void)arrangeButtons {
  float buttonWidth = (self.alarmContainer.frame.size.width - ALARM_SPACING*self.numAlarms) / self.numAlarms;
  
  for (NSInteger i=self.alarmButtons.count-1; i>=0; i--) { // faster than iterating upwards
    UIView *alarmButton = [self.alarmButtons objectAtIndex:i];
    CGRect newButtonFrame = CGRectMake((buttonWidth+ALARM_SPACING)*i, alarmButton.frame.origin.y, buttonWidth, alarmButton.frame.size.height);
    [[self.alarmButtons objectAtIndex:i] setFrame:newButtonFrame];
  }
}

@end
