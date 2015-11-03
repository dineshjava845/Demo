//
//  NetworkBO.h
//  Buzztang
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void(^BasicThumbnailHandler)(NSError* error, id info);

@interface NetworkBO : NSObject

@property (nonatomic, strong) NSString *networkId;
@property (nonatomic, strong) NSString *contacts;
@property (nonatomic, strong) NSString *descriptions;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *members;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *contactOptions;
@property (nonatomic, strong) NSArray *networkOptions;

-(void)downloadthumbnailFromItemCompletionHandler:(BasicThumbnailHandler)handler;
- (void)downloadThumbnailImage:(id)element completionblock:(BasicThumbnailHandler)handler;
-(UIImage *)imageThumbnail;

@end
