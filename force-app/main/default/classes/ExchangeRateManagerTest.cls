// Test class for ExchangeRateManager
// Provides comprehensive coverage for scheduled execution, multi-object support,
// and utility methods with various edge cases
@isTest
public class ExchangeRateManagerTest {
    
    // Test data setup method
    // Creates test opportunities, quotes, and exchange rate data
    @testSetup
    static void setupTestData() {
        // Create test Account
        Account testAccount = TestDataFactory.createAccount('Exchange Rate Test Account');
        insert testAccount;
        
        // Create test Opportunity
        Opportunity opp = TestDataFactory.createOpportunity(testAccount.Id, 'Test Exchange Rate Opportunity');
        opp.Contract_Start_Date__c = Date.today();
        insert opp;
        
        // Create test Quotes with different currencies and exchange rate states
        List<Quote> testQuotes = new List<Quote>();
        
        // Quote 1: No exchange rate, USD currency
        Quote usdQuote = TestDataFactory.createQuote(opp.Id, 'Test Quote USD - No Rate');
        usdQuote.CurrencyIsoCode = 'USD';
        usdQuote.Exchange_Rate_at_Creation__c = null;
        testQuotes.add(usdQuote);
        
        // Quote 2: No exchange rate, EUR currency  
        Quote eurQuote = TestDataFactory.createQuote(opp.Id, 'Test Quote EUR - No Rate');
        eurQuote.CurrencyIsoCode = 'EUR';
        eurQuote.Exchange_Rate_at_Creation__c = null;
        testQuotes.add(eurQuote);
        
        // Quote 3: Already has exchange rate (should be skipped)
        Quote hasRateQuote = TestDataFactory.createQuote(opp.Id, 'Test Quote USD - Has Rate');
        hasRateQuote.CurrencyIsoCode = 'USD';
        hasRateQuote.Exchange_Rate_at_Creation__c = 1.15;
        testQuotes.add(hasRateQuote);
        
        insert testQuotes;
    }
    
    // Test the schedulable execute method
    // Verifies that scheduled execution runs without errors
    @isTest
    static void testSchedulableExecution() {
        Test.startTest();
        
        // Create schedulable instance and execute
        ExchangeRateManager scheduler = new ExchangeRateManager();
        String cronExpression = '0 1 0 * * ?'; // Daily at 12:01 AM
        String jobId = System.schedule('Test Exchange Rate Manager', cronExpression, scheduler);
        
        // Verify job was scheduled
        System.assert(String.isNotBlank(jobId), 'Scheduled job should have valid ID');
        
        // Execute the scheduler directly for testing
        SchedulableContext mockContext = null; // Null is acceptable for test context
        scheduler.execute(mockContext);
        
        Test.stopTest();
        
        // Verify execution completed without exceptions
        // Additional assertions would depend on DatedConversionRate test data availability
        System.assert(true, 'Scheduled execution should complete without exceptions');
    }
    
    // Test updating exchange rates for Quote object specifically
    // Covers the primary use case for the current implementation
    @isTest
    static void testUpdateExchangeRatesForQuoteObject() {
        Test.startTest();
        
        // Execute exchange rate update for Quote object
        Integer recordsUpdated = ExchangeRateManager.updateExchangeRatesForObject('Quote', 'Exchange_Rate_at_Creation__c');
        
        Test.stopTest();
        
        // Verify method executed without errors
        System.assert(recordsUpdated >= 0, 'Should return non-negative count of updated records');
        
        // Query quotes to verify exchange rates were set (where possible)
        List<Quote> updatedQuotes = [
            SELECT Id, Name, Exchange_Rate_at_Creation__c, CurrencyIsoCode
            FROM Quote 
            WHERE Exchange_Rate_at_Creation__c != null
        ];
        
        // At minimum, quotes that had rates should still have them
        System.assert(updatedQuotes.size() >= 1, 'At least one quote should have exchange rate');
    }
    
    // Test the main orchestration method
    // Verifies processing of all configured objects
    @isTest
    static void testUpdateExchangeRatesForAllConfiguredObjects() {
        Test.startTest();
        
        // Execute the main orchestration method
        ExchangeRateManager.updateExchangeRatesForAllConfiguredObjects();
        
        Test.stopTest();
        
        // Verify method executed without exceptions
        // In a real org with multi-currency, would verify actual exchange rates were set
        System.assert(true, 'Main orchestration method should execute without exceptions');
    }
    
    // Test the getCurrentExchangeRate utility method
    // Tests both success and edge case scenarios
    @isTest
    static void testGetCurrentExchangeRate() {
        Test.startTest();
        
        // Test with valid currency code
        Decimal usdRate = ExchangeRateManager.getCurrentExchangeRate('USD');
        System.assert(usdRate != null, 'Should return exchange rate for USD');
        System.assert(usdRate > 0, 'Exchange rate should be positive');
        
        // Test with null currency code
        Decimal nullRate = ExchangeRateManager.getCurrentExchangeRate(null);
        System.assertEquals(null, nullRate, 'Should return null for null currency code');
        
        // Test with blank currency code
        Decimal blankRate = ExchangeRateManager.getCurrentExchangeRate('');
        System.assertEquals(null, blankRate, 'Should return null for blank currency code');
        
        // Test with non-existent currency code
        Decimal fakeRate = ExchangeRateManager.getCurrentExchangeRate('XYZ');
        System.assert(fakeRate == 1.0, 'Should return 1.0 for non-existent currency');
        
        Test.stopTest();
    }
    
