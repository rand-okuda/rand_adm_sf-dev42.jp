public class ikemen_Helper {
    
    public static void WriteImageUrl(ikemen__c ikemen){
        System.debug('@@@ WriteImageUrl()');
        
        ikemen.ImageURL__c = ContentDocumentLink_Helper.getImageUrlFromCDLink(ikemen.Id);
        
    }
    
    @future(callout=true)
    public static void getImagePrediction(Id recordId, String datasetName) {
        System.debug('@@@ getImagePrediction()');
        System.debug('*** recordId ' + recordId);
        System.debug('*** datasetName ' + datasetName);
        
        Blob fileBlob = ContentDocumentLink_Helper.getImageBlobFromCDLink(recordId);
        
        EinsteinVision_PredictionService service = new EinsteinVision_PredictionService();
        EinsteinVision_Dataset[] datasets = service.getDatasets();
        
        for (EinsteinVision_Dataset dataset : datasets) {
            if (dataset.Name.equals(datasetName)) {
                
                EinsteinVision_Model[] models = service.getModels(dataset);
                EinsteinVision_Model model = models.get(0);
                EinsteinVision_PredictionResult result = service.predictBlob(model.modelId, fileBlob, '');
                EinsteinVision_Probability probability = result.probabilities.get(0);
                
                System.debug('*** dataset ' + dataset);
                System.debug('*** models ' + models);
                System.debug('*** model ' + model);
                System.debug('*** result1 ' + result.probabilities[0]);
                System.debug('*** result2 ' + result.probabilities[1]);
                System.debug('*** result3 ' + result.probabilities[2]);
                System.debug('*** probability ' + probability);
                
                ikemen__c ikemen = [SELECT Id FROM ikemen__c WHERE Id=:recordId];
                ikemen.Judgment__c = probability.label;
                ikemen.modelId__c = model.modelId;
                ikemen.Probability01__c = result.probabilities[0].probability;
                ikemen.Probability02__c = result.probabilities[1].probability;
                ikemen.Probability03__c = result.probabilities[2].probability;
                ikemen.label01__c = result.probabilities[0].label;
                ikemen.label02__c = result.probabilities[1].label;
                ikemen.label03__c = result.probabilities[2].label;
                update ikemen;
                
            }
        }
    }
    
    @future(callout=true)
    public static void JudgmentFeedback(Id recordId){
        System.debug('@@@ JudgmentFeedback()');
        
        ikemen__c ikemen = [SELECT Id, modelId__c, Judgment__c FROM ikemen__c WHERE Id = :recordId LIMIT 1];
        System.debug('*** ikemen.modelId__c ' + ikemen.modelId__c);
        System.debug('*** ikemen.ikemen__c ' + ikemen.Judgment__c);
        
        String name = ikemen.Id;
        String expectedLabel = ikemen.Judgment__c;
        String modelId = ikemen.modelId__c;
        Blob fileBlob = ContentDocumentLink_Helper.getImageBlobFromCDLink(ikemen.Id);
        
        Einstein_PredictionService Service = new Einstein_PredictionService(Einstein_PredictionService.Types.IMAGE);
        Einstein_Example feedbackResult = Service.createFeedbackImageExample(name, expectedLabel, modelId, fileBlob);
        
        ikemen.ExampleCreatedAt__c = feedbackResult.createdAt;
        ikemen.ExampleId__c = String.valueOf(feedbackResult.id);
        ikemen.ExampleDatasetId__c = String.valueOf(feedbackResult.label.datasetId);
        ikemen.ExampleLabelName__c = feedbackResult.label.name;
        ikemen.ExampleLabelId__c = String.valueOf(feedbackResult.label.Id);
        ikemen.ExampleNum__c = feedbackResult.label.numExamples;
        
        ikemen.Feedback__c = false;
        
        update ikemen;
        
        System.debug('*** ikemen.ExampleCreatedAt__c ' + ikemen.ExampleCreatedAt__c);
        System.debug('*** ikemen.ExampleId__c ' + ikemen.ExampleId__c);
        System.debug('*** ikemen.ExampleDatasetId__c ' + ikemen.ExampleDatasetId__c);
        System.debug('*** ikemen.ExampleLabelName__c ' + ikemen.ExampleLabelName__c);
        System.debug('*** ikemen.ExampleLabelId__c ' + ikemen.ExampleLabelId__c);
        System.debug('*** ikemen.ExampleNum__c ' + ikemen.ExampleNum__c);
        
    }
    
}