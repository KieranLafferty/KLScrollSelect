//
//  KLViewController.m
//  KLScrollSelectDemo
//
//  Created by Kieran Lafferty on 2013-04-03.
//  Copyright (c) 2013 KieranLafferty. All rights reserved.
//

#import "KLViewController.h"
#import <Social/Social.h>
@interface KLViewController ()
{
    CGFloat leftColumnWidth;
    BOOL showingBothColumns;
}
@end

#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
@implementation KLViewController
-(void) viewDidLoad {
    [super viewDidLoad];
    leftColumnWidth = self.view.frame.size.width / 2;
    showingBothColumns = YES;
    self.scrollSelect = [[KLScrollSelect alloc] initWithFrame: CGRectMake(0, 150, 320, 438)];
    [self.scrollSelect setDataSource: self];
    [self.scrollSelect setDelegate: self];
    [self.scrollSelect start];
    
    [self.scrollSelect setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview: self.scrollSelect];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"expda-launch-linen.png"]]];
    
    //Configure data source arrays
    NSString* leftPlistPath = [[NSBundle mainBundle] pathForResource:@"LeftCityList"
                                                              ofType:@"plist"];
    self.leftColumnData = [NSArray arrayWithContentsOfFile: leftPlistPath];
    
    
    NSString* rightPlistPath = [[NSBundle mainBundle] pathForResource:@"RightCityList"
                                                               ofType:@"plist"];
    self.rightColumnData = [NSArray arrayWithContentsOfFile: rightPlistPath];
    
    
    //Configure buttons
    [self.tweetButton setBackgroundImage:[self.tweetButton.currentBackgroundImage stretchableImageWithLeftCapWidth:9
                                                                                                      topCapHeight:45]forState: UIControlStateNormal];
    [self.facebookButton setBackgroundImage:[self.facebookButton.currentBackgroundImage stretchableImageWithLeftCapWidth:9
                                                                                                            topCapHeight:45]forState: UIControlStateNormal];
    [self.titleLabel setFont:[UIFont fontWithName:@"Geometr415 Md BT" size:25]];
}
- (CGFloat)scrollRateForColumnAtIndex: (NSInteger) index {
    return 15 + index * 15;
}
-(NSInteger) numberOfColumnsInScrollSelect:(KLScrollSelect *)scrollSelect {
    return 2;
}
-(NSInteger) scrollSelect:(KLScrollSelect *)scrollSelect numberOfRowsInColumnAtIndex:(NSInteger)index {
    if (index == 0) {
        //Left column
        return self.leftColumnData.count;
    }
    //Right Column
    else return self.rightColumnData.count;
}
- (UITableViewCell*) scrollSelect:(KLScrollSelect*) scrollSelect cellForRowAtIndexPath:(KLIndexPath *)indexPath {
    KLScrollingColumn* column = [[scrollSelect columns] objectAtIndex: indexPath.column];
    KLImageCell* cell;
    
    //registerClass only works on iOS 6 so if the app runs on iOS 5 we shouldn't use this method.
    //On iOS 5 we only initialize a new KLImageCell if the cell is nil
    if (IOS_VERSION >= 6.0) {
        [column registerClass:[KLImageCell class] forCellReuseIdentifier:@"Cell" ];
        cell = [column dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:[indexPath innerIndexPath]];
    } else {
        cell = [column dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            cell = [[KLImageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        }
    }
    
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    
    NSDictionary* dictForCell = indexPath.column == 0? [self.leftColumnData objectAtIndex:indexPath.row] : [self.rightColumnData objectAtIndex:indexPath.row];
    
    [cell.image setImage:[UIImage imageNamed: [dictForCell objectForKey:@"image"]]];
    //    [cell.label setText:@"Fly to"];
    //    [cell.subLabel setText: [dictForCell objectForKey:@"title"]];
    [cell layoutSubviews];
    return cell;
}
- (void)scrollSelect:(KLScrollSelect *)tableView didSelectCellAtIndexPath:(KLIndexPath *)indexPath {
    NSLog(@"Selected cell at index %ld, %ld, %ld", (long)indexPath.column, (long)indexPath.section, (long)indexPath.row);
}
- (CGFloat) scrollSelect: (KLScrollSelect*) scrollSelect heightForColumnAtIndex: (NSInteger) index {
    return 150;
}

-(CGFloat)columnWidthAtIndex:(NSInteger)index
{
    if (index)
        return self.view.frame.size.width - leftColumnWidth;
    return leftColumnWidth;
}

- (IBAction)didSelectTweetButton:(id)sender {
    SLComposeViewController* shareViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [shareViewController addURL:[NSURL URLWithString:@"https://github.com/KieranLafferty/KLScrollSelect"]];
    [shareViewController setInitialText:@"I'm planning on using this UI control in my next iOS app!"];
    
    
    if ([SLComposeViewController isAvailableForServiceType:shareViewController.serviceType]) {
        [self presentViewController:shareViewController
                           animated:YES
                         completion: nil];
    }
}

- (IBAction)didSelectFacebookButton:(id)sender {
    SLComposeViewController* shareViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [shareViewController addURL:[NSURL URLWithString:@"https://github.com/KieranLafferty/KLScrollSelect"]];
    [shareViewController setInitialText:@"I'm planning on using this UI control in my next iOS app!"];
    
    
    if ([SLComposeViewController isAvailableForServiceType:shareViewController.serviceType]) {
        [self presentViewController:shareViewController
                           animated:YES
                         completion: nil];
    }
    
}
@end

