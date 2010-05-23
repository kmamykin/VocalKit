//
//  ServerRequest.h
//  VocalKitTest
//
//  Created by lucy on 5/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ServerRequest : NSObject {
  NSMutableData *receivedData;
  id delegate;
  SEL callback;
  SEL errorCallback;
    
  BOOL isPost;
  NSString *requestBody;
}

@property(nonatomic, retain) NSMutableData *receivedData;
@property(nonatomic, assign) id delegate;
@property(nonatomic) SEL callback;
@property(nonatomic) SEL errorCallback;
  
+ (NSString *)encode:(NSString *)input;

- (void)sendRequest:(NSURL *)url;
- (void)post:(NSString *)query delegate:(id)requestDelegate
  requestSelector:(SEL)requestSelector errorSelector:(SEL)errorSelector;
- (void)list:(NSString *)query delegate:(id)requestDelegate
  requestSelector:(SEL)requestSelector errorSelector:(SEL)errorSelector;
- (void)add:(NSString *)query delegate:(id)requestDelegate
  requestSelector:(SEL)requestSelector errorSelector:(SEL)errorSelector;
- (void)remove:(NSString *)query delegate:(id)requestDelegate
  requestSelector:(SEL)requestSelector errorSelector:(SEL)errorSelector;

@end
