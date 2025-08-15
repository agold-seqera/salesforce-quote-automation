# Quote System - Complete Field Inventory

| Field Label | Field API Name | sObject | Description | Field Type | Formula | How the field is populated |
|-------------|---------------|---------|-------------|------------|---------|---------------------------|
| Exchange Rate at Creation | Exchange_Rate_at_Creation__c | Quote | Frozen exchange rate for currency consistency | Number(16,6) | | Flow E + ExchangeRateManager |
| Order Start Date | Order_Start_Date__c | Quote | Service period start (inherits from Opportunity) | Date | | Flow E from Contract_Start_Date__c |
| Order End Date | Order_End_Date__c | Quote | Service period end (inherits from Opportunity) | Date | | Flow E from Contract_End_Date__c |
| Term Length Months | Term_Length_Months__c | Quote | Calculated term length with decimal precision | Number(3,1) | | Flow E calculation |
| Ready for Sync | Ready_for_Sync__c | Quote | Controls when quote can sync to Opportunity | Checkbox | | User controlled |
| Auto Create Line Items | Auto_Create_Line_Items__c | Quote | Triggers QLI creation from Opportunity products | Checkbox | | User controlled |
| First Payment Due | First_Payment_Due__c | Quote | First payment based on billing frequency | Currency(16,2) | | Auto-calculated |
| Converted Currency Total | Converted_Currency_Total__c | Quote | Quote total in corporate currency | Currency(16,2) | | Auto-calculated |
| Annual Total | Annual_Total__c | Quote | Sum of subscription Annual_Amount__c values | Currency(16,2) | | Flow B calculated |
| One Off Charges | One_Off_Charges__c | Quote | Sum of non-subscription TotalPrice values | Currency(16,2) | | Flow B calculated |
| Total Payment Due | Total_Payment_Due__c | Quote | Sum of all billing amounts | Currency(16,2) | | Flow B calculated |
| Approval Status | Approval_Status__c | Quote | Quote approval status | | | |
| Currency ISO Code | CurrencyIsoCode | Quote | Standard Salesforce currency field | Picklist | | Standard Salesforce |
| Annual Amount | Annual_Amount__c | QuoteLineItem | Annualized subscription value from OLI | Currency(16,2) | | Flow D from OLI.TotalPrice |
| Total Price Custom | Total_Price__c | QuoteLineItem | Calculated prorated billing amount | Currency(16,2) | | Trigger handler calculated |
| Service Start Date | Service_Start_Date__c | QuoteLineItem | Line-level service start override | Date | | User entered |
| Service End Date | Service_End_Date__c | QuoteLineItem | Line-level service end override | Date | | User entered |
| Effective Start Date | Effective_Start_Date__c | QuoteLineItem | Prioritizes line dates over quote dates | Date | `IF(NOT(ISBLANK(Service_Start_Date__c)), Service_Start_Date__c, Quote.Order_Start_Date__c)` | Auto-calculated hierarchy |
| Effective End Date | Effective_End_Date__c | QuoteLineItem | Prioritizes line dates over quote dates | Date | `IF(NOT(ISBLANK(Service_End_Date__c)), Service_End_Date__c, Quote.Order_End_Date__c)` | Auto-calculated hierarchy |
| Service Period Days | Service_Period_Days__c | QuoteLineItem | Days between effective dates | Number(5,0) | | Auto-calculated |
| Service Year Is Leap | Service_Year_Is_Leap__c | QuoteLineItem | Detects if service period spans Feb 29 | Checkbox | `AND(MOD(YEAR(Effective_Start_Date__c), 4) = 0, OR(MOD(YEAR(Effective_Start_Date__c), 400) = 0, MOD(YEAR(Effective_Start_Date__c), 100) <> 0), Effective_Start_Date__c <= DATE(YEAR(Effective_Start_Date__c), 2, 29), Effective_End_Date__c >= DATE(YEAR(Effective_Start_Date__c), 2, 29))` | Auto-calculated |
| Days In Service Year | Days_In_Service_Year__c | QuoteLineItem | Returns 365 or 366 for accurate division | Number(3,0) | | Auto-calculated |
| Term Length Months | Term_Length_Months__c | QuoteLineItem | Calculated term length with decimal precision based on effective dates | Number(3,1) | `MAX(1, ROUND((Effective_End_Date__c - Effective_Start_Date__c) / 30.44, 0))` | Auto-calculated from effective date range |
| Product Family | Product_Family__c | QuoteLineItem | Product categorization for billing logic | | | |
| Total Price | TotalPrice | QuoteLineItem | Standard Salesforce calculated field | Currency | | Standard Salesforce (Quantity × UnitPrice) |
| Quantity | Quantity | QuoteLineItem | Standard quantity field | Number | | User entered |
| Unit Price | UnitPrice | QuoteLineItem | Standard unit price field | Currency | | User entered |
| Product2 Id | Product2Id | QuoteLineItem | Standard product lookup | Lookup | | User selected |
| Pricebook Entry Id | PricebookEntryId | QuoteLineItem | Standard pricebook entry lookup | Lookup | | Standard Salesforce |
| Description | Description | QuoteLineItem | Standard description field | Text | | User entered |
| Service Date | ServiceDate | QuoteLineItem | Standard service date field | Date | | User entered |
| Discount | Discount | QuoteLineItem | Standard discount field | Percent | | User entered |
| Billing Amount | Billing_Amount__c | OpportunityLineItem | Actual prorated billing amount from synced QLI | Currency(16,2) | | Flow F sync process |
| Term Start Date | Term_Start_Date__c | OpportunityLineItem | Service term start date from Quote Line Item | Date | | Flow F sync process |
| Term End Date | Term_End_Date__c | OpportunityLineItem | Service term end date from Quote Line Item | Date | | Flow F sync process |
| Term Length Months | Term_Length_Months__c | OpportunityLineItem | Term length in months from Quote Line Item | Number(3,1) | | Flow F sync process |
| Total Price | TotalPrice | OpportunityLineItem | Standard total price field | Currency | | Standard Salesforce |
| Product2 Id | Product2Id | OpportunityLineItem | Standard product lookup | Lookup | | Standard Salesforce |
| Quantity | Quantity | OpportunityLineItem | Standard quantity field | Number | | User entered |
| Unit Price | UnitPrice | OpportunityLineItem | Standard unit price field | Currency | | User entered |
| Description | Description | OpportunityLineItem | Standard description field | Text | | User entered |
| Service Date | ServiceDate | OpportunityLineItem | Standard service date field | Date | | User entered |
| Contract Start Date | Contract_Start_Date__c | Opportunity | Contract period start date | Date | | |
| Contract End Date | Contract_End_Date__c | Opportunity | Contract period end date | Date | | |
| Contract End Date Override | Contract_End_Date_Override__c | Opportunity | Override for contract end date | Date | | |
| Term Length Months | Term_Length_Months__c | Opportunity | Contract term length in months | Number(3,1) | | |
| Product Family | Product_Family__c | Product2 | Product categorization field | Picklist | | |
| Family | Family | Product2 | Standard product family field | Picklist | | Standard Salesforce |
| Customer Logo Use | | Account | | | | |
| Role | Role | OpportunityContactRole | Standard role field | Picklist | | Standard Salesforce |
| Primary Contact | | OpportunityContactRole | | | | |
| ISO Code | IsoCode | DatedConversionRate | Currency ISO code | Text | | Standard Salesforce |
| Conversion Rate | ConversionRate | DatedConversionRate | Exchange rate value | Number | | Standard Salesforce |
| Start Date | StartDate | DatedConversionRate | Rate effective start date | Date | | Standard Salesforce |
| Next Start Date | NextStartDate | DatedConversionRate | Next rate effective date | Date | | Standard Salesforce |