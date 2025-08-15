// UI Test Data Creation Script
// Creates comprehensive test data for Quote System UI testing
// Execute in Execute Anonymous in Salesforce Developer Console

System.debug('Starting UI Test Data Creation...');

// Create multiple test accounts for different scenarios
List<Account> accounts = new List<Account>();
accounts.add(TestDataFactory.createAccount('Acme Software Solutions'));
accounts.add(TestDataFactory.createAccount('Global Tech Enterprises')); 
accounts.add(TestDataFactory.createAccount('NextGen Bio Labs'));
accounts.add(TestDataFactory.createAccount('Enterprise Cloud Corp'));
insert accounts;
System.debug('Created ' + accounts.size() + ' test accounts');

// Create contacts for each account
List<Contact> contacts = new List<Contact>();
for(Account acc : accounts) {
    contacts.add(TestDataFactory.createContact(acc.Id, 'John', 'Smith', 'john.smith@' + acc.Name.toLowerCase().replace(' ', '') + '.com'));
    contacts.add(TestDataFactory.createContact(acc.Id, 'Sarah', 'Johnson', 'sarah.johnson@' + acc.Name.toLowerCase().replace(' ', '') + '.com'));
}
insert contacts;
System.debug('Created ' + contacts.size() + ' test contacts');

// Create opportunities for different scenarios
List<Opportunity> opportunities = new List<Opportunity>();

// Scenario 1: New Sales Opportunity (Large Deal)
Opportunity newSalesOpp = TestDataFactory.createOpportunity(accounts[0].Id, 'Acme Software - Platform License');
newSalesOpp.Amount = 500000;
newSalesOpp.StageName = 'Proposal';
newSalesOpp.Contract_Start_Date__c = Date.today().addDays(30);
newSalesOpp.CloseDate = Date.today().addDays(45);
newSalesOpp.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'New_Sales_Opportunity' LIMIT 1].Id;
opportunities.add(newSalesOpp);

// Scenario 2: Existing Customer Renewal
Opportunity renewalOpp = TestDataFactory.createOpportunity(accounts[1].Id, 'Global Tech - Annual Renewal');
renewalOpp.Amount = 250000;
renewalOpp.StageName = 'Negotiation';
renewalOpp.Contract_Start_Date__c = Date.today().addDays(60);
renewalOpp.CloseDate = Date.today().addDays(30);
renewalOpp.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Existing_Customer_Opportunity' LIMIT 1].Id;
opportunities.add(renewalOpp);

// Scenario 3: Academic Opportunity (Lower Amount)
Opportunity academicOpp = TestDataFactory.createOpportunity(accounts[2].Id, 'NextGen Bio - Research License');
academicOpp.Amount = 75000;
academicOpp.StageName = 'Discovery';
academicOpp.Contract_Start_Date__c = Date.today().addDays(90);
academicOpp.CloseDate = Date.today().addDays(60);
academicOpp.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Academic_Opportunity' LIMIT 1].Id;
opportunities.add(academicOpp);

// Scenario 4: Enterprise Deal (High Value)
Opportunity enterpriseOpp = TestDataFactory.createOpportunity(accounts[3].Id, 'Enterprise Cloud - Multi-Year Deal');
enterpriseOpp.Amount = 1200000;
enterpriseOpp.StageName = 'Proposal';
enterpriseOpp.Contract_Start_Date__c = Date.today().addDays(15);
enterpriseOpp.CloseDate = Date.today().addDays(21);
opportunities.add(enterpriseOpp);

insert opportunities;
System.debug('Created ' + opportunities.size() + ' test opportunities');

// Create diverse products for testing
List<Product2> products = new List<Product2>();
products.add(TestDataFactory.createProduct('Seqera Platform Enterprise', 'Software Subscriptions'));
products.add(TestDataFactory.createProduct('Seqera Platform Standard', 'Software Subscriptions'));
products.add(TestDataFactory.createProduct('Professional Services - Implementation', 'Professional Services'));
products.add(TestDataFactory.createProduct('Professional Services - Training', 'Professional Services'));
products.add(TestDataFactory.createProduct('Premium Support', 'Support'));
insert products;
System.debug('Created ' + products.size() + ' test products');

