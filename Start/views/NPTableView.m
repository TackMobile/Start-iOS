#import "NPTableView.h"

@implementation NPTableView

@dynamic delegate;

- (void) reloadData {
    [self.delegate willReloadData];
    
    [super reloadData];
    
    [self.delegate didReloadData];
}

- (void) layoutSubviews {
    [self.delegate willLayoutSubviews];
    
    [super layoutSubviews];
    
    [self.delegate didLayoutSubviews];
}

@end