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