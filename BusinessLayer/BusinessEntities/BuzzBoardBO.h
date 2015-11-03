//
//  BuzzBoardBO.h
//  Buzztang
//

//

#import <Foundation/Foundation.h>

@interface BuzzBoardBO : NSObject


@property (nonatomic, strong)NSString *networksFromLastLogin;
@property (nonatomic, strong)NSString *totalNetwork;
@property (nonatomic, strong)NSString *userNetworks;
@property (nonatomic, strong)NSString *watchingNetworks;
@property (nonatomic, strong)NSString *belongsPrivateNet;
@property (nonatomic, strong)NSString *belongsPublicNet;
@property (nonatomic, strong)NSString *watchPrivateNet;
@property (nonatomic, strong)NSString *watchPublicNet;
@property (nonatomic , strong) NSMutableArray *arrMostWatchedNet;
@end
