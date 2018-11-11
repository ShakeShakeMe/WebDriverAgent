//
//  UIDevice+ScreenResolution.h
//  WebDriverAgentLib
//
//  Created by dl on 2018/11/11.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (ScreenResolution)

- (NSString *) deviceType;
- (CGSize) screenResolution;
- (BOOL) isCurrentDeviceSimulator;

@end

NS_ASSUME_NONNULL_END
