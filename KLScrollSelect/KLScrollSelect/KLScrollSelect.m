//
//  KLViewController.m
//  KLScrollSelectViewController
//
//  Created by Kieran Lafferty on 2013-04-02.
//  Copyright (c) 2013 KieranLafferty. All rights reserved.
//

#import "KLScrollSelect.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define TRANSLATED_INDEX_PATH( __INDEXPATH__, __TOTALROWS__ ) [self translatedIndexPath:__INDEXPATH__ forTotalRows:__TOTALROWS__]
#define ROUND_NEAREST_HALF(__NUM__)
@implementation KLScrollSelectViewController
-(void) viewDidLoad {
    [super viewDidLoad];
    self.scrollSelect = [[KLScrollSelect alloc] initWithFrame: self.view.bounds];
    [self.scrollSelect setDataSource: self];
    [self.scrollSelect setDelegate: self];
    [self.view addSubview:self.scrollSelect];
}
- (NSInteger)scrollSelect:(KLScrollSelect *)scrollSelect numberOfRowsInColumnAtIndex:(NSInteger)index {
    return 0;
}
- (UITableViewCell*) scrollSelect:(KLScrollSelect*) scrollSelect cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}
@end
@interface KLScrollSelect()
-(void) populateColumns;
-(NSIndexPath*) translatedIndexPath: (NSIndexPath*) indexPath forTotalRows:(NSInteger) totalRows;
-(NSInteger) indexOfColumn:(KLScrollingColumn*) column;
-(void) synchronizeContentOffsetsWithDriver:(KLScrollingColumn*) drivingColumn;
-(void) startScrollingDriver;
-(void) stopScrollingDriver;


-(NSArray*) columnsWithoutColumn:(KLScrollingColumn*) column;
-(void) updateDriverOffset;


@property (nonatomic) BOOL shouldResumeAnimating;
@property (nonatomic,strong) NSArray* passengers;
@property (nonatomic,strong) KLScrollingColumn* driver;
@property (nonatomic,strong) KLScrollingColumn* smallestColumn;
@property (nonatomic, strong) NSTimer* animationTimer;

-(BOOL) animating;
@end
@implementation KLScrollSelect
-(BOOL) animating {
    return  (BOOL)self.animationTimer;
}
-(NSArray*) passengers {
    return [self columnsWithoutColumn: self.driver];
}
-(NSArray*) columnsWithoutColumn:(KLScrollingColumn*) column {
    return [self.columns filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject != column;
    }]];
}
-(void) layoutSubviews {
    [super layoutSubviews];
    [self populateColumns];
    [self startScrollingDriver];
    
}

-(void) synchronizeColumnsForMainDriver {
    [self synchronizeContentOffsetsWithDriver: self.driver];
}
-(void) populateColumns {
    NSInteger numberOfColumns = [self numberOfColumnsInScrollSelect:self];
    NSMutableArray* columns = [[NSMutableArray alloc] initWithCapacity:numberOfColumns];
    CGFloat columnWidth = self.frame.size.width/[self numberOfColumnsInScrollSelect:self];
    
    for (NSInteger count = 0; count < numberOfColumns;  count++) {
        //Make the frame the entire height and the width the width of the superview divided by number of columns
        CGRect columnFrame = CGRectMake(columnWidth * count, 0, columnWidth, self.frame.size.height);
        KLScrollingColumn* column = [[KLScrollingColumn alloc] initWithFrame:columnFrame style:UITableViewStylePlain];
        
        [column setDataSource:self];
        [column setRowHeight: [self scrollSelect:self heightForColumnAtIndex:count]];
        [column setSeparatorStyle: UITableViewCellSeparatorStyleNone];
        [column setBackgroundColor:[UIColor clearColor]];
        [column setColumnDelegate:self];
        [column setScrollRate: [self.dataSource scrollRateForColumnAtIndex: count]];
        [column setDelegate:self];
        [columns addObject: column];
        
        if (![[self subviews] containsObject: column]) {
            [self addSubview:column];
        }
    }
    self.columns = columns;
    NSInteger smallestCount = -1;
    for (KLScrollingColumn* column in self.columns) {
        NSInteger currentNumRows =  [self tableView:column numberOfRowsInSection:0];
        if (smallestCount < 0 || currentNumRows < smallestCount) {
            smallestCount = currentNumRows;
            self.smallestColumn = column;
        }
    }
    
}

