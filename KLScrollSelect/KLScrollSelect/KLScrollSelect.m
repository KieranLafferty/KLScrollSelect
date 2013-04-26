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
@end

@implementation KLScrollSelect
-(void) layoutSubviews {
    [super layoutSubviews];
    [self populateColumns];
    [self setAnimatedColumnAtIndex:0];
}
-(void) setScrollRate:(CGFloat)scrollRate {
    _scrollRate = scrollRate;
    for (KLScrollingColumn* column in self.columns) {
        [column setScrollRate:scrollRate];
    }
}
-(NSInteger) indexOfColumn:(KLScrollingColumn*) column {
    return [self.columns indexOfObject: column];
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
        [column setColumnDelegate:self];
        [column setRowHeight:150.0];
        [column setSeparatorStyle: UITableViewCellSeparatorStyleNone];
        [column setBackgroundColor:[UIColor clearColor]];
        [columns addObject: column];
        
        if (![[self subviews] containsObject: column]) {
            [self addSubview:column];
        }
    }
    self.columns = columns;
    [self setScrollRate: [self scrollRateForScrollSelect:self]];

}
-(NSIndexPath*) translatedIndexPath: (NSIndexPath*) indexPath forTotalRows:(NSInteger) totalRows{
    return [NSIndexPath indexPathForRow: indexPath.row % totalRows
                              inSection: indexPath.section];
}
-(void) setAnimatedColumnAtIndex:(NSInteger) index {
    for (KLScrollingColumn* column in self.columns) {
        NSInteger currentindex = [self indexOfColumn:column];
        [column setShouldAnimate: currentindex == index];
    }
}
#pragma Datasource implementation
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
- (CGFloat)scrollRateForScrollSelect:(KLScrollSelect *)scrollSelect {
    if ([self.dataSource respondsToSelector:@selector(scrollRateForScrollSelect:)]) {
        return [self.dataSource scrollRateForScrollSelect:self];
    }
    else return 10.0;
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
#pragma  UITableViewDelegate implementation
- (void)column:(KLScrollingColumn *)column didSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger columnIndex = [self indexOfColumn:column];
    NSIndexPath* translatedIndex = TRANSLATED_INDEX_PATH(indexPath, [self scrollSelect: self
                                                           numberOfRowsInColumnAtIndex: columnIndex]);
    if ([self.delegate respondsToSelector:@selector(scrollSelect:didSelectCellAtIndexPath:)]) {
        [self.delegate scrollSelect:self didSelectCellAtIndexPath:[NSIndexPath indexPathForRow: translatedIndex.row
                                                                                     inSection: translatedIndex.section
                                                                                      inColumn: columnIndex]];
    }
    
}
#pragma mark - KLColumnDelegate

-(void) column:(KLScrollingColumn*) column isPanningWithGesture:(UIPanGestureRecognizer*) gesture {
    for (KLScrollingColumn* currentColumn in self.columns) {
        //Animate all other columns
        if (currentColumn != column) {
            CGFloat accelerationFactor = currentColumn.contentSize.height/ column.contentSize.height;
            CGPoint contentOffset = CGPointMake(currentColumn.contentOffset.x, column.contentOffset.y*accelerationFactor);
            [currentColumn.layer removeAllAnimations];
            [currentColumn setContentOffset: contentOffset];
        }
    }
}
@end


@interface KLScrollingColumn()
{
    int mTotalCellsVisible;
    NSInteger _totalRows;
}
- (void)resetContentOffsetIfNeeded;
@end

@implementation KLScrollingColumn