// Create pricebook entries
List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
pricebookEntries.add(TestDataFactory.createPricebookEntry(products[0].Id, 100000)); // Enterprise License
pricebookEntries.add(TestDataFactory.createPricebookEntry(products[1].Id, 50000));  // Standard License
pricebookEntries.add(TestDataFactory.createPricebookEntry(products[2].Id, 25000));  // Implementation Services
pricebookEntries.add(TestDataFactory.createPricebookEntry(products[3].Id, 15000));  // Training Services
pricebookEntries.add(TestDataFactory.createPricebookEntry(products[4].Id, 12000));  // Premium Support
insert pricebookEntries;
System.debug('Created ' + pricebookEntries.size() + ' pricebook entries');

// Create opportunity line items
List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();

// For New Sales Opportunity - Full suite
opportunityLineItems.add(TestDataFactory.createOpportunityLineItem(opportunities[0].Id, products[0].Id, pricebookEntries[0].Id, 5, 100000));
opportunityLineItems.add(TestDataFactory.createOpportunityLineItem(opportunities[0].Id, products[2].Id, pricebookEntries[2].Id, 1, 25000));

// For Renewal Opportunity - Standard license
opportunityLineItems.add(TestDataFactory.createOpportunityLineItem(opportunities[1].Id, products[1].Id, pricebookEntries[1].Id, 5, 50000));
opportunityLineItems.add(TestDataFactory.createOpportunityLineItem(opportunities[1].Id, products[4].Id, pricebookEntries[4].Id, 1, 12000));

// For Academic Opportunity - Discounted standard
OpportunityLineItem academicOLI = TestDataFactory.createOpportunityLineItem(opportunities[2].Id, products[1].Id, pricebookEntries[1].Id, 1, 50000);
academicOLI.Discount = 40; // Academic discount
opportunityLineItems.add(academicOLI);
opportunityLineItems.add(TestDataFactory.createOpportunityLineItem(opportunities[2].Id, products[3].Id, pricebookEntries[3].Id, 1, 15000));

// For Enterprise Opportunity - Large volume
opportunityLineItems.add(TestDataFactory.createOpportunityLineItem(opportunities[3].Id, products[0].Id, pricebookEntries[0].Id, 12, 100000));
opportunityLineItems.add(TestDataFactory.createOpportunityLineItem(opportunities[3].Id, products[2].Id, pricebookEntries[2].Id, 1, 25000));
opportunityLineItems.add(TestDataFactory.createOpportunityLineItem(opportunities[3].Id, products[4].Id, pricebookEntries[4].Id, 1, 12000));

insert opportunityLineItems;
System.debug('Created ' + opportunityLineItems.size() + ' opportunity line items');

// Create quotes for testing different scenarios
List<Quote> quotes = new List<Quote>();

// Quote 1: Draft status - ready for editing and testing
Quote draftQuote = TestDataFactory.createQuote(opportunities[0].Id, 'Acme Software Quote - Draft');
draftQuote.Status = 'Draft';
draftQuote.Billing_Frequency__c = 'Annually';
draftQuote.Contract_Signer__c = contacts[0].Id;
draftQuote.Billing_Contact__c = contacts[1].Id;
draftQuote.ExpirationDate = Date.today().addDays(30);
quotes.add(draftQuote);

// Quote 2: Needs Review status - ready for approval workflow testing
Quote reviewQuote = TestDataFactory.createQuote(opportunities[1].Id, 'Global Tech Renewal - Needs Review');
reviewQuote.Status = 'Needs Review';
reviewQuote.Billing_Frequency__c = 'Monthly';
reviewQuote.Contract_Signer__c = contacts[2].Id;
reviewQuote.Billing_Contact__c = contacts[3].Id;
reviewQuote.ExpirationDate = Date.today().addDays(45);
// Total_Amount__c field may not exist - removing this line
// reviewQuote.Total_Amount__c = 262000;
quotes.add(reviewQuote);