#pragma mark - Driver & Passenger animation implementation
-(void) synchronizeContentOffsetsWithDriver:(KLScrollingColumn*) drivingColumn {
    if (self.driver.offsetDelta == 0)
        return;
    for (KLScrollingColumn* currentColumn in self.passengers) {
        CGPoint currentOffset = currentColumn.contentOffset;
        CGFloat relativeScrollRate = currentColumn.scrollRate / drivingColumn.scrollRate;
        currentOffset.y += drivingColumn.offsetDelta* relativeScrollRate;
        
        //Only move passenger when offset has accumulated to the min pixel movement threshold (0.5)
        currentColumn.offsetAccumulator += fabs(drivingColumn.offsetDelta * relativeScrollRate);
        if (currentColumn.offsetAccumulator >= 0.5) {
            [currentColumn setContentOffset: currentOffset];
            currentColumn.offsetAccumulator = 0;
        }
    }
}
-(void) startScrollingDriver {
    self.driver = self.columns[0];
    
    if (self.animating) {
        return;
    }
    CGFloat animationDuration = 0.5f / self.driver.scrollRate;
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval: animationDuration
                                                           target:self
                                                         selector:@selector(updateDriverAnimation)
                                                         userInfo:nil
                                                          repeats:YES];
    [self.animationTimer fire];
}
-(void) updateDriverAnimation {
    [self updateDriverOffset];
}
-(void) updateDriverOffset {
    CGFloat pointChange = 0.5;
    CGPoint newOffset = self.driver.contentOffset;
    newOffset.y = newOffset.y + pointChange;
    [self.driver setContentOffset: newOffset];
}

- (void)stopScrollingDriver {
    if (!self.animating) {
        return;
    }
    [self.driver.layer removeAllAnimations];
    [self.animationTimer invalidate];
    self.animationTimer = nil;
}

#pragma mark - UIScrollViewDelegate implementation
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //Stop animating driver
    [self setDriver: (KLScrollingColumn*) scrollView];
    [self stopScrollingDriver];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //Start animating driver
    [self startScrollingDriver];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self startScrollingDriver];
    }
}

#pragma  UITableViewDataSource implementation
//Column data source implementation
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger columnIndex = [self indexOfColumn: (KLScrollingColumn*)tableView];
    NSInteger numberOfRows = [self scrollSelect:self numberOfRowsInColumnAtIndex: columnIndex] * 3;
    return numberOfRows;
}

-(NSInteger) numberOfSectionsInTableView:(KLScrollingColumn *)tableView {
    return [self scrollSelect:self numberOfSectionsInColumnAtIndex:[self indexOfColumn: tableView]];
}
-(UITableViewCell*) tableView:(KLScrollingColumn *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger columnIndex = [self indexOfColumn:tableView];
    NSIndexPath* translatedIndex = TRANSLATED_INDEX_PATH(indexPath, [self scrollSelect:self
                                                           numberOfRowsInColumnAtIndex:columnIndex]);
    return [self cellForRowAtIndexPath: [NSIndexPath indexPathForRow: translatedIndex.row
                                                           inSection: translatedIndex.section
                                                            inColumn: columnIndex]];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger columnIndex = [self indexOfColumn: (KLScrollingColumn*)tableView];
    NSIndexPath* translatedIndex = TRANSLATED_INDEX_PATH(indexPath, [self scrollSelect: self
                                                           numberOfRowsInColumnAtIndex: columnIndex]);
    if ([self.delegate respondsToSelector:@selector(scrollSelect:didSelectCellAtIndexPath:)]) {
        [self.delegate scrollSelect:self didSelectCellAtIndexPath:[NSIndexPath indexPathForRow: translatedIndex.row
                                                                                     inSection: translatedIndex.section
                                                                                      inColumn: columnIndex]];
    }
}

