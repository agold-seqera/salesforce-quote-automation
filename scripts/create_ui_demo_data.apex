// UI Demo Data Creation Script for agdev org
// Creates comprehensive demo data for Quote System UI testing
// Execute in Execute Anonymous in Salesforce Developer Console

System.debug('Starting UI Demo Data Creation...');

// Create test accounts for different scenarios
List<Account> accounts = new List<Account>();
accounts.add(new Account(Name = 'Acme Software Solutions', Type = 'Customer - Direct'));
accounts.add(new Account(Name = 'Global Tech Enterprises', Type = 'Customer - Channel')); 
accounts.add(new Account(Name = 'NextGen Bio Labs', Type = 'Prospect'));
accounts.add(new Account(Name = 'Enterprise Cloud Corp', Type = 'Customer - Direct'));
insert accounts;
System.debug('Created ' + accounts.size() + ' demo accounts');

// Create contacts for each account
List<Contact> contacts = new List<Contact>();
for(Account acc : accounts) {
    contacts.add(new Contact(
        AccountId = acc.Id,
        FirstName = 'John',
        LastName = 'Smith',
        Email = 'john.smith@' + acc.Name.toLowerCase().replace(' ', '') + '.com'
    ));
    contacts.add(new Contact(
        AccountId = acc.Id,
        FirstName = 'Sarah',
        LastName = 'Johnson',
        Email = 'sarah.johnson@' + acc.Name.toLowerCase().replace(' ', '') + '.com'
    ));
}
insert contacts;
System.debug('Created ' + contacts.size() + ' demo contacts');

// Create opportunities for different scenarios
List<Opportunity> opportunities = new List<Opportunity>();

// Scenario 1: New Sales Opportunity (Large Deal)
Opportunity newSalesOpp = new Opportunity(
    Name = 'Acme Software - Platform License',
    AccountId = accounts[0].Id,
    Amount = 500000,
    StageName = 'Proposal',
    CloseDate = Date.today().addDays(45),
    Contract_Start_Date__c = Date.today().addDays(30)
);
opportunities.add(newSalesOpp);

// Scenario 2: Existing Customer Renewal
Opportunity renewalOpp = new Opportunity(
    Name = 'Global Tech - Annual Renewal',
    AccountId = accounts[1].Id,
    Amount = 250000,
    StageName = 'Negotiation',
    CloseDate = Date.today().addDays(30),
    Contract_Start_Date__c = Date.today().addDays(60)
);
opportunities.add(renewalOpp);

// Scenario 3: Academic Opportunity (Lower Amount)
Opportunity academicOpp = new Opportunity(
    Name = 'NextGen Bio - Research License',
    AccountId = accounts[2].Id,
    Amount = 75000,
    StageName = 'Discovery',
    CloseDate = Date.today().addDays(60),
    Contract_Start_Date__c = Date.today().addDays(90)
);
opportunities.add(academicOpp);

// Scenario 4: Enterprise Deal (High Value)
Opportunity enterpriseOpp = new Opportunity(
    Name = 'Enterprise Cloud - Multi-Year Deal',
    AccountId = accounts[3].Id,
    Amount = 1200000,
    StageName = 'Proposal',
    CloseDate = Date.today().addDays(21),
    Contract_Start_Date__c = Date.today().addDays(15)
);
opportunities.add(enterpriseOpp);

insert opportunities;
System.debug('Created ' + opportunities.size() + ' demo opportunities');

// Create opportunity contact roles for realistic sales scenarios
List<OpportunityContactRole> contactRoles = new List<OpportunityContactRole>();

// For each opportunity, assign contact roles
Integer contactIndex = 0;
for(Opportunity opp : opportunities) {
    // Primary contact (Decision Maker)
    contactRoles.add(new OpportunityContactRole(
        OpportunityId = opp.Id,
        ContactId = contacts[contactIndex].Id,
        Role = 'Decision Maker',
        IsPrimary = true
    ));
    
    // Secondary contact (Influencer)
    contactRoles.add(new OpportunityContactRole(
        OpportunityId = opp.Id,
        ContactId = contacts[contactIndex + 1].Id,
        Role = 'Influencer',
        IsPrimary = false
    ));
    
    contactIndex += 2; // Move to next account's contacts
}

insert contactRoles;
System.debug('Created ' + contactRoles.size() + ' opportunity contact roles');

// Create diverse products for testing
List<Product2> products = new List<Product2>();
products.add(new Product2(Name = 'Seqera Platform Enterprise', Family = 'Software Subscriptions', IsActive = true));
products.add(new Product2(Name = 'Seqera Platform Standard', Family = 'Software Subscriptions', IsActive = true));
products.add(new Product2(Name = 'Professional Services - Implementation', Family = 'Professional Services', IsActive = true));
products.add(new Product2(Name = 'Professional Services - Training', Family = 'Professional Services', IsActive = true));
products.add(new Product2(Name = 'Premium Support', Family = 'Support', IsActive = true));
insert products;
System.debug('Created ' + products.size() + ' demo products');

