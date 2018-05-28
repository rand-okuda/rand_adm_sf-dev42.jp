public class ContentDocumentLink_Helper {
    
    public static void CreateIkemenCDL(List<ContentDocumentLink> existCDLList) {
        System.debug('@@@ CreateIkemenCDL()');
        
        Set<Id> idSet = new Set<Id>();
        for ( Integer i=0; i<existCDLList.size(); i++ ){
            idSet.add(existCDLList[i].LinkedEntityId);
        }
        List<ikemen__c> existIkemenList = [SELECT Id FROM ikemen__c WHERE Id IN :idSet];
        
        if(!existIkemenList.isEmpty()){
            
            String datasetName = 'kao';
            for(ikemen__c ikemen :existIkemenList){
                System.debug('*** ikemen ' + ikemen); 
                EinsteinVision_Admin.getImagePrediction(ikemen.Id, datasetName);
            }
            
        }else{
            
            List<ikemen__c> newIkemenList = new List<ikemen__c>();
            for ( Integer i=0; i<existCDLList.size(); i++ ){
                ikemen__c ikemen = new ikemen__c();
                newIkemenList.add(ikemen);
                System.debug('*** ikemen ' + ikemen); 
            }
            insert newIkemenList;
            
            List<ContentDocumentLink> newCDLList = new List<ContentDocumentLink>();
            for ( Integer i=0; i<existCDLList.size(); i++ ){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = newIkemenList[i].Id;
                cdl.ContentDocumentId = existCDLList[i].ContentDocumentId;
                cdl.ShareType = 'I';
                newCDLList.add(cdl);
                System.debug('*** cdl ' + cdl);
            }
            insert newCDLList;
            
        }
        
    }
    
}