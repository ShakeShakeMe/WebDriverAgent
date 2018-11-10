//
//  CustomSnapshotService.h
//  WebDriverAgentLib
//
//  Created by dl on 2018/11/10.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomSnapshotService : NSObject
+ (instancetype) sharedInstance;
- (void) startServer;
@end

NS_ASSUME_NONNULL_END
