trigger ikemen_Trigger on ikemen__c (after update) {
    System.debug('@@@ ikemen_Trigger');
    
    List<ikemen__c> ikemenList = new List<ikemen__c>();
    for ( Integer i=0; i<Trigger.New.size(); i++ ){
        if(Trigger.New[i].Feedback__c && Trigger.New[i].modelId__c != null && Trigger.New[i].Judgment__c != Trigger.Old[i].Judgment__c){
            ikemenList.add(Trigger.New[i]);
        }
    }
    for(ikemen__c ikemen :ikemenList){
        System.debug('*** ikemen ' + ikemen);
        EinsteinVision_Admin.JudgmentFeedback(ikemen.Id);
    }
    
}