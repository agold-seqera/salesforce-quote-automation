// UI Demo Data Refresh Script for agdev org
// Cleans up existing demo data and creates fresh comprehensive data
// Execute in Execute Anonymous in Salesforce Developer Console

System.debug('Starting UI Demo Data Refresh...');

// Clean up existing demo data first
try {
    // Delete existing demo quotes and related data
    List<Quote> existingQuotes = [SELECT Id FROM Quote WHERE Name LIKE '%Demo%' OR Name LIKE '%Test%' OR Name LIKE '%Acme%' OR Name LIKE '%Global Tech%' OR Name LIKE '%NextGen%' OR Name LIKE '%Enterprise Cloud%'];
    if (!existingQuotes.isEmpty()) {
        delete existingQuotes;
        System.debug('Deleted ' + existingQuotes.size() + ' existing demo quotes');
    }
    
    // Delete existing demo opportunities
    List<Opportunity> existingOpps = [SELECT Id FROM Opportunity WHERE Name LIKE '%Demo%' OR Name LIKE '%Test%' OR Name LIKE '%Acme%' OR Name LIKE '%Global Tech%' OR Name LIKE '%NextGen%' OR Name LIKE '%Enterprise Cloud%'];
    if (!existingOpps.isEmpty()) {
        delete existingOpps;
        System.debug('Deleted ' + existingOpps.size() + ' existing demo opportunities');
    }
    
    // Delete existing demo accounts
    List<Account> existingAccounts = [SELECT Id FROM Account WHERE Name LIKE '%Demo%' OR Name LIKE '%Test%' OR Name LIKE '%Acme%' OR Name LIKE '%Global Tech%' OR Name LIKE '%NextGen%' OR Name LIKE '%Enterprise Cloud%'];
    if (!existingAccounts.isEmpty()) {
        delete existingAccounts;
        System.debug('Deleted ' + existingAccounts.size() + ' existing demo accounts');
    }
    
} catch (Exception e) {
    System.debug('Cleanup note: ' + e.getMessage());
}

