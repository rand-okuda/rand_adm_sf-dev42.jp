trigger ikemen_Trigger on ikemen__c (before update) {
    System.debug('@@@ ikemen_Trigger');
    
    for ( Integer i=0; i<Trigger.New.size(); i++ ){
        if(Trigger.Old[i].Judgment__c != null && Trigger.New[i].modelId__c != null && Trigger.New[i].Judgment__c != Trigger.Old[i].Judgment__c){
            System.debug('*** ikemen ' + Trigger.New[i]);
            ikemen_Helper.JudgmentFeedback(Trigger.New[i].Id);
        }else{
            ikemen_Helper.WriteImageUrl(Trigger.New[i]);
        }
    }
    
}