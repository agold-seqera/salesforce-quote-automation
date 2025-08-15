// Trigger for Quote processing: sync and general processing
// NOTE: Approval processing moved to native Salesforce approval processes (August 10, 2025)
trigger QuoteSyncTrigger on Quote (after update) {
    QuoteProcessOrchestratorHandler.handleTrigger();
}