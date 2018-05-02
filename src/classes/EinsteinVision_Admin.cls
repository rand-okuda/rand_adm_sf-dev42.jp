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
    
    @AuraEnabled
    public static void getImagePrediction(Id objectId, Id imageId, String datasetName) {
        System.debug('@@@ getImagePrediction()');
        Blob fileBlob = EncodingUtil.base64Decode(imageId);
        EinsteinVision_PredictionService service = new EinsteinVision_PredictionService();
        EinsteinVision_Dataset[] datasets = service.getDatasets();
        for (EinsteinVision_Dataset dataset : datasets) {
            if (dataset.Name.equals(datasetName)) {
                EinsteinVision_Model[] models = service.getModels(dataset);
                EinsteinVision_Model model = models.get(0);
                EinsteinVision_PredictionResult result = service.predictBlob(model.modelId, fileBlob, '');
                EinsteinVision_Probability probability = result.probabilities.get(0);
                
                System.debug('*** probability.label ' + probability.label);
                
                ContentVersion cv = new ContentVersion();
                cv.VersionData = fileBlob;
                cv.Title = datasetName + imageId;
                Integer existCVCount = [SELECT COUNT() FROM ContentDocument WHERE Title = :cv.Title];
                if(existCVCount > 0){
                    ContentDocument existCV = [SELECT Id, Title FROM ContentDocument WHERE Title = :cv.Title];
                    cv.ContentDocumentId = existCV.Id;
                }
                cv.PathOnClient = '/' + cv.Title;
                insert cv;
                System.debug('*** cv ' + cv);
                
                FeedItem fi = new FeedItem();
                fi.Body = probability.label;
                fi.ParentId = objectId;
                fi.RelatedRecordId = cv.Id;
                insert fi;
                System.debug('*** fi ' + fi);
                
            }
        }
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
    
}