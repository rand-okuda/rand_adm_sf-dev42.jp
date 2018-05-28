trigger ContentDocumentLink_Trigger on ContentDocumentLink (after insert) {
    System.debug('@@@ ContentDocumentLink_Trigger');
    
    ContentDocumentLink_Helper.CreateIkemenCDL(Trigger.New);
    
}