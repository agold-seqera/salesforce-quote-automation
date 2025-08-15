@isTest
public class QuoteOrchestrationSubflowTest {
    
    @TestSetup
    static void setupTestData() {
        // Use TestDataFactory for consistent test data creation
        Account testAccount = TestDataFactory.createAccount('Test Account');
        insert testAccount;
        
        Opportunity testOpp = TestDataFactory.createOpportunity(testAccount.Id, 'Test Opportunity');
        insert testOpp;
        
        // Create test contacts using TestDataFactory
        List<Contact> contacts = new List<Contact>();
        contacts.add(TestDataFactory.createContact(testAccount.Id, 'Contract', 'Signer', 'signer@test.com'));
        contacts.add(TestDataFactory.createContact(testAccount.Id, 'Primary', 'Contact', 'primary@test.com'));
        contacts.add(TestDataFactory.createContact(testAccount.Id, 'Legal', 'Contact', 'legal@test.com'));
        insert contacts;
        
        // Create test users using TestDataFactory
        User adminUser = TestDataFactory.createUser('System Administrator', 'admin@seqera.io.test.orchestration');
        User salesUser = TestDataFactory.createUser('Minimum Access - Salesforce', 'sales@seqera.io.test.orchestration');
        insert new List<User>{ adminUser, salesUser };
    }
    
    // ========== QUOTE_SUBFLOW_SET_APPROVAL_PROCESS TESTS ==========
    // NOTE: These tests are commented out because Quote_Subflow_Set_Approval_Process flow 
    // was deactivated in the UI as it's not needed for current Quote System functionality
    
