//
//  SlidingGameViewController.h
//  SlidingTilePuzzle
//
//  Created by Emma Steimann on 2/25/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlidingGameViewController : UIViewController <UIGestureRecognizerDelegate>
- (instancetype)initWithFrame:(CGRect)frame andSize:(NSInteger)gameBoardSize;
@end