// Quote 3: Academic quote with special pricing
Quote academicQuote = TestDataFactory.createQuote(opportunities[2].Id, 'NextGen Bio Research Quote');
academicQuote.Status = 'Draft';
academicQuote.Billing_Frequency__c = 'Annually';
academicQuote.Contract_Signer__c = contacts[4].Id;
academicQuote.Billing_Contact__c = contacts[5].Id;
academicQuote.ExpirationDate = Date.today().addDays(60);
quotes.add(academicQuote);

// Quote 4: High-value enterprise quote
Quote enterpriseQuote = TestDataFactory.createQuote(opportunities[3].Id, 'Enterprise Cloud Multi-Year');
enterpriseQuote.Status = 'Draft';
enterpriseQuote.Billing_Frequency__c = 'Quarterly';
enterpriseQuote.Contract_Signer__c = contacts[6].Id;
enterpriseQuote.Billing_Contact__c = contacts[7].Id;
enterpriseQuote.ExpirationDate = Date.today().addDays(21);
quotes.add(enterpriseQuote);

insert quotes;
System.debug('Created ' + quotes.size() + ' test quotes');

// Create quote line items with realistic scenarios
List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();

// Quote 1 Line Items - Enterprise with services
quoteLineItems.add(TestDataFactory.createQuoteLineItem(quotes[0].Id, products[0].Id, pricebookEntries[0].Id, 5, 100000));
QuoteLineItem serviceQLI1 = TestDataFactory.createQuoteLineItem(quotes[0].Id, products[2].Id, pricebookEntries[2].Id, 1, 25000);
serviceQLI1.Service_Start_Date__c = Date.today().addDays(30);
serviceQLI1.Service_End_Date__c = Date.today().addDays(60);
quoteLineItems.add(serviceQLI1);

// Quote 2 Line Items - Renewal scenario
QuoteLineItem renewalQLI = TestDataFactory.createQuoteLineItem(quotes[1].Id, products[1].Id, pricebookEntries[1].Id, 5, 50000);
renewalQLI.Service_Start_Date__c = Date.today().addDays(60);
renewalQLI.Service_End_Date__c = Date.today().addDays(425); // One year
quoteLineItems.add(renewalQLI);
quoteLineItems.add(TestDataFactory.createQuoteLineItem(quotes[1].Id, products[4].Id, pricebookEntries[4].Id, 1, 12000));

// Quote 3 Line Items - Academic with discount
QuoteLineItem academicQLI = TestDataFactory.createQuoteLineItem(quotes[2].Id, products[1].Id, pricebookEntries[1].Id, 1, 50000);
academicQLI.Discount = 40;
academicQLI.Service_Start_Date__c = Date.today().addDays(90);
academicQLI.Service_End_Date__c = Date.today().addDays(455);
quoteLineItems.add(academicQLI);

// Quote 4 Line Items - High volume enterprise
QuoteLineItem enterpriseQLI = TestDataFactory.createQuoteLineItem(quotes[3].Id, products[0].Id, pricebookEntries[0].Id, 12, 100000);
enterpriseQLI.Service_Start_Date__c = Date.today().addDays(15);
enterpriseQLI.Service_End_Date__c = Date.today().addDays(1110); // Three years
quoteLineItems.add(enterpriseQLI);
quoteLineItems.add(TestDataFactory.createQuoteLineItem(quotes[3].Id, products[2].Id, pricebookEntries[2].Id, 1, 25000));

insert quoteLineItems;
System.debug('Created ' + quoteLineItems.size() + ' quote line items');

System.debug('=== UI TEST DATA CREATION COMPLETE ===');
System.debug('Accounts: ' + accounts.size());
System.debug('Contacts: ' + contacts.size()); 
System.debug('Opportunities: ' + opportunities.size());
System.debug('Products: ' + products.size());
System.debug('Quotes: ' + quotes.size());
System.debug('Quote Line Items: ' + quoteLineItems.size());
System.debug('Ready for comprehensive UI testing!');

// Output quote IDs for easy reference
System.debug('=== QUOTE IDS FOR UI TESTING ===');
for(Quote q : quotes) {
    System.debug('Quote: ' + q.Name + ' (ID: ' + q.Id + ', Status: ' + q.Status + ')');
}
