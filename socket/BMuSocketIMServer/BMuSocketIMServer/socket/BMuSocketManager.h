//
//  BMuSocketManager.h
//  BMuSocketIMServer
//
//  Created by Jashion on 2023/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMuSocketManager : NSObject

- (void)sendMsg: (NSString *)msg;
- (void)close;

@end

NS_ASSUME_NONNULL_END