- (void)resetContentOffsetIfNeeded
{
    
    NSArray *indexpaths = [self indexPathsForVisibleRows];
    int totalVisibleCells =[indexpaths count];
    if( mTotalCellsVisible > totalVisibleCells )
    {
        //we dont have enough content to generate scroll
        return;
    }
    CGPoint contentOffset  = self.contentOffset;
    
    //check the top condition
    //check if the scroll view reached its top.. if so.. move it to center.. remember center is the start of the data repeating for 2nd time.
    if( contentOffset.y<=0.0)
    {
        contentOffset.y = self.contentSize.height/3.0f;
    }
    else if( contentOffset.y >= ( self.contentSize.height - self.bounds.size.height) )//scrollview content offset reached bottom minus the height of the tableview
    {
        //this scenario is same as the data repeating for 2nd time minus the height of the table view
        contentOffset.y = self.contentSize.height/3.0f- self.bounds.size.height;
    }
    [self setContentOffset: contentOffset];
}

//The heart of this app.
//this function iterates through all visible cells and lay them in a circular shape
#pragma mark Layout

- (void)layoutSubviews
{
    mTotalCellsVisible = self.frame.size.height / self.rowHeight;
    [self resetContentOffsetIfNeeded];
    [super layoutSubviews];
}
- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setShowsVerticalScrollIndicator:NO];
    
    [self setDelegate: self];
    
    if(newWindow) {
        [self startScrolling];
        [self.panGestureRecognizer addTarget:self action:@selector(gestureDidChange:)];
        [self.pinchGestureRecognizer addTarget:self action:@selector(gestureDidChange:)];
    }
    else {
        [self stopScrolling];
        [self.panGestureRecognizer removeTarget:self action:@selector(gestureDidChange:)];
        [self.pinchGestureRecognizer removeTarget:self action:@selector(gestureDidChange:)];
    }
}

#pragma mark - Touch methods

- (void)gestureDidChange:(UIGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            if([self scrolling]){
                [self stopScrolling];
            }
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            if(![self scrolling] && self.shouldAnimate){
                [self startScrolling];
            }
            break;
        }
        default:
            break;
    }
}
- (void) setScrollRate:(CGFloat)scrollRate {
    _scrollRate = scrollRate;
    [self stopScrolling];
    [self startScrolling];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.columnDelegate respondsToSelector:@selector(column:isPanningWithGesture:)]) {
        [self.columnDelegate column:self
               isPanningWithGesture:self.panGestureRecognizer];
    }
}
- (BOOL)becomeFirstResponder {
    [self stopScrolling];
    return [super becomeFirstResponder];
}
#pragma mark - Public methods
- (void)startScrolling {
    [self stopScrolling];
    self.scrolling = YES;
    CGFloat animationDuration = (0.5f / self.scrollRate);
    self.timer = [NSTimer scheduledTimerWithTimeInterval: animationDuration
                                                  target: self
                                                selector: @selector(updateScroll)
                                                userInfo: nil
                                                 repeats: YES];
}
- (void)stopScrolling {
    [self.timer invalidate];
    self.timer = nil;
    self.scrolling = NO;
}
- (void)updateScroll {
    CGFloat animationDuration = self.timer.timeInterval;
    CGFloat pointChange = self.scrollRate * animationDuration;
    CGPoint newOffset = self.contentOffset;
    newOffset.y = newOffset.y + pointChange;

    if (!(newOffset.y > (self.contentSize.height - self.bounds.size.height)) && self.shouldAnimate) {
        
        [UIView beginAnimations: nil
                        context: nil];
        [UIView setAnimationDuration:animationDuration];
        self.contentOffset = newOffset;
        [UIView commitAnimations];
    }
}
-(void) setShouldAnimate:(BOOL)shouldAnimate {
    _shouldAnimate = shouldAnimate;
    if (self.shouldAnimate) {
        //Start Animation
        [self startScrolling];
    }
    else {
        //Stop Animation
        [self stopScrolling];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.columnDelegate respondsToSelector:@selector(column:didSelectCellAtIndexPath:)]) {
        [self.columnDelegate column:self didSelectCellAtIndexPath:indexPath];
    }
}
@end

@implementation KLImageCell

-(void) willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
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