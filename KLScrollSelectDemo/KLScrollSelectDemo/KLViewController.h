//
//  KLViewController.h
//  KLScrollSelectDemo
//
//  Created by Kieran Lafferty on 2013-04-03.
//  Copyright (c) 2013 KieranLafferty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KLScrollSelect/KLScrollSelect.h>
@interface KLViewController : UIViewController <KLScrollSelectDataSource, KLScrollSelectDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;
@property (weak, nonatomic) IBOutlet KLScrollSelect *scrollSelect;
@property (nonatomic, strong) NSArray* leftColumnData;
@property (nonatomic, strong) NSArray* rightColumnData;
- (IBAction)didSelectTweetButton:(id)sender;
- (IBAction)didSelectFacebookButton:(id)sender;


@end
