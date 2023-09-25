//
//  BMuSocketManager.h
//  BMuSocketIM
//
//  Created by Jashion on 2023/9/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMuSocketManager : NSObject

- (void)connect;
- (void)disConnect;
- (void)sendMsg: (NSString *)msg;

@end

NS_ASSUME_NONNULL_END