#pragma mark - Delegate Implementation
- (CGFloat) scrollSelect: (KLScrollSelect*) scrollSelect heightForColumnAtIndex: (NSInteger) index {
    if ([self.dataSource respondsToSelector:@selector(scrollSelect:heightForColumnAtIndex:)]) {
        return [self.dataSource scrollSelect:self heightForColumnAtIndex:index];
    }
    else return 150.0;
}
-(NSIndexPath*) translatedIndexPath: (NSIndexPath*) indexPath forTotalRows:(NSInteger) totalRows{
    return [NSIndexPath indexPathForRow: indexPath.row % totalRows
                              inSection: indexPath.section];
}

#pragma mark - Datasource Implementation
- (NSInteger)scrollSelect:(KLScrollSelect *)scrollSelect numberOfRowsInColumnAtIndex:(NSInteger)index {
    return [self.dataSource scrollSelect: self
             numberOfRowsInColumnAtIndex: index];
}
- (NSInteger)scrollSelect:(KLScrollSelect *)scrollSelect numberOfSectionsInColumnAtIndex:(NSInteger)index {
    if ([self.dataSource respondsToSelector:@selector(scrollSelect:numberOfSectionsInColumnAtIndex:)]) {
        return [self.dataSource scrollSelect:self numberOfSectionsInColumnAtIndex: index];
    }
    else return 1;
}

-(NSInteger) numberOfColumnsInScrollSelect:(KLScrollSelectViewController *)scrollSelect {
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInScrollSelect:)]) {
        return [self.dataSource numberOfColumnsInScrollSelect:scrollSelect];
    }
    else return 1;
}
- (UITableViewCell*) cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource scrollSelect:self cellForRowAtIndexPath:indexPath];
}
- (KLScrollingColumn*) columnAtIndex:(NSInteger) index {
    return [self.columns objectAtIndex:index];
}
- (CGFloat) scrollRateForColumnAtIndex: (NSInteger) index {
    if ([self.dataSource respondsToSelector:@selector(scrollRateForColumnAtIndex:)]) {
        return [self.dataSource scrollRateForColumnAtIndex:index];
    }
    else return 10.0;
}
-(NSInteger) indexOfColumn:(KLScrollingColumn*) column {
    return [self.columns indexOfObject: column];
}
- (void) willUpdateContentOffsetForColumn: (KLScrollingColumn*) column {
    if (column == self.driver) {
    }
}
- (void) didUpdateContentOffsetForColumn: (KLScrollingColumn*) column {
    if (column == self.driver) {
        [self synchronizeColumnsForMainDriver];
    }
}
@end


@interface KLScrollingColumn()
{
    int mTotalCellsVisible;
    BOOL isResettingContent;
    NSInteger _totalRows;
}
- (void) resetContentOffsetIfNeeded;
- (BOOL) didReachBottomBounds;
- (BOOL) didReachTopBounds;
@end

@implementation KLScrollingColumn
- (BOOL) didReachTopBounds {
    return self.contentOffset.y <= 0.0;
}
- (BOOL) didReachBottomBounds {
    return self.contentOffset.y >= ( self.contentSize.height - self.bounds.size.height);
}
- (void)resetContentOffsetIfNeeded
{
    CGPoint contentOffset  = self.contentOffset;
    //check the top condition
    //check if the scroll view reached its top.. if so.. move it to center.. remember center is the start of the data repeating for 2nd time.
    if ([self didReachTopBounds] || [self didReachBottomBounds]) {
        isResettingContent = YES;
        if([self didReachTopBounds])
            contentOffset.y = self.contentSize.height/3.0f;
        else if([self didReachBottomBounds] )//scrollview content offset reached bottom minus the height of the tableview
            //this scenario is same as the data repeating for 2nd time minus the height of the table view
            contentOffset.y = self.contentSize.height/3.0f - self.bounds.size.height;
        [self setContentOffset: contentOffset];
        isResettingContent = NO;
    }
}

