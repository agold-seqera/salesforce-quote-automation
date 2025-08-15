/**
 * Data provider for Quote approval Slack views
 * Provides quote details and approval context for interactive Slack notifications
 */
public class QuoteApprovalDataProvider {
    
    /**
     * Gets comprehensive quote details for Slack approval view
     * @param quoteId The ID of the quote requiring approval
     * @return Map containing all quote details needed for the view
     */
    @InvocableMethod(label='Get Quote Details for Slack Approval' 
                     description='Retrieves quote information for Slack approval interface')
    public static List<QuoteDetailsResult> getQuoteDetails(List<QuoteDetailsRequest> requests) {
        List<QuoteDetailsResult> results = new List<QuoteDetailsResult>();
        
        for (QuoteDetailsRequest request : requests) {
            results.add(getQuoteDetailsForId(request.quoteId));
        }
        
        return results;
    }
    
    /**
     * Gets quote details for a specific quote ID
     */
    private static QuoteDetailsResult getQuoteDetailsForId(String quoteId) {
        QuoteDetailsResult result = new QuoteDetailsResult();
        
        try {
            // Query quote with all necessary fields for approval
            Quote quote = [
                SELECT Id, Name, QuoteNumber, Account.Name, GrandTotal, 
                       Total_Payment_Due__c, Status, First_Approval_Override__c, 
                       Second_Approval_Override__c, CreatedBy.Name, CreatedDate,
                       Order_Start_Date__c, Order_End_Date__c, Term_Length_Months__c,
                       Contract_Signer__c, Payment_Terms__c, Billing_Frequency__c,
                       Annual_Total__c, Professional_Services__c, One_Off_Charges__c
                FROM Quote 
                WHERE Id = :quoteId 
                LIMIT 1
            ];
            
            // Populate result with quote data
            result.success = true;
            result.quoteId = quote.Id;
            result.quoteName = quote.QuoteNumber + ' - ' + quote.Name;
            result.accountName = quote.Account.Name;
            result.totalAmount = String.valueOf(quote.Total_Payment_Due__c ?? quote.GrandTotal);
            result.status = quote.Status;
            result.firstOverride = quote.First_Approval_Override__c ?? false;
            result.secondOverride = quote.Second_Approval_Override__c ?? false;
            result.createdBy = quote.CreatedBy.Name;
            result.createdDate = quote.CreatedDate;
            
            // Calculate approval stage based on current state
            result.approvalStage = determineApprovalStage(quote);
            result.approverGroup = determineApproverGroup(quote);
            
            // Add financial breakdown
            result.annualTotal = quote.Annual_Total__c;
            // Temporarily commented out to resolve deployment issue
            // result.professionalServices = quote.Professional_Services__c;
            // result.oneOffCharges = quote.One_Off_Charges__c;
            
            // Add contract details
            result.termLengthMonths = quote.Term_Length_Months__c;
            result.paymentTerms = quote.Payment_Terms__c;
            result.billingFrequency = quote.Billing_Frequency__c;
            result.contractSigner = quote.Contract_Signer__c;
            
        } catch (Exception e) {
            result.success = false;
            result.errorMessage = 'Error retrieving quote details: ' + e.getMessage();
            System.debug('QuoteApprovalDataProvider error: ' + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * Determines current approval stage based on quote state and override flags
     */
    private static String determineApprovalStage(Quote quote) {
        // Logic mirrors the flow decision tree
        if (quote.First_Approval_Override__c == false) {
            return 'Sales';
        } else if (quote.Second_Approval_Override__c == false) {
            return 'Ops_Legal';
        } else {
            return 'Auto_Approved';
        }
    }
    
    /**
     * Determines current approver group based on approval stage
     */
    private static String determineApproverGroup(Quote quote) {
        String stage = determineApprovalStage(quote);
        switch on stage {
            when 'Sales' {
                return 'Sales_Approver';
            }
            when 'Ops_Legal' {
                return 'Ops_Legal_Approver';
            }
            when else {
                return 'System';
            }
        }
    }
    
    // Request wrapper class
    public class QuoteDetailsRequest {
        @InvocableVariable(required=true)
        public String quoteId;
    }
    
    // Result wrapper class  
    public class QuoteDetailsResult {
        @InvocableVariable
        public Boolean success;
        
        @InvocableVariable
        public String errorMessage;
        
        @InvocableVariable
        public String quoteId;
        
        @InvocableVariable
        public String quoteName;
        
        @InvocableVariable
        public String accountName;
        
        @InvocableVariable
        public String totalAmount;
        
        @InvocableVariable
        public String status;
        
        @InvocableVariable
        public String approvalStage;
        
        @InvocableVariable
        public String approverGroup;
        
        @InvocableVariable
        public Boolean firstOverride;
        
        @InvocableVariable
        public Boolean secondOverride;
        
        @InvocableVariable
        public String createdBy;
        
        @InvocableVariable
        public DateTime createdDate;
        
        @InvocableVariable
        public Decimal annualTotal;
        
        @InvocableVariable
        public Decimal professionalServices;
        
        @InvocableVariable
        public Decimal oneOffCharges;
        
        @InvocableVariable
        public Decimal termLengthMonths;
        
        @InvocableVariable
        public String paymentTerms;
        
        @InvocableVariable
        public String billingFrequency;
        
        @InvocableVariable
        public String contractSigner;
    }
}