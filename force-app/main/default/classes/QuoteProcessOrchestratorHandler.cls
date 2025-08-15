// Handler for Quote sync and related after-update processing
// NOTE: Approval processing now handled by native Salesforce approval processes
// via Quote_After_Save_Launch_Approval_Process flow (August 10, 2025)
public class QuoteProcessOrchestratorHandler {
    
    public static void handleTrigger() {
        if (Trigger.isAfter && Trigger.isUpdate) {
            handleAfterUpdate((Map<Id, Quote>)Trigger.newMap, (Map<Id, Quote>)Trigger.oldMap);
        }
    }

    private static void handleAfterUpdate(Map<Id, Quote> newQuotes, Map<Id, Quote> oldQuotes) {
        System.debug('QuoteProcessOrchestratorHandler: Processing ' + newQuotes.size() + ' Quote updates');
        
        // NOTE: Automatic sync on status change has been disabled per user requirements
        // Sync now only happens manually via Quote_Button_Sync_Quote_to_Opportunity button
        // which invokes QuoteSyncService.syncQuotesToOpportunities() directly
        
        // Approval processing is also handled by:
        // - Quote_After_Save_Launch_Approval_Process (flow)
        // - Quote_Dual_Approval (native approval process)
        // - Quote_First_Override_Approval (native approval process) 
        // - Quote_Second_Override_Approval (native approval process)
    }
}