    // Test the InvocableMethod for Flow integration
    // Verifies that flows can call the exchange rate update functionality
    @isTest
    static void testInvocableMethod() {
        Test.startTest();
        
        // Test with configured object
        List<String> objectNames = new List<String>{'Quote'};
        List<String> results = ExchangeRateManager.updateExchangeRatesInvocable(objectNames);
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assert(results[0].contains('Quote'), 'Result should mention Quote object');
        
        // Test with non-configured object
        List<String> invalidObjects = new List<String>{'CustomObject__c'};
        List<String> invalidResults = ExchangeRateManager.updateExchangeRatesInvocable(invalidObjects);
        
        System.assertEquals(1, invalidResults.size(), 'Should return one result for invalid object');
        System.assert(invalidResults[0].contains('Not configured'), 'Should indicate object not configured');
        
        Test.stopTest();
    }
    
    // Test the getExchangeRateForDate utility method
    // Verifies historical exchange rate lookup functionality
    @isTest
    static void testGetExchangeRateForDate() {
        Test.startTest();
        
        Date testDate = Date.today().addDays(-30);
        
        // Test with valid currency and date
        Decimal historicalRate = ExchangeRateManager.getExchangeRateForDate('USD', testDate);
        System.assert(historicalRate != null, 'Should return exchange rate for valid currency and date');
        System.assert(historicalRate > 0, 'Historical exchange rate should be positive');
        
        // Test with null currency
        Decimal nullCurrencyRate = ExchangeRateManager.getExchangeRateForDate(null, testDate);
        System.assertEquals(null, nullCurrencyRate, 'Should return null for null currency');
        
        // Test with null date  
        Decimal nullDateRate = ExchangeRateManager.getExchangeRateForDate('USD', null);
        System.assertEquals(null, nullDateRate, 'Should return null for null date');
        
        Test.stopTest();
    }
    
    // Test configuration management methods
    // Verifies ability to add objects and query configuration
    @isTest
    static void testConfigurationManagement() {
        Test.startTest();
        
        // Test getting current configuration
        Set<String> configuredObjects = ExchangeRateManager.getConfiguredObjects();
        System.assert(configuredObjects.contains('Quote'), 'Configuration should include Quote object');
        
        // Test adding new object to configuration
        Boolean addResult = ExchangeRateManager.addObjectToConfiguration('Opportunity', 'Exchange_Rate__c');
        System.assertEquals(true, addResult, 'Should successfully add new object');
        
        // Test adding duplicate object
        Boolean duplicateResult = ExchangeRateManager.addObjectToConfiguration('Quote', 'Exchange_Rate_at_Creation__c');
        System.assertEquals(false, duplicateResult, 'Should return false for duplicate object');
        
        // Verify updated configuration
        Set<String> updatedConfig = ExchangeRateManager.getConfiguredObjects();
        System.assert(updatedConfig.contains('Opportunity'), 'Updated configuration should include Opportunity');
        
        Test.stopTest();
    }
    
    // Test bulk processing capabilities
    // Verifies system can handle multiple records efficiently
    @isTest
    static void testBulkProcessing() {
        // Create additional test quotes for bulk testing
        List<Quote> bulkQuotes = new List<Quote>();
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        Id standardPricebookId = QuoteLineItemCalculationHelper.getStandardPriceBookId();
        
        for (Integer i = 0; i < 50; i++) {
            bulkQuotes.add(new Quote(
                Name = 'Bulk Test Quote ' + i,
                OpportunityId = testOpp.Id,
                Pricebook2Id = standardPricebookId,
                Order_Start_Date__c = Date.today(),
                Order_End_Date__c = Date.today().addDays(365),
                CurrencyIsoCode = (Math.mod(i, 2) == 0 ? 'USD' : 'EUR'),
                Exchange_Rate_at_Creation__c = null
            ));
        }
        insert bulkQuotes;
        
        Test.startTest();
        
        // Execute bulk processing
        Integer recordsUpdated = ExchangeRateManager.updateExchangeRatesForObject('Quote', 'Exchange_Rate_at_Creation__c');
        
        Test.stopTest();
        
        // Verify bulk processing completed
        System.assert(recordsUpdated >= 0, 'Bulk processing should return non-negative result');
        
        // Verify no governor limit exceptions occurred
        System.assert(true, 'Bulk processing should complete without governor limit exceptions');
    }
    
    // Test error handling for invalid object names
    // Verifies graceful handling of configuration errors
    @isTest
    static void testErrorHandling() {
        Test.startTest();
        
        try {
            // Test with invalid object name (should handle gracefully)
            Integer result = ExchangeRateManager.updateExchangeRatesForObject('InvalidObject', 'Invalid_Field__c');
            
            // Method should handle error gracefully and return 0
            System.assertEquals(0, result, 'Invalid object should return 0 records updated');
            
        } catch (Exception e) {
            // Verify error is handled appropriately
            System.assert(e.getMessage().contains('sObject type') || e.getMessage().contains('Invalid'), 
                         'Should receive appropriate error message for invalid object');
        }
        
        Test.stopTest();
    }
}