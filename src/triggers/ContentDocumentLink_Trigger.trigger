trigger ContentDocumentLink_Trigger on ContentDocumentLink (after insert) {
    System.debug('@@@ ContentDocumentLink_Trigger');
    
    Set<Id> idSet = new Set<Id>();
    for ( Integer i=0; i<Trigger.New.size(); i++ ){
        idSet.add(Trigger.New[i].LinkedEntityId);
    }

    List<ikemen__c> ikemenList = [SELECT Id FROM ikemen__c WHERE Id IN :idSet];
    if(!ikemenList.isEmpty()){
        String datasetName = 'kao';
        for(ikemen__c ikemen :ikemenList){
            System.debug('*** ikemen ' + ikemen); 
            EinsteinVision_Admin.getImagePrediction(ikemen.Id, datasetName);
        }
    }else{
        List<ikemen__c> ikemenList = new List<ikemen__c>();
        for ( Integer i=0; i<Trigger.New.size(); i++ ){
            ikemen__c ikemen = new ikemen__c();
            ikemenList.add(ikemen);
        }
        insert ikemenList;
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        for ( Integer i=0; i<Trigger.New.size(); i++ ){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = ikemenList[i].Id;
            cdl.ContentDocumentId = Trigger.New[i].ContentDocumentId;
            cdl.ShareType = 'I';
            cdlList.add(cdl);
            System.debug('*** cdl ' + cdl);
        }
        insert cdlList;
    }

}