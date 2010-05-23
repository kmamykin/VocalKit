//
//  GroceryListViewController.h
//  VocalKitTest
//
//  Created by lucy on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GroceryListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
  IBOutlet UIBarItem  *addButton;
  IBOutlet UITableView *table;
  
  NSMutableArray *list;
}

-(IBAction) addPressed:(id)sender;

@end