// Create fresh demo data
System.debug('Creating fresh demo data...');

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
        Email = 'john.smith@' + acc.Name.toLowerCase().replace(' ', '') + '.com',
        Title = 'CTO'
    ));
    contacts.add(new Contact(
        AccountId = acc.Id,
        FirstName = 'Sarah',
        LastName = 'Johnson',
        Email = 'sarah.johnson@' + acc.Name.toLowerCase().replace(' ', '') + '.com',
        Title = 'VP Engineering'
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
    StageName = 'Negotiations/Contracting',
    CloseDate = Date.today().addDays(45),
    Contract_Start_Date__c = Date.today().addDays(30),
    Type = 'Commercial',
    LeadSource = 'AE Outreach',
    NextStep = 'Final contract negotiation'
);
opportunities.add(newSalesOpp);

// Scenario 2: Existing Customer Renewal
Opportunity renewalOpp = new Opportunity(
    Name = 'Global Tech - Annual Renewal',
    AccountId = accounts[1].Id,
    Amount = 250000,
    StageName = 'Validation',
    CloseDate = Date.today().addDays(30),
    Contract_Start_Date__c = Date.today().addDays(60),
    Type = 'Commercial',
    LeadSource = 'AE Outreach',
    NextStep = 'Internal validation and approval'
);
opportunities.add(renewalOpp);

// Scenario 3: Academic Opportunity (Lower Amount)
Opportunity academicOpp = new Opportunity(
    Name = 'NextGen Bio - Research License',
    AccountId = accounts[2].Id,
    Amount = 75000,
    StageName = 'Discovery',
    CloseDate = Date.today().addDays(60),
    Contract_Start_Date__c = Date.today().addDays(90),
    Type = 'Academic',
    LeadSource = 'AE Outreach',
    NextStep = 'Technical requirements gathering'
);
opportunities.add(academicOpp);

// Scenario 4: Enterprise Deal (High Value)
Opportunity enterpriseOpp = new Opportunity(
    Name = 'Enterprise Cloud - Multi-Year Deal',
    AccountId = accounts[3].Id,
    Amount = 1200000,
    StageName = 'Qualification',
    CloseDate = Date.today().addDays(21),
    Contract_Start_Date__c = Date.today().addDays(15),
    Type = 'Commercial',
    LeadSource = 'AE Outreach',
    NextStep = 'Stakeholder alignment meeting'
);
opportunities.add(enterpriseOpp);

insert opportunities;
System.debug('Created ' + opportunities.size() + ' demo opportunities');

// Create opportunity contact roles aligned with Quote System requirements
// Using exact role names from TestDataFactory.cls and Quote Before Save flow
List<OpportunityContactRole> contactRoles = new List<OpportunityContactRole>();

// For each opportunity, assign the 3 key quote contact roles
Integer contactIndex = 0;
for(Opportunity opp : opportunities) {
    // Primary contact - exact role name the flow expects
    contactRoles.add(new OpportunityContactRole(
        OpportunityId = opp.Id,
        ContactId = contacts[contactIndex].Id,
        Role = 'Primary Contact',
        IsPrimary = true
    ));
    
    // Invoice contact - exact role name the flow expects  
    contactRoles.add(new OpportunityContactRole(
        OpportunityId = opp.Id,
        ContactId = contacts[contactIndex + 1].Id,
        Role = 'Invoice Contact',
        IsPrimary = false
    ));
    
    // Legal contact - exact role name the flow expects
    // For demo purposes, create a third role using the first contact
    contactRoles.add(new OpportunityContactRole(
        OpportunityId = opp.Id,
        ContactId = contacts[contactIndex].Id, // Reuse primary contact for legal role demo
        Role = 'Legal Contact',
        IsPrimary = false
    ));
    
    contactIndex += 2; // Move to next account's contacts
}

insert contactRoles;
System.debug('Created ' + contactRoles.size() + ' opportunity contact roles');

// Create diverse products for testing (only if they don't exist)
List<Product2> existingProducts = [SELECT Id, Name FROM Product2 WHERE Name LIKE 'Seqera Platform%' OR Name LIKE 'Professional Services%' OR Name LIKE 'Premium Support%'];
List<Product2> products = new List<Product2>();

if (existingProducts.isEmpty()) {
    products.add(new Product2(Name = 'Seqera Platform Enterprise', Family = 'Software Subscriptions', IsActive = true));
    products.add(new Product2(Name = 'Seqera Platform Standard', Family = 'Software Subscriptions', IsActive = true));
    products.add(new Product2(Name = 'Professional Services - Implementation', Family = 'Professional Services', IsActive = true));
    products.add(new Product2(Name = 'Professional Services - Training', Family = 'Professional Services', IsActive = true));
    products.add(new Product2(Name = 'Premium Support', Family = 'Support', IsActive = true));
    insert products;
    System.debug('Created ' + products.size() + ' demo products');
} else {
    products = existingProducts;
    System.debug('Using ' + products.size() + ' existing products');
}

// Get standard pricebook ID
Id standardPricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;

// Create pricebook entries (only if they don't exist)
List<PricebookEntry> existingPBEs = [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :products AND Pricebook2Id = :standardPricebookId];
Map<Id, PricebookEntry> productToPBE = new Map<Id, PricebookEntry>();
for (PricebookEntry pbe : existingPBEs) {
    productToPBE.put(pbe.Product2Id, pbe);
}

List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
Decimal[] prices = new Decimal[]{100000, 50000, 25000, 15000, 12000};

for (Integer i = 0; i < products.size(); i++) {
    if (!productToPBE.containsKey(products[i].Id)) {
        pricebookEntries.add(new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = products[i].Id,
            UnitPrice = prices[i],
            IsActive = true
        ));
    }
}

if (!pricebookEntries.isEmpty()) {
    insert pricebookEntries;
    System.debug('Created ' + pricebookEntries.size() + ' new pricebook entries');
    
    // Refresh the map
    for (PricebookEntry pbe : pricebookEntries) {
        productToPBE.put(pbe.Product2Id, pbe);
    }
} else {
    System.debug('Using existing pricebook entries');
}

// Create opportunity line items
List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();