//The heart of this app.
//this function iterates through all visible cells and lay them in a circular shape
#pragma mark Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    mTotalCellsVisible = self.frame.size.height / self.rowHeight;
    [self resetContentOffsetIfNeeded];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setShowsVerticalScrollIndicator:NO];
}

#pragma mark - Touch methods
-(void) setContentOffset:(CGPoint)contentOffset {
    
    if ([self.columnDelegate respondsToSelector:@selector(willUpdateContentOffsetForColumn:)] && !isResettingContent) {
        [self.columnDelegate willUpdateContentOffsetForColumn:self];
    }
    if (!isResettingContent) {
        self.offsetDelta = contentOffset.y - self.contentOffset.y;
    }
    [super setContentOffset: contentOffset];
    if ([self.columnDelegate respondsToSelector:@selector(didUpdateContentOffsetForColumn:)] && !isResettingContent) {
        [self.columnDelegate didUpdateContentOffsetForColumn:self];
    }
}
@end

@implementation KLImageCell

-(void) willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    // On iOS 5 willMoveToSuperview method always gets called, so by checking existence of self.image ,
    // we prevent imageView initialization of reused cells otherwise we face with low performance while scrolling
    if (self.image == nil) {
        self.backgroundColor = [UIColor clearColor];
        self.image = [[UIImageView alloc] initWithFrame: CGRectMake( kDefaultCellImageEdgeInset.left,
                                                                    kDefaultCellImageEdgeInset.top,
                                                                    self.frame.size.width - (kDefaultCellImageEdgeInset.left + kDefaultCellImageEdgeInset.right),
                                                                    self.frame.size.height - (kDefaultCellImageEdgeInset.top + kDefaultCellImageEdgeInset.bottom))];
        [self.image.layer setBorderWidth: 1.0];
        [self.image.layer setBorderColor: [UIColor colorWithRed: 1
                                                          green: 1
                                                           blue: 1
                                                          alpha: 0.4].CGColor];
        [self.image.layer setCornerRadius:6.0];
        
        [self.image setClipsToBounds:YES];
        
        [self addSubview: self.image];
        
        CGFloat labelHeight = 20;
        
        self.label = [[UILabel alloc] initWithFrame: CGRectMake(self.image.frame.origin.x,
                                                                self.image.frame.size.height - labelHeight*2,
                                                                self.image.frame.size.width,
                                                                labelHeight)];
        
        [self.label setBackgroundColor:[UIColor clearColor]];
        [self.label setTextColor:[UIColor whiteColor]];
        [self.label setTextAlignment:NSTextAlignmentCenter];
        [self.label setFont:[UIFont systemFontOfSize: 15]];
        [self.image addSubview:self.label];
        
        self.subLabel = [[UILabel alloc] initWithFrame: CGRectMake(self.image.frame.origin.x,
                                                                   self.image.frame.size.height - labelHeight,
                                                                   self.image.frame.size.width,
                                                                   labelHeight)];
        
        [self.subLabel setBackgroundColor:[UIColor clearColor]];
        [self.subLabel setTextColor:[UIColor whiteColor]];
        [self.subLabel setTextAlignment:NSTextAlignmentCenter];
        [self.subLabel setFont:[UIFont boldSystemFontOfSize: 15]];
        [self.image addSubview:self.subLabel];
        
        [self.layer setShouldRasterize:YES];
        [self.layer setRasterizationScale: [UIScreen mainScreen].scale];
    }
}

@end

NSString const *kColumnObjectKey = @"columnKey";
@implementation NSIndexPath (Column)

+ (NSIndexPath *)indexPathForRow:(NSInteger) row
                       inSection:(NSInteger) section
                        inColumn:(NSInteger) column {
    NSIndexPath* index = [NSIndexPath indexPathForRow:row inSection:section];
    objc_setAssociatedObject(index, &kColumnObjectKey, @(column), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    return index;
}
-(NSInteger) column {
    id object = objc_getAssociatedObject(self, &kColumnObjectKey);
    return [object integerValue];
}

@end