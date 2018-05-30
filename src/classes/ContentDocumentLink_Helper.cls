public class ContentDocumentLink_Helper {
    
    public static void CreateIkemenCDL(List<ContentDocumentLink> targetCDLList) {
        System.debug('@@@ CreateIkemenCDL()');
        
        Set<Id> LinkedEntityIdSet = new Set<Id>();
        for ( Integer i=0; i<targetCDLList.size(); i++ ){
            LinkedEntityIdSet.add(targetCDLList[i].LinkedEntityId);
            System.debug('*** targetCDLList[i] ' + targetCDLList[i]);
        }
        List<ikemen__c> existIkemenList = [SELECT Id FROM ikemen__c WHERE Id IN :LinkedEntityIdSet];
        
        if(!existIkemenList.isEmpty()){
            
            String datasetName = 'kao';
            for(ikemen__c ikemen :existIkemenList){
                System.debug('*** ikemen ' + ikemen); 
                ikemen_Helper.getImagePrediction(ikemen.Id, datasetName);
            }
            
        }else{
                        
            List<ikemen__c> newIkemenList = new List<ikemen__c>();
            for ( Integer i=0; i<targetCDLList.size(); i++ ){
                ikemen__c ikemen = new ikemen__c();
                newIkemenList.add(ikemen);
                System.debug('*** ikemen ' + ikemen); 
            }
            insert newIkemenList;
            
            List<ContentDocumentLink> newCDLList = new List<ContentDocumentLink>();
            for ( Integer i=0; i<targetCDLList.size(); i++ ){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = newIkemenList[i].Id;
                cdl.ContentDocumentId = targetCDLList[i].ContentDocumentId;
                cdl.ShareType = 'I';
                newCDLList.add(cdl);
                System.debug('*** cdl ' + cdl);
            }
            insert newCDLList;
            
        }
        
    }
    
    public static Blob getImageBlobFromCDLink(Id recordId) {
        System.debug('@@@ getImageBlobFromCDLink()');
        List<ContentDocumentLink> cdl = [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId=:recordId];
        List<ContentDocument> cd = [SELECT Id, LatestPublishedVersionId, PublishStatus, Title FROM ContentDocument WHERE Id=:cdl[0].ContentDocumentId];
        List<ContentVersion> cv = [SELECT FirstPublishLocationId, VersionData, Id, Title, IsLatest, CreatedDate FROM ContentVersion WHERE Id=:cd[0].LatestPublishedVersionId AND IsLatest=true ORDER BY CreatedDate DESC];
        if (cv.size()>0) {
            System.debug('*** cv.get(0) ' + cv.get(0));
            return cv.get(0).VersionData;
        }
        return null;
    }
    
    public static String getImageUrlFromCDLink(Id recordId) {
        System.debug('@@@ getImageURLFromCDLink()');
        List<ContentDocumentLink> cdl = [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId=:recordId];
        List<ContentDocument> cd = [SELECT Id, LatestPublishedVersionId, PublishStatus, Title FROM ContentDocument WHERE Id=:cdl[0].ContentDocumentId];
        List<ContentVersion> cv = [SELECT FirstPublishLocationId, VersionData, Id, Title, IsLatest, CreatedDate FROM ContentVersion WHERE Id=:cd[0].LatestPublishedVersionId AND IsLatest=true ORDER BY CreatedDate DESC];
        if (cv.size()>0) {
            Set<Id> contentVersionIdSet = new Set<Id>();
            ContentDistribution cDist = new ContentDistribution();
            cDist.Name = 'Auto Create By Trigger';
            cDist.ContentVersionId = cv[0].Id;
            cDist.PreferencesNotifyOnVisit = false;
            contentVersionIdSet.add(cv[0].Id);
            List<ContentDistribution> existCDistList = [SELECT Id, ContentVersionId FROM ContentDistribution WHERE ContentVersionId = :contentVersionIdSet];
            delete existCDistList;
            insert cDist;
            cDist = [SELECT Id, ContentDownloadUrl FROM ContentDistribution WHERE Id=:cDist.Id];
            System.debug('*** cDist.ContentDownloadUrl ' + cDist.ContentDownloadUrl);
            return cDist.ContentDownloadUrl;
        }
        return null;
    }
    
}