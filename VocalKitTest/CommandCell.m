//
//  CommandCell.m
//  VocalKitTest
//
//  Created by lucy on 5/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CommandCell.h"


@implementation CommandCell

@synthesize icon;
@synthesize label;

- (void)dealloc {
  self.icon = nil;
  self.label = nil;
  [super dealloc];
}

@end