// For New Sales Opportunity - Full suite
opportunityLineItems.add(new OpportunityLineItem(
    OpportunityId = opportunities[0].Id,
    Product2Id = products[0].Id,
    PricebookEntryId = productToPBE.get(products[0].Id).Id,
    Quantity = 5,
    UnitPrice = 100000
));

// For Renewal Opportunity - Standard license
opportunityLineItems.add(new OpportunityLineItem(
    OpportunityId = opportunities[1].Id,
    Product2Id = products[1].Id,
    PricebookEntryId = productToPBE.get(products[1].Id).Id,
    Quantity = 5,
    UnitPrice = 50000
));

// For Academic Opportunity - Discounted standard
OpportunityLineItem academicOLI = new OpportunityLineItem(
    OpportunityId = opportunities[2].Id,
    Product2Id = products[1].Id,
    PricebookEntryId = productToPBE.get(products[1].Id).Id,
    Quantity = 1,
    UnitPrice = 50000,
    Discount = 40 // Academic discount
);
opportunityLineItems.add(academicOLI);

// For Enterprise Opportunity - Large volume
opportunityLineItems.add(new OpportunityLineItem(
    OpportunityId = opportunities[3].Id,
    Product2Id = products[0].Id,
    PricebookEntryId = productToPBE.get(products[0].Id).Id,
    Quantity = 12,
    UnitPrice = 100000
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
    Primary_Customer_Contact__c = contacts[0].Id,
    Billing_Contact__c = contacts[1].Id,
    Customer_Legal_Notice_Contact__c = contacts[0].Id,
    ExpirationDate = Date.today().addDays(30)
);
quotes.add(draftQuote);

// Quote 2: Needs Review status - ready for approval workflow testing
Quote reviewQuote = new Quote(
    Name = 'Global Tech Renewal - Needs Review',
    OpportunityId = opportunities[1].Id,
    Pricebook2Id = standardPricebookId,
    Status = 'Draft', // Start as Draft, then update to Needs Review
    Billing_Frequency__c = 'Monthly',
    Primary_Customer_Contact__c = contacts[2].Id,
    Billing_Contact__c = contacts[3].Id,
    Customer_Legal_Notice_Contact__c = contacts[2].Id,
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
    Primary_Customer_Contact__c = contacts[4].Id,
    Billing_Contact__c = contacts[5].Id,
    Customer_Legal_Notice_Contact__c = contacts[4].Id,
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
    Primary_Customer_Contact__c = contacts[6].Id,
    Billing_Contact__c = contacts[7].Id,
    Customer_Legal_Notice_Contact__c = contacts[6].Id,
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
    PricebookEntryId = productToPBE.get(products[0].Id).Id,
    Quantity = 5,
    UnitPrice = 100000
));

// Quote 2 Line Items - Renewal scenario
QuoteLineItem renewalQLI = new QuoteLineItem(
    QuoteId = quotes[1].Id,
    Product2Id = products[1].Id,
    PricebookEntryId = productToPBE.get(products[1].Id).Id,
    Quantity = 5,
    UnitPrice = 50000,
    Service_Start_Date__c = Date.today().addDays(60),
    Service_End_Date__c = Date.today().addDays(425) // One year
);
quoteLineItems.add(renewalQLI);

// Quote 3 Line Items - Academic with discount
QuoteLineItem academicQLI = new QuoteLineItem(
    QuoteId = quotes[2].Id,
    Product2Id = products[1].Id,
    PricebookEntryId = productToPBE.get(products[1].Id).Id,
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
    PricebookEntryId = productToPBE.get(products[0].Id).Id,
    Quantity = 12,
    UnitPrice = 100000,
    Service_Start_Date__c = Date.today().addDays(15),
    Service_End_Date__c = Date.today().addDays(1110) // Three years
);
quoteLineItems.add(enterpriseQLI);

insert quoteLineItems;
System.debug('Created ' + quoteLineItems.size() + ' quote line items');

System.debug('=== UI DEMO DATA REFRESH COMPLETE ===');
System.debug('Accounts: ' + accounts.size());
System.debug('Contacts: ' + contacts.size()); 
System.debug('Contact Roles: ' + contactRoles.size() + ' (Primary Contact, Invoice Contact, Legal Contact for each opp)');
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
