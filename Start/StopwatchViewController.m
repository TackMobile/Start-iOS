//
//  StopwatchViewController.m
//  Start
//
//  Created by Nick Place on 12/18/12.
//
//

#import "StopwatchViewController.h"

@interface StopwatchViewController ()

@end

@implementation StopwatchViewController
@synthesize timerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect timerFrame = (CGRect){{0, 100}, {self.view.frame.size.width, 100}};
    timerView = [[TimerView alloc] initWithFrame:timerFrame];
    [self.view addSubview:timerView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
