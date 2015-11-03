//
//  NetworkBO.m
//  Buzztang
//

//

#import "NetworkBO.h"
#import "ImageStore.h"
#define ThumbnailImage @"Thumbnail"

@implementation NetworkBO

-(UIImage *)imageThumbnail
{
    //5
    if(![self.imageUrl length])
    {
        return nil;
    }
    else
    {
        NSString *strName  = [self.name stringByReplacingOccurrencesOfString:@" " withString:@""];
        if([ImageStore isDataExistsWithNameInDirctory:[NSString stringWithFormat:@"%@%@",self.networkId,strName] withFolderName:ThumbnailImage])
        {
            UIImage *imgRef = nil;
            {
                NSData *dataRef = nil;
                
                dataRef = [ImageStore returnMediaDataWithName:[NSString stringWithFormat:@"%@%@",self.networkId,strName] withFolderName:ThumbnailImage];
                
                if (![[NSThread currentThread] isCancelled])
                {
                    if(dataRef)
                    {
                        imgRef = [UIImage imageWithData:dataRef];
                        dataRef = nil;
                    }
                }
            }
            return imgRef;
        }
        else
        {
        }
        return nil;
    }
}

- (void)downloadThumbnailImage:(id)element completionblock:(BasicThumbnailHandler)handler
{
    if ([[NSThread currentThread] isCancelled])
    {
        return;
    }
    
    NSString *mediaName = [NSString stringWithFormat:@"%@",self.imageUrl];
    NSString *docuPath = [ImageStore getDirectoryPathWthFolderName:ThumbnailImage];
    mediaName = [mediaName stringByReplacingOccurrencesOfString:@"/" withString:@""];
    
    NSString *filePath  = [docuPath stringByAppendingPathComponent:mediaName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == YES)
    {
        return;
    }
    
    
    
    id __block mediaData;
    
    
    [self downloadthumbnailFromItemCompletionHandler:^(NSError *error, id info)
     {
         mediaData = info;
         info = nil;
         
         if ([[NSThread currentThread] isCancelled])
         {
             return;
         }
         
         //if ([mediaData isKindOfClass:[NSData class]])
         {
             
             
             if(error!=nil)
             {
                 
                 if ([[NSThread currentThread] isCancelled])
                     return;
                 
             }
             else if (mediaData && [mediaData isKindOfClass:[NSData class]] )
             {
                 if ([[NSThread currentThread] isCancelled])
                 {
                     return;
                 }
                 
                 @autoreleasepool {
                     NSData *data = (NSData *)mediaData;
                     if (data && data.length) {
                         UIImage *tempImg = [UIImage imageWithData:data];
                         
                         // UIImage *tempImage =  [APP_CONSTANTS squareImageWithImage:tempImg scaledToSize:CGSizeMake(80, 80)];
                         
                         
                         if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO)
                         {
                             NSString *strName  = [self.name stringByReplacingOccurrencesOfString:@" " withString:@""];

                             [ImageStore saveMediaWithData:UIImageJPEGRepresentation(tempImg, 1.0) withImageName:[NSString stringWithFormat:@"%@%@",self.networkId,strName] withFolderName:ThumbnailImage];
                             
                         }
                     }
                 }
                 
             }
             
             handler(nil, nil);
         }
         
     }];
    
}
-(void)downloadthumbnailFromItemCompletionHandler:(BasicThumbnailHandler)handler
{
    if ([[NSThread currentThread] isCancelled])
    {
        return;
    }
    NSMutableURLRequest *request;
    NSHTTPURLResponse *__block responseGlobal= NULL;
    NSError *__block requestError = NULL;
    
    
    NSURL *url = [NSURL URLWithString:self.imageUrl];
    request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    
    NSOperationQueue *__block queAsync = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queAsync completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        queAsync = nil;
        responseGlobal = (NSHTTPURLResponse *)response;
        
        if ([[NSThread currentThread] isCancelled])
        {
            return;
        }
        if(connectionError)
        {
            handler(connectionError,nil);
        }
        else
        {
            if (data == nil|| data.length==0) {
                
                handler(requestError,nil);
                return;
            }
            
            if ([responseGlobal statusCode]<300 && [data length]>0)
            {
                handler(nil, data);
            }
            else if ([responseGlobal statusCode]==404)
            {
                
                handler(nil, data);
            }
            else
            {
                if (connectionError!=NULL)
                {
                    NSLog(@"error: %@", [requestError description]);
                }
                
                handler(connectionError,nil);
            }
        }
    }];
}



@end
