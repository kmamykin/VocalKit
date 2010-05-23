//
//  GroceryListViewController.m
//  VocalKitTest
//
//  Created by lucy on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ServerRequest.h"
#import "SBJSON.h"
#import "GroceryListViewController.h"


@implementation GroceryListViewController

- (IBAction) addPressed:(id)sender {
  [self dismissModalViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
      list = [[NSMutableArray alloc] init];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  table.delegate = self;
    table.dataSource = self;
    [table reloadData];

  
  ServerRequest *request = [[ServerRequest alloc] init];
  [request list:@"" delegate:self
  requestSelector:@selector(listCallback:)
  errorSelector:@selector(errorCallback:)];
  [request release];
  
  [super viewDidLoad];
}

- (void)listCallback:(NSData *)data {
	NSString *response = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	SBJSON *jsonParser = [SBJSON new];
	id result = [jsonParser objectWithString:response error:NULL];
  NSLog(@"response: %@", result);
	[response release];
  
  
  [list removeAllObjects];
	for (id r in result) {
    NSString *item = [[r valueForKey:@"shopping_item"] valueForKey:@"name"];
    NSLog(@"r %@", item);
    [list addObject:item];
	}
	[table reloadData]; 
}

- (void)errorCallback:(NSString *)message {
  NSLog(@"errorCallback %@", message);
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *ident = @"ItemCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease]; 
  
  }
  cell.textLabel.text = [list objectAtIndex:indexPath.row];
   
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  tableView.allowsSelection = NO;
  return [list count];
}




@end
