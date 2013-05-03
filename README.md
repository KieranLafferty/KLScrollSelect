<img src="https://raw.github.com/KieranLafferty/KLScrollSelect/master/KLScrollSelectDemo/ScreenShot.png" width="50%"/>

KLScrollSelect
=======

A control that infinitely scrolls up and down at variable speeds inspired by Expedia 3.0 app.

Note: KLScrollSelect is intended for use with portrait orientation on iPhone/iPod Touch.

Requires ARC

*Source is dual licensed. Can be used freely without restriction on FREE apps, PAID apps require a license purchased from https://www.cocoacontrols.com/controls/klscrollselect*

[Check out the Demo](http://www.youtube.com/watch?v=uorJfwpTzoI) *Excuse the graphics glitches and lag due to my slow computer.*
## Scroll Rate ##
The scroll rate property of each column is measured in [pixel/second] and can be set individually for each column. This value should be set via the KLScrollViewDataSource implementation. Defaults to 10 pixel/second if datasource not implemented


## Installation ##

	1. Drag the KLScrollSelect.xcodeproj to your existing project
	2. Under Build Phases on your project's Xcode Project file add 'KLScrollSelect(KLScrollSelect)' to your Target Dependancies
	3. Under Build on your Xcode Project file add 'libKLScrollSelect' & QuartzCore.framework under Link Binary With Libraries
	4. Include #import <KLScrollSelect/KLScrollSelect.h> in any file you wish to use
	
	
Via CocoaPods
Add the following line to your podfile

	pod 'KLScrollSelect', :git=>'git://github.com/KieranLafferty/KLScrollSelect.git'
	
## Usage ##

Import the header file and declare your controller to subclass KLScrollViewController

	#import <KLScrollSelect/KLScrollSelect.h>
	@interface KLViewController : KLScrollSelectViewController


OR, Import the header file and declare your controller to conform to KLScrollSelectDelegate and KLScrollSelectDataSrouce

	#import <KLScrollSelect/KLScrollSelect.h>
	@interface KLViewController : UIViewController <KLScrollSelectDataSource, KLScrollSelectDelegate>

Implement the required methods for KLScrollSelectDataSource

	@required
	- (NSInteger)scrollSelect:(KLScrollSelect *)scrollSelect numberOfRowsInColumnAtIndex:(NSInteger)index;
	- (UITableViewCell*) scrollSelect:(KLScrollSelect*) scrollSelect cellForRowAtIndexPath:(NSIndexPath *)indexPath;
	@optional
	- (CGFloat) scrollSelect: (KLScrollSelect*) scrollSelect heightForColumnAtIndex: (NSInteger) index;
	- (CGFloat) scrollRateForColumnAtIndex: (NSInteger) index;
	- (NSInteger)scrollSelect:(KLScrollSelect *)scrollSelect numberOfSectionsInColumnAtIndex:(NSInteger)index;
	// Default is 1 if not implemented
	- (NSInteger)numberOfColumnsInScrollSelect:(KLScrollSelectViewController *)scrollSelect;
	
Implement the optional methods for KLScrollSelectDelegate

	@optional
	- (void)scrollSelect:(KLScrollSelect *)tableView didSelectCellAtIndexPath:(NSIndexPath *)indexPath;

NSIndexPath Add-on
Implements a category which adds *column* to NSIndexPath. This allows NSIndexPath to identify which cell in which column as follows:
	 
	column: Identifies to column in the KLScrollView
	section: Identifies the section (As one would expect with UITableView column on NSIndexPath)
	row: Identifies the row (As one would expect with UITableView row on NSIndexPath)

## Contact ##

* [@kieran_lafferty](https://twitter.com/kieran_lafferty) on Twitter
* [@kieranlafferty](https://github.com/kieranlafferty) on Github
* <a href="mailTo:kieran.lafferty@gmail.com">kieran.lafferty [at] gmail [dot] com</a>

## License ##

Copyright 2013 Kieran Lafferty

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.