// Get standard pricebook ID
Id standardPricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;

// Create pricebook entries
List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
pricebookEntries.add(new PricebookEntry(
    Pricebook2Id = standardPricebookId,
    Product2Id = products[0].Id,
    UnitPrice = 100000,
    IsActive = true
));
pricebookEntries.add(new PricebookEntry(
    Pricebook2Id = standardPricebookId,
    Product2Id = products[1].Id,
    UnitPrice = 50000,
    IsActive = true
));
pricebookEntries.add(new PricebookEntry(
    Pricebook2Id = standardPricebookId,
    Product2Id = products[2].Id,
    UnitPrice = 25000,
    IsActive = true
));
pricebookEntries.add(new PricebookEntry(
    Pricebook2Id = standardPricebookId,
    Product2Id = products[3].Id,
    UnitPrice = 15000,
    IsActive = true
));
pricebookEntries.add(new PricebookEntry(
    Pricebook2Id = standardPricebookId,
    Product2Id = products[4].Id,
    UnitPrice = 12000,
    IsActive = true
));
insert pricebookEntries;
System.debug('Created ' + pricebookEntries.size() + ' pricebook entries');

// Create opportunity line items
List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();

// For New Sales Opportunity - Full suite
opportunityLineItems.add(new OpportunityLineItem(
    OpportunityId = opportunities[0].Id,
    Product2Id = products[0].Id,
    PricebookEntryId = pricebookEntries[0].Id,
    Quantity = 5,
    UnitPrice = 100000
));
opportunityLineItems.add(new OpportunityLineItem(
    OpportunityId = opportunities[0].Id,
    Product2Id = products[2].Id,
    PricebookEntryId = pricebookEntries[2].Id,
    Quantity = 1,
    UnitPrice = 25000
));

// For Renewal Opportunity - Standard license
opportunityLineItems.add(new OpportunityLineItem(
    OpportunityId = opportunities[1].Id,
    Product2Id = products[1].Id,
    PricebookEntryId = pricebookEntries[1].Id,
    Quantity = 5,
    UnitPrice = 50000
));
opportunityLineItems.add(new OpportunityLineItem(
    OpportunityId = opportunities[1].Id,
    Product2Id = products[4].Id,
    PricebookEntryId = pricebookEntries[4].Id,
    Quantity = 1,
    UnitPrice = 12000
));

// For Academic Opportunity - Discounted standard
OpportunityLineItem academicOLI = new OpportunityLineItem(
    OpportunityId = opportunities[2].Id,
    Product2Id = products[1].Id,
    PricebookEntryId = pricebookEntries[1].Id,
    Quantity = 1,
    UnitPrice = 50000,
    Discount = 40 // Academic discount
);
opportunityLineItems.add(academicOLI);
opportunityLineItems.add(new OpportunityLineItem(
    OpportunityId = opportunities[2].Id,
    Product2Id = products[3].Id,
    PricebookEntryId = pricebookEntries[3].Id,
    Quantity = 1,
    UnitPrice = 15000
));

// For Enterprise Opportunity - Large volume
opportunityLineItems.add(new OpportunityLineItem(
    OpportunityId = opportunities[3].Id,
    Product2Id = products[0].Id,
    PricebookEntryId = pricebookEntries[0].Id,
    Quantity = 12,
    UnitPrice = 100000
));
opportunityLineItems.add(new OpportunityLineItem(
    OpportunityId = opportunities[3].Id,
    Product2Id = products[2].Id,
    PricebookEntryId = pricebookEntries[2].Id,
    Quantity = 1,
    UnitPrice = 25000
));

insert opportunityLineItems;
System.debug('Created ' + opportunityLineItems.size() + ' opportunity line items');

// Create quotes for testing different scenarios
List<Quote> quotes = new List<Quote>();

// Quote 1: Draft status - ready for editing and testing
Quote draftQuote = new Quote(
    Name = 'Acme Software Quote - Draft',
    OpportunityId = opportunities[0].Id,
    Pricebook2Id = standardPricebookId,
    Status = 'Draft',
    Billing_Frequency__c = 'Annually',
    Contract_Signer__c = contacts[0].Id,
    Billing_Contact__c = contacts[1].Id,
    ExpirationDate = Date.today().addDays(30)
);
quotes.add(draftQuote);

