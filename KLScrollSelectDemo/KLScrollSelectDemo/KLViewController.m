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

@end

#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
@implementation KLViewController
-(void) viewDidLoad {
    [super viewDidLoad];
    
    [self.scrollSelect setBackgroundColor:[UIColor clearColor]];
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
- (UITableViewCell*) scrollSelect:(KLScrollSelect*) scrollSelect cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KLScrollingColumn* column = [[scrollSelect columns] objectAtIndex: indexPath.column];
    KLImageCell* cell;
    
    //registerClass only works on iOS 6 so if the app runs on iOS 5 we shouldn't use this method.
    //On iOS 5 we only initialize a new KLImageCell if the cell is nil
    if (IOS_VERSION >= 6.0) {
        [column registerClass:[KLImageCell class] forCellReuseIdentifier:@"Cell" ];
        cell = [column dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
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
    return cell;
}
- (void)scrollSelect:(KLScrollSelect *)tableView didSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected cell at index %d, %d, %d", indexPath.column, indexPath.section, indexPath.row);
}
- (CGFloat) scrollSelect: (KLScrollSelect*) scrollSelect heightForColumnAtIndex: (NSInteger) index {
    return 150;
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

