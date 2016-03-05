//
//  SlidingTileViewController.m
//  SlidingTilePuzzle
//
//  Created by Emma Steimann on 2/25/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "SlidingTileViewController.h"

@interface SlidingTileViewController ()
@property (nonatomic, assign) CGRect viewFrame;
@end

@implementation SlidingTileViewController

- (instancetype)initWithFrame:(CGRect)frame andNumber:(NSNumber *)number {
  if (self == [super init]) {
    self.value = number;
    self.viewFrame = frame;
    
  }
  return self;
}

-(void)viewDidLoad {
  self.view.frame = self.viewFrame;
  
  
  self.view.tag = [self.value integerValue];
  
  [self.view setBackgroundColor:[UIColor whiteColor]];
  [self.view.layer setBorderColor:[UIColor blackColor].CGColor];
  [self.view.layer setBorderWidth:2];
  
  UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
  if ([self.value isEqual: @0]) {
    numberLabel.text = @"";
  } else {
    numberLabel.text = [NSString stringWithFormat:@"%@", self.value];
  }
  numberLabel.font = [UIFont systemFontOfSize:20.0f];
  numberLabel.textColor = [UIColor blackColor];
  [numberLabel sizeToFit];
  [numberLabel setCenter:CGPointMake((self.view.frame.size.width / 2), (self.view.frame.size.height / 2))];
  [self.view addSubview:numberLabel];
  
}

@end
