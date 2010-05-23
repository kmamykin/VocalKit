//
//  CommandCell.h
//  VocalKitTest
//
//  Created by lucy on 5/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CommandCell : UITableViewCell {
  IBOutlet UIImageView *icon;
  IBOutlet UILabel *label;
}

@property(nonatomic, retain) UIImageView *icon;
@property(nonatomic, retain) UILabel *label;


@end