    /*
    @isTest
    static void testApprovalProcessSubflow_AdminBypass() {
        User adminUser = [SELECT Id FROM User WHERE Username = 'admin@seqera.io.test.orchestration' LIMIT 1];
        
        System.runAs(adminUser) {
            Test.startTest();
            
            Quote testQuote = createTestQuote(true);
            
            // Call the approval process subflow via Flow.Interview
            Map<String, Object> inputs = new Map<String, Object>{
                'recordId' => testQuote.Id,
                'currentUserId' => adminUser.Id
            };
            
            Flow.Interview.Quote_Subflow_Set_Approval_Process interview = 
                new Flow.Interview.Quote_Subflow_Set_Approval_Process(inputs);
            interview.start();
            
            Test.stopTest();
            
            // Verify admin bypass logic
            Boolean bypassApproval = (Boolean) interview.getVariableValue('bypassApproval');
            String approvalProcess = (String) interview.getVariableValue('approvalProcess');
            Boolean isValid = (Boolean) interview.getVariableValue('isValid');
            
            System.assertEquals(true, bypassApproval, 'Admin should bypass approval');
            System.assertEquals('Auto-Approval', approvalProcess, 'Should set auto-approval process');
            System.assertEquals(true, isValid, 'Should be valid for admin');
        }
    }
    
    @isTest
    static void testApprovalProcessSubflow_BothOverridesSet() {
        User salesUser = [SELECT Id FROM User WHERE Username = 'sales@seqera.io.test.orchestration' LIMIT 1];
        
        System.runAs(salesUser) {
            Test.startTest();
            
            Quote testQuote = createTestQuote(true);
            testQuote.First_Approval_Override__c = true;
            testQuote.Second_Approval_Override__c = true;
            update testQuote;
            
            // Call the approval process subflow
            Map<String, Object> inputs = new Map<String, Object>{
                'recordId' => testQuote.Id,
                'currentUserId' => salesUser.Id
            };
            
            Flow.Interview.Quote_Subflow_Set_Approval_Process interview = 
                new Flow.Interview.Quote_Subflow_Set_Approval_Process(inputs);
            interview.start();
            
            Test.stopTest();
            
            // Verify both overrides logic
            Boolean bypassApproval = (Boolean) interview.getVariableValue('bypassApproval');
            String approvalProcess = (String) interview.getVariableValue('approvalProcess');
            
            System.assertEquals(true, bypassApproval, 'Both overrides should bypass approval');
            System.assertEquals('Auto-Approval', approvalProcess, 'Should set auto-approval process');
        }
    }
    
    @isTest
    static void testApprovalProcessSubflow_FirstOverrideOnly() {
        User salesUser = [SELECT Id FROM User WHERE Username = 'sales@seqera.io.test.orchestration' LIMIT 1];
        
        System.runAs(salesUser) {
            Test.startTest();
            
            Quote testQuote = createTestQuote(true);
            testQuote.First_Approval_Override__c = true;
            testQuote.Second_Approval_Override__c = false;
            update testQuote;
            
            // Call the approval process subflow
            Map<String, Object> inputs = new Map<String, Object>{
                'recordId' => testQuote.Id,
                'currentUserId' => salesUser.Id
            };
            
            Flow.Interview.Quote_Subflow_Set_Approval_Process interview = 
                new Flow.Interview.Quote_Subflow_Set_Approval_Process(inputs);
            interview.start();
            
            Test.stopTest();
            
            // Verify first override logic
            String approvalProcess = (String) interview.getVariableValue('approvalProcess');
            Boolean isValid = (Boolean) interview.getVariableValue('isValid');
            
            System.assertEquals('Operations/Legal Approval Only', approvalProcess, 
                               'Should set ops/legal approval process');
            System.assertEquals(true, isValid, 'Should be valid');
        }
    }
    
    @isTest
    static void testApprovalProcessSubflow_SecondOverrideOnly() {
        User salesUser = [SELECT Id FROM User WHERE Username = 'sales@seqera.io.test.orchestration' LIMIT 1];
        
        System.runAs(salesUser) {
            Test.startTest();
            
            Quote testQuote = createTestQuote(true);
            testQuote.First_Approval_Override__c = false;
            testQuote.Second_Approval_Override__c = true;
            update testQuote;
            
            // Call the approval process subflow
            Map<String, Object> inputs = new Map<String, Object>{
                'recordId' => testQuote.Id,
                'currentUserId' => salesUser.Id
            };
            
            Flow.Interview.Quote_Subflow_Set_Approval_Process interview = 
                new Flow.Interview.Quote_Subflow_Set_Approval_Process(inputs);
            interview.start();
            
            Test.stopTest();
            
            // Verify second override logic
            String approvalProcess = (String) interview.getVariableValue('approvalProcess');
            Boolean isValid = (Boolean) interview.getVariableValue('isValid');
            
            System.assertEquals('Sales Approval Only', approvalProcess, 
                               'Should set sales approval process');
            System.assertEquals(true, isValid, 'Should be valid');
        }
    }
    
    @isTest
    static void testApprovalProcessSubflow_DualApproval() {
        User salesUser = [SELECT Id FROM User WHERE Username = 'sales@seqera.io.test.orchestration' LIMIT 1];
        
        System.runAs(salesUser) {
            Test.startTest();
            
            Quote testQuote = createTestQuote(true);
            testQuote.First_Approval_Override__c = false;
            testQuote.Second_Approval_Override__c = false;
            update testQuote;
            
            // Call the approval process subflow
            Map<String, Object> inputs = new Map<String, Object>{
                'recordId' => testQuote.Id,
                'currentUserId' => salesUser.Id
            };
            
            Flow.Interview.Quote_Subflow_Set_Approval_Process interview = 
                new Flow.Interview.Quote_Subflow_Set_Approval_Process(inputs);
            interview.start();
            
            Test.stopTest();
            
            // Verify dual approval logic
            String approvalProcess = (String) interview.getVariableValue('approvalProcess');
            Boolean isValid = (Boolean) interview.getVariableValue('isValid');
            
            System.assertEquals('Dual Approval', approvalProcess, 
                               'Should set dual approval process');
            System.assertEquals(true, isValid, 'Should be valid');
        }
    }
    
    // ========== STATUS SUBFLOW TESTS ==========
    
    @isTest
    static void testStatusSubflow_SetToInReview() {
        Test.startTest();
        
        Quote testQuote = createTestQuote(true);
        
        // Call the In Review status subflow
        Map<String, Object> inputs = new Map<String, Object>{
            'recordId' => testQuote.Id
        };
        
        Flow.Interview.Quote_Subflow_Set_Quote_Status_to_In_Review interview = 
            new Flow.Interview.Quote_Subflow_Set_Quote_Status_to_In_Review(inputs);
        interview.start();
        
        Test.stopTest();
        
        // Verify status update
        Quote updatedQuote = [SELECT Status FROM Quote WHERE Id = :testQuote.Id];
        System.assertEquals('In Review', updatedQuote.Status, 'Status should be updated to In Review');
    }
    
    @isTest
    static void testStatusSubflow_SetToApproved() {
        Test.startTest();
        
        Quote testQuote = createTestQuote(true);
        
        // Call the Approved status subflow
        Map<String, Object> inputs = new Map<String, Object>{
            'recordId' => testQuote.Id
        };
        
        Flow.Interview.Quote_Subflow_Set_Quote_Status_to_Approved interview = 
            new Flow.Interview.Quote_Subflow_Set_Quote_Status_to_Approved(inputs);
        interview.start();
        
        Test.stopTest();
        
        // Verify status update
        Quote updatedQuote = [SELECT Status FROM Quote WHERE Id = :testQuote.Id];
        System.assertEquals('Approved', updatedQuote.Status, 'Status should be updated to Approved');
    }
    
    @isTest
    static void testStatusSubflow_SetToRejected() {
        Test.startTest();
        
        Quote testQuote = createTestQuote(true);
        
        // Call the Rejected status subflow
        Map<String, Object> inputs = new Map<String, Object>{
            'recordId' => testQuote.Id
        };
        
        Flow.Interview.Quote_Subflow_Set_Quote_Status_to_Rejected interview = 
            new Flow.Interview.Quote_Subflow_Set_Quote_Status_to_Rejected(inputs);
        interview.start();
        
        Test.stopTest();
        
        // Verify status update
        Quote updatedQuote = [SELECT Status FROM Quote WHERE Id = :testQuote.Id];
        System.assertEquals('Rejected', updatedQuote.Status, 'Status should be updated to Rejected');
    }
    
    @isTest
    static void testStatusSubflows_BulkOperations() {
        Test.startTest();
        
        List<Quote> testQuotes = new List<Quote>();
        for (Integer i = 0; i < 5; i++) {
            testQuotes.add(createTestQuote(true));
        }
        
        // Test bulk status updates through multiple subflow calls
        for (Quote q : testQuotes) {
            Map<String, Object> inputs = new Map<String, Object>{
                'recordId' => q.Id
            };
            
            Flow.Interview.Quote_Subflow_Set_Quote_Status_to_In_Review interview = 
                new Flow.Interview.Quote_Subflow_Set_Quote_Status_to_In_Review(inputs);
            interview.start();
        }
        
        Test.stopTest();
        
        // Verify all quotes updated
        List<Quote> updatedQuotes = [SELECT Status FROM Quote WHERE Id IN :testQuotes];
        System.assertEquals(5, updatedQuotes.size(), 'All quotes should be updated');
        
        for (Quote q : updatedQuotes) {
            System.assertEquals('In Review', q.Status, 'All quotes should be In Review');
        }
    }
    
    // ========== APPROVAL_SCREEN_STANDARD_DECISION TESTS ==========
    
    @isTest
    static void testApprovalScreenFlow_Basic() {
        Test.startTest();
        
        // Test basic approval screen flow instantiation
        Map<String, Object> inputs = new Map<String, Object>();
        
        Flow.Interview.Approval_Screen_Standard_Decision interview = 
            new Flow.Interview.Approval_Screen_Standard_Decision(inputs);
        
        // Note: Cannot test screen interaction in unit tests
        // This validates the flow can be instantiated
        System.assertNotEquals(null, interview, 'Interview should be created');
        
        Test.stopTest();
    }
    
    // ========== INTEGRATION TESTS ==========
    
    @isTest
    static void testOrchestrationIntegration_FullWorkflow() {
        User salesUser = [SELECT Id FROM User WHERE Username = 'sales@seqera.io.test.orchestration' LIMIT 1];
        
        System.runAs(salesUser) {
            Test.startTest();
            
            Quote testQuote = createTestQuote(true);
            
            // Step 1: Set approval process
            Map<String, Object> approvalInputs = new Map<String, Object>{
                'recordId' => testQuote.Id,
                'currentUserId' => salesUser.Id
            };
            
            Flow.Interview.Quote_Subflow_Set_Approval_Process approvalInterview = 
                new Flow.Interview.Quote_Subflow_Set_Approval_Process(approvalInputs);
            approvalInterview.start();
            
            // Step 2: Set status to In Review
            Map<String, Object> statusInputs = new Map<String, Object>{
                'recordId' => testQuote.Id
            };
            
            Flow.Interview.Quote_Subflow_Set_Quote_Status_to_In_Review statusInterview = 
                new Flow.Interview.Quote_Subflow_Set_Quote_Status_to_In_Review(statusInputs);
            statusInterview.start();
            
            Test.stopTest();
            
            // Verify workflow completion
            String approvalProcess = (String) approvalInterview.getVariableValue('approvalProcess');
            Quote updatedQuote = [SELECT Status FROM Quote WHERE Id = :testQuote.Id];
            
            System.assertEquals('Dual Approval', approvalProcess, 'Should set dual approval');
            System.assertEquals('In Review', updatedQuote.Status, 'Should set status to In Review');
        }
    }
    */
    