// Quote 2: Needs Review status - ready for approval workflow testing
Quote reviewQuote = new Quote(
    Name = 'Global Tech Renewal - Needs Review',
    OpportunityId = opportunities[1].Id,
    Pricebook2Id = standardPricebookId,
    Status = 'Needs Review',
    Billing_Frequency__c = 'Monthly',
    Contract_Signer__c = contacts[2].Id,
    Billing_Contact__c = contacts[3].Id,
    ExpirationDate = Date.today().addDays(45)
);
quotes.add(reviewQuote);

// Quote 3: Academic quote with special pricing
Quote academicQuote = new Quote(
    Name = 'NextGen Bio Research Quote',
    OpportunityId = opportunities[2].Id,
    Pricebook2Id = standardPricebookId,
    Status = 'Draft',
    Billing_Frequency__c = 'Annually',
    Contract_Signer__c = contacts[4].Id,
    Billing_Contact__c = contacts[5].Id,
    ExpirationDate = Date.today().addDays(60)
);
quotes.add(academicQuote);

// Quote 4: High-value enterprise quote
Quote enterpriseQuote = new Quote(
    Name = 'Enterprise Cloud Multi-Year',
    OpportunityId = opportunities[3].Id,
    Pricebook2Id = standardPricebookId,
    Status = 'Draft',
    Billing_Frequency__c = 'Quarterly',
    Contract_Signer__c = contacts[6].Id,
    Billing_Contact__c = contacts[7].Id,
    ExpirationDate = Date.today().addDays(21)
);
quotes.add(enterpriseQuote);

insert quotes;
System.debug('Created ' + quotes.size() + ' demo quotes');

// Create quote line items with realistic scenarios
List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();

// Quote 1 Line Items - Enterprise with services
quoteLineItems.add(new QuoteLineItem(
    QuoteId = quotes[0].Id,
    Product2Id = products[0].Id,
    PricebookEntryId = pricebookEntries[0].Id,
    Quantity = 5,
    UnitPrice = 100000
));
QuoteLineItem serviceQLI1 = new QuoteLineItem(
    QuoteId = quotes[0].Id,
    Product2Id = products[2].Id,
    PricebookEntryId = pricebookEntries[2].Id,
    Quantity = 1,
    UnitPrice = 25000,
    Service_Start_Date__c = Date.today().addDays(30),
    Service_End_Date__c = Date.today().addDays(60)
);
quoteLineItems.add(serviceQLI1);

// Quote 2 Line Items - Renewal scenario
QuoteLineItem renewalQLI = new QuoteLineItem(
    QuoteId = quotes[1].Id,
    Product2Id = products[1].Id,
    PricebookEntryId = pricebookEntries[1].Id,
    Quantity = 5,
    UnitPrice = 50000,
    Service_Start_Date__c = Date.today().addDays(60),
    Service_End_Date__c = Date.today().addDays(425) // One year
);
quoteLineItems.add(renewalQLI);
quoteLineItems.add(new QuoteLineItem(
    QuoteId = quotes[1].Id,
    Product2Id = products[4].Id,
    PricebookEntryId = pricebookEntries[4].Id,
    Quantity = 1,
    UnitPrice = 12000
));

// Quote 3 Line Items - Academic with discount
QuoteLineItem academicQLI = new QuoteLineItem(
    QuoteId = quotes[2].Id,
    Product2Id = products[1].Id,
    PricebookEntryId = pricebookEntries[1].Id,
    Quantity = 1,
    UnitPrice = 50000,
    Discount = 40,
    Service_Start_Date__c = Date.today().addDays(90),
    Service_End_Date__c = Date.today().addDays(455)
);
quoteLineItems.add(academicQLI);

// Quote 4 Line Items - High volume enterprise
QuoteLineItem enterpriseQLI = new QuoteLineItem(
    QuoteId = quotes[3].Id,
    Product2Id = products[0].Id,
    PricebookEntryId = pricebookEntries[0].Id,
    Quantity = 12,
    UnitPrice = 100000,
    Service_Start_Date__c = Date.today().addDays(15),
    Service_End_Date__c = Date.today().addDays(1110) // Three years
);
quoteLineItems.add(enterpriseQLI);
quoteLineItems.add(new QuoteLineItem(
    QuoteId = quotes[3].Id,
    Product2Id = products[2].Id,
    PricebookEntryId = pricebookEntries[2].Id,
    Quantity = 1,
    UnitPrice = 25000
));

insert quoteLineItems;
System.debug('Created ' + quoteLineItems.size() + ' quote line items');

System.debug('=== UI DEMO DATA CREATION COMPLETE ===');
System.debug('Accounts: ' + accounts.size());
System.debug('Contacts: ' + contacts.size()); 
System.debug('Contact Roles: ' + contactRoles.size());
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
