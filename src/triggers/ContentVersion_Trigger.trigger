trigger ContentVersion_Trigger on ContentVersion (after insert) {
    System.debug('@@@ ContentVersion_Trigger');
    
    for ( Integer i=0; i<Trigger.New.size(); i++ ){
        if(Trigger.New[i].FirstPublishLocationId != null){
            ContentVersion cv = Trigger.New[i];
            String datasetName = 'kao';
            System.debug('*** cv ' + cv); 
            EinsteinVision_Admin.getImagePrediction(cv.FirstPublishLocationId, datasetName);
        }
    }
    
}