<img src="https://raw.github.com/KieranLafferty/KLScrollSelect/master/KLScrollSelectDemo/ScreenShot.png" width="50%"/>

KLScrollSelect
=======

A control that infinitely scrolls up and down at variable speeds inspired by Expedia 3.0 app

Note: KLScrollSelect is intended for use with portrait orientation on iPhone/iPod Touch.

[Check out the Demo](http://www.youtube.com/watch?v=uorJfwpTzoI) *Excuse the graphics glitches and lag due to my slow computer.*
## Scroll Rate ##
There are two scroll rates that affect the control
	
	1. The comparative scroll rate. This determines how quickly column 1 will scroll with respect to column 2. This is determined by the content height of each column. 
	If column 1 has a content height of 500 and column 2 has a content height of 250, then column 2 will scroll twice as fast as column 1.
	
	2. The overall scroll rate. This speeds/slows the entire table and applies to all of the columns. This can be set by adjsuting the scrollRate property on the KLScrollView instantiation.



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


OR, Import the header file and declare your controller to conform to KLScrollSelectDelegate and KLScrollSelectDelegate

	#import <KLScrollSelect/KLScrollSelect.h>
	@interface KLViewController : UIViewController <KLScrollSelectDataSource, KLScrollSelectDelegate>

Implement the required methods for KLScrollSelectDataSource

	@required
	- (NSInteger)scrollSelect:(KLScrollSelect *)scrollSelect numberOfRowsInColumnAtIndex:(NSInteger)index;
	- (UITableViewCell*) scrollSelect:(KLScrollSelect*) scrollSelect cellForRowAtIndexPath:(NSIndexPath *)indexPath;
	@optional
	- (CGFloat)scrollRateForScrollSelect:(KLScrollSelect *)scrollSelect;
	- (NSInteger)scrollSelect:(KLScrollSelect *)scrollSelect numberOfSectionsInColumnAtIndex:(NSInteger)index;
	// Default is 1 if not implemented
	- (NSInteger)numberOfColumnsInScrollSelect:(KLScrollSelectViewController *)scrollSelect;
	
Implement the optional methods for KLScrollSelectDelegate

	- (void)scrollSelect:(KLScrollSelect *)tableView didSelectCellAtIndexPath:(NSIndexPath *)indexPath;
	


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