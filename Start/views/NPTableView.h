
@protocol NPTableViewDelegate <NSObject, UITableViewDelegate>
@required
- (void)willReloadData;
- (void)didReloadData;
- (void)willLayoutSubviews;
- (void)didLayoutSubviews;
@end

@interface NPTableView : UITableView

@property(nonatomic,weak) id <NPTableViewDelegate> delegate;

@end;