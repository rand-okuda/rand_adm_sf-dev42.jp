public class ikemen_Helper {
    
    public static void WriteImageUrl(ikemen__c ikemen){
        System.debug('@@@ WriteImageUrl()');
        
        ikemen.ImageURL__c = EinsteinVision_Admin.getImageUrlFromCDLink(ikemen.Id);
        
    }

}