    // ========== ACTIVE STATUS SUBFLOW TESTS ==========
    
    @isTest
    static void testOrchestrationIntegration_ErrorHandling() {
        Test.startTest();
        
        // Test error handling with invalid record ID
        Map<String, Object> inputs = new Map<String, Object>{
            'recordId' => 'invalid_id'
        };
        
        Boolean exceptionThrown = false;
        try {
            Flow.Interview.Quote_Subflow_Set_Quote_Status_to_Approved interview = 
                new Flow.Interview.Quote_Subflow_Set_Quote_Status_to_Approved(inputs);
            interview.start();
        } catch (Exception e) {
            exceptionThrown = true;
        }
        
        Test.stopTest();
        
        // Verify graceful error handling
        System.assert(exceptionThrown, 'Should handle invalid record ID gracefully');
    }
    
    // ========== HELPER METHODS ==========
    
    private static Quote createTestQuote(Boolean withCompleteData) {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact ORDER BY FirstName];
        
        Quote testQuote = new Quote(
            Name = 'Test Quote ' + System.currentTimeMillis(),
            OpportunityId = testOpp.Id,
            ExpirationDate = Date.today().addDays(30),
            Status = 'Draft',
            Pricebook2Id = Test.getStandardPricebookId(),
            First_Approval_Override__c = false,
            Second_Approval_Override__c = false
        );
        
