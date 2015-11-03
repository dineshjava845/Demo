//
//  ContactBO.h
//  Buzztang
//

//

#import <Foundation/Foundation.h>

@interface ContactBO : NSObject




@property (nonatomic, strong) NSString *email_id;
@property (nonatomic, strong) NSString *contact_id;

@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *last_name;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *outlookID;
@property (nonatomic, strong) NSString *stockSymbol;
@property (nonatomic, strong) NSArray *facebookIds;
@property (nonatomic, strong) NSArray *twitterIds;
@property (nonatomic, strong) NSArray *RSSfeeds;
@property (nonatomic, strong) NSArray *linkedInUrls;

@end
