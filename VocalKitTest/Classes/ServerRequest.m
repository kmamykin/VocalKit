//
//  ServerRequest.m
//  VocalKitTest
//
//  Created by lucy on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ServerRequest.h"


@implementation ServerRequest

@synthesize receivedData;
@synthesize delegate;
@synthesize callback;
@synthesize errorCallback;

- (void)add:(NSString *)message delegate:(id)requestDelegate
  requestSelector:(SEL)requestSelector errorSelector:(SEL)errorSelector {
  self.delegate = requestDelegate;
  self.callback = requestSelector;
  self.errorCallback = errorSelector;
  
  NSString *urlStr = @"http://home-assistant.heroku.com/recognized";
  NSURL *url = [NSURL URLWithString:urlStr];
  requestBody = [NSString stringWithFormat:@"command=add&message=%@", [ServerRequest encode:message]];
  isPost = YES;
  [self sendRequest:url];    
}

- (void)remove:(NSString *)message delegate:(id)requestDelegate
  requestSelector:(SEL)requestSelector errorSelector:(SEL)errorSelector {
  self.delegate = requestDelegate;
  self.callback = requestSelector;
  self.errorCallback = errorSelector;
  
  NSString *urlStr = @"http://home-assistant.heroku.com/recognized";
  NSURL *url = [NSURL URLWithString:urlStr];
  requestBody = [NSString stringWithFormat:@"command=delete&message=%@", [ServerRequest encode:message]];
  isPost = YES;
  [self sendRequest:url];    
}

- (void)post:(NSString *)query delegate:(id)requestDelegate
  requestSelector:(SEL)requestSelector errorSelector:(SEL)errorSelector {
  self.delegate = requestDelegate;
  self.callback = requestSelector;
  self.errorCallback = errorSelector;
  
  NSString *urlStr = [NSString stringWithFormat:@"http://srgroceries.heroku.com/recognized?name=%@",
                      [ServerRequest encode:query]];
  NSURL *url = [NSURL URLWithString:urlStr];
  isPost = FALSE;
  [self sendRequest:url];  
}

- (void)list:(NSString *)query delegate:(id)requestDelegate
  requestSelector:(SEL)requestSelector errorSelector:(SEL)errorSelector {
  self.delegate = requestDelegate;
  self.callback = requestSelector;
  self.errorCallback = errorSelector;
  
  NSString *urlStr = [NSString stringWithFormat:@"http://srgroceries.heroku.com/shopping_items.json",
                      [ServerRequest encode:query]];
  NSURL *url = [NSURL URLWithString:urlStr];
  isPost = FALSE;
  [self sendRequest:url];  
}

- (void)sendRequest:(NSURL *)url {
  NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
  [request setTimeoutInterval:10.0];
  
  if (isPost) {
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[requestBody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    [request setValue:[NSString stringWithFormat:@"%d", [requestBody length]] forHTTPHeaderField:@"Content-Length"];
    NSLog(@"requestBody %@", requestBody);
  }
  
  NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
  if (connection) {
    self.receivedData = [NSMutableData data];
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data  {
  [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  [connection release];
  NSString *errorMessage = @"Connection failure";
  [delegate performSelector:errorCallback withObject:errorMessage];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  [connection release];
  [delegate performSelector:callback withObject:receivedData];
}

+ (NSString *)encode:(NSString *)input {
	NSString *encodedUrl =
  (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                      NULL,
                                                      (CFStringRef)input,
                                                      NULL,
                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                      kCFStringEncodingUTF8);
	[encodedUrl autorelease];
	return encodedUrl;
}

- (void)dealloc {
  self.delegate = nil;
  self.receivedData = nil;
  [super dealloc];
}

@end