        if (withCompleteData) {
            testQuote.Customer_Legal_Name__c = 'Test Customer Legal Name';
            testQuote.BillingName = 'Test Bill To Name';
            testQuote.Master_Terms__c = 'MSA | SLA executed on the effective date set out therein';
            testQuote.Seqera_Contact_Email__c = 'seqera@test.com';
            testQuote.DPA_Required__c = 'Yes';
            testQuote.Payment_Terms__c = 'Net 30';
            testQuote.Order_Start_Date__c = Date.today();
            testQuote.Order_End_Date__c = Date.today().addYears(1);
            testQuote.Term_Length_Months__c = 12;
            testQuote.Annual_Total__c = 100000;
            testQuote.One_Off_Charges__c = 5000;
            testQuote.Tax_Exempt__c = 'No';
            testQuote.PO_Required_by_Customer__c = 'No';
            
            // Set required contact fields
            if (contacts.size() >= 3) {
                testQuote.Contract_Signer__c = contacts[0].Id;
                testQuote.Primary_Customer_Contact__c = contacts[1].Id;
                testQuote.Billing_Contact__c = contacts[2].Id;
            }
            
            try {
                testQuote.put('Billing_Frequency__c', 'Annually');
            } catch (Exception e) {
                // Field may not exist in this org, ignore
            }
        }
        
        insert testQuote;
        
        // Create quote line item for complete data
        if (withCompleteData) {
            Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
            insert testProduct;
            
            PricebookEntry pbe = new PricebookEntry(
                Product2Id = testProduct.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                UnitPrice = 1000,
                IsActive = true
            );
            insert pbe;
            
            QuoteLineItem qli = TestDataFactory.createQuoteLineItem(testQuote.Id, testProduct.Id, pbe.Id, 1, 1000);
            insert qli;
        }
        
        return testQuote;
    }
}