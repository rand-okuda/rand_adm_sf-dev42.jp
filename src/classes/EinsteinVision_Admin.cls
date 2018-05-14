public class EinsteinVision_Admin {

    @AuraEnabled
    public static void createDatasetFromUrl(String zipUrl) {
        System.debug('@@@ createDatasetFromUrl()');
        EinsteinVision_PredictionService service = new EinsteinVision_PredictionService();
        service.createDatasetFromUrlAsync(zipUrl);
        System.debug('*** zipUrl ' + zipUrl);
    }
    
    @AuraEnabled
    public static List<EinsteinVision_Dataset> getDatasets() {
        System.debug('@@@ getDatasets()');
        EinsteinVision_PredictionService service = new EinsteinVision_PredictionService();
        EinsteinVision_Dataset[] datasets = service.getDatasets();
        System.debug('*** datasets ' + datasets);
        return datasets;
    }
    
    @AuraEnabled
    public static String trainDataset(Decimal datasetId) {
        System.debug('@@@ trainDataset()');
        EinsteinVision_PredictionService service = new EinsteinVision_PredictionService();
        EinsteinVision_Model model = service.trainDataset(Long.valueOf(String.valueOf(datasetId)), 'Training', 0, 0, '');
        System.debug('*** model.modelId ' + model.modelId);
        return model.modelId;
    }
    
    @AuraEnabled
    public static void deleteDataset(Long datasetId) {
        System.debug('@@@ deleteDataset()');
        EinsteinVision_PredictionService service = new EinsteinVision_PredictionService();
        System.debug('*** datasetId ' + datasetId);
        service.deleteDataset(datasetId);
    }
    
    @AuraEnabled
    public static List<EinsteinVision_Model> getModels(Long datasetId) {
        System.debug('@@@ getModels()');
        EinsteinVision_PredictionService service = new EinsteinVision_PredictionService();
        EinsteinVision_Model[] models = service.getModels(datasetId);
        System.debug('*** models ' + models);
        return models;
    }
    
    @future(callout=true)
    public static void getImagePrediction(Id recordId, String datasetName) {
        System.debug('@@@ getImagePrediction()');
        System.debug('*** recordId ' + recordId);
        System.debug('*** datasetName ' + datasetName);
        Blob fileBlob = getImageBlobFromFile(recordId);
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
        Blob fileBlob = getImageBlobFromFile(ikemen.Id);
        
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
    
    @AuraEnabled
    public static List<EinsteinVision_Label> getImageLabels(String datasetName) {
        System.debug('@@@ getImageLabels()');
        EinsteinVision_PredictionService service = new EinsteinVision_PredictionService();
        EinsteinVision_Dataset[] datasets = service.getDatasets();
        for (EinsteinVision_Dataset dataset : datasets) {
            if (dataset.Name.equals(datasetName)) {
                System.debug('*** dataset.labelSummary.labels ' + dataset.labelSummary.labels);
                return dataset.labelSummary.labels;
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static String getImageUrlFromAttachment(Id recordId) {
        System.debug('@@@ getImageUrlFromAttachment()');
        List<Attachment> atts = [SELECT Id FROM Attachment WHERE ParentId=:recordId];
        if (atts.size()>0) {
            System.debug('*** atts.get(0) ' + atts.get(0));
            return atts.get(0).Id;
        }
        return '';
    }
    
    public static Blob getImageBlobFromFile(Id recordId) {
        System.debug('@@@ getImageBlobFromFile()');
        List<ContentVersion> cv = [SELECT FirstPublishLocationId, VersionData, Id, Title, IsLatest, CreatedDate FROM ContentVersion WHERE FirstPublishLocationId=:recordId AND IsLatest=true ORDER BY CreatedDate DESC];
        if (cv.size()>0) {
            System.debug('*** cv.get(0) ' + cv.get(0));
            return cv.get(0).VersionData;
        }
        return null;
    }
    
}