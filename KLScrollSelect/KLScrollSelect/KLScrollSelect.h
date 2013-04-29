//
//  KLViewController.h
//  KLScrollSelectViewController
//
//  Created by Kieran Lafferty on 2013-04-02.
//  Copyright (c) 2013 KieranLafferty. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kDefaultCellImageEdgeInset UIEdgeInsetsMake(5, 5, 5, 5)


@class KLScrollSelectViewController, KLScrollingColumn, KLScrollSelect;

@protocol KLScrollingColumnDelegate <NSObject>
@optional
- (void) willUpdateContentOffsetForColumn: (KLScrollingColumn*) column;
- (void) didUpdateContentOffsetForColumn: (KLScrollingColumn*) column;
@end
@protocol KLScrollSelectDelegate <NSObject>
@optional
- (void)scrollSelect:(KLScrollSelect *)tableView didSelectCellAtIndexPath:(NSIndexPath *)indexPath;
@end
@protocol KLScrollSelectDataSource <NSObject>
@required
- (NSInteger)scrollSelect:(KLScrollSelect *)scrollSelect numberOfRowsInColumnAtIndex:(NSInteger)index;
- (UITableViewCell*) scrollSelect:(KLScrollSelect*) scrollSelect cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (CGFloat) scrollSelect: (KLScrollSelect*) scrollSelect heightForColumnAtIndex: (NSInteger) index;
- (CGFloat) scrollRateForColumnAtIndex: (NSInteger) index;
- (NSInteger)scrollSelect:(KLScrollSelect *)scrollSelect numberOfSectionsInColumnAtIndex:(NSInteger)index;
// Default is 1 if not implemented
- (NSInteger)numberOfColumnsInScrollSelect:(KLScrollSelectViewController *)scrollSelect;
@end

@interface KLScrollSelect : UIView <UITableViewDelegate, UITableViewDataSource, KLScrollingColumnDelegate>
@property (nonatomic, strong) NSArray* columns;
@property (nonatomic, strong) IBOutlet id<KLScrollSelectDataSource> dataSource;
@property (nonatomic, strong) IBOutlet id<KLScrollSelectDelegate> delegate;
- (NSInteger)scrollSelect:(KLScrollSelect *)scrollSelect numberOfRowsInColumnAtIndex:(NSInteger)index;
- (NSInteger)scrollSelect:(KLScrollSelect *)scrollSelect numberOfSectionsInColumnAtIndex:(NSInteger)index;
- (CGFloat) scrollSelect: (KLScrollSelect*) scrollSelect heightForColumnAtIndex: (NSInteger) index;

//Actions
- (UITableViewCell*) cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfColumnsInScrollSelect:(KLScrollSelect *)scrollSelect;
- (CGFloat) scrollRateForColumnAtIndex: (NSInteger) index;
- (KLScrollingColumn*) columnAtIndex:(NSInteger) index;
@end


@interface KLScrollSelectViewController : UIViewController <KLScrollSelectDataSource, KLScrollSelectDelegate>
@property (nonatomic, strong) KLScrollSelect* scrollSelect;
@end

@interface KLScrollingColumn : UITableView <UIScrollViewDelegate, UITableViewDelegate>
@property (nonatomic, strong) id<KLScrollingColumnDelegate> columnDelegate;
@property (nonatomic) CGFloat offsetDelta;
@property (nonatomic) CGFloat scrollRate;
@property (nonatomic) CGFloat offsetAccumulator;
- (void)resetContentOffsetIfNeeded;
@end


@interface KLImageCell : UITableViewCell
@property (nonatomic, strong) UIImageView* image;
@property (nonatomic, strong) UILabel* label;
@property (nonatomic, strong) UILabel* subLabel;
@end

@interface NSIndexPath (Column)
+ (NSIndexPath *)indexPathForRow:(NSInteger) row
                       inSection:(NSInteger) section
                        inColumn:(NSInteger) column;

@property(nonatomic, readonly) NSInteger column;

@end