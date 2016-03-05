//
//  SlidingTileViewController.h
//  SlidingTilePuzzle
//
//  Created by Emma Steimann on 2/25/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlidingTileViewController : UIViewController
- (instancetype)initWithFrame:(CGRect)frame andNumber:(NSNumber *)number;
@property (nonatomic, strong) NSNumber *value;
@end
