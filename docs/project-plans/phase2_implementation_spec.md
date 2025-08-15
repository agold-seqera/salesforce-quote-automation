# Phase 2: Flow Automation Implementation Specification

**Environment**: seqera--partial.sandbox.my.salesforce.com  
**Phase**: Flow Automation and Integration  
**Implementation**: Cursor Agent (with Syl architecture oversight)  
**Documentation**: Comprehensive logging for admin/developer guide + end user experience  
**Status**: 🚀 **READY FOR IMPLEMENTATION**

---

## 🎯 **IMPLEMENTATION OBJECTIVES**

### **Primary Goals**:
1. **Automate Quote Line Item Creation** from Opportunity Products
2. **Calculate Accurate Billing Amounts** with leap-year precision
3. **Populate Quote Rollup Fields** with Product Family logic
4. **Control Quote-Opportunity Sync** with Ready_for_Sync workflow
5. **Integrate with Existing Automation** seamlessly

### **Success Criteria**:
- ✅ All 6 flows deploy successfully and activate
- ✅ End-to-end quote creation workflow functional
- ✅ Leap-year calculations accurate for billing
- ✅ Product Family rollups calculate correctly
- ✅ Sync control logic works as designed
- ✅ No conflicts with existing Quote automation

---

## 📋 **FLOW IMPLEMENTATION PLAN**

### **Implementation Sequence** (Dependency Order):
1. **Flow A**: Helper Apex Class (if needed)
2. **Flow B**: Quote_Calculate_Rollup_Fields 
3. **Flow C**: QuoteLineItem_Calculate_Billing_Amount
4. **Flow D**: Quote_Create_Line_Items_from_Opportunity
5. **Flow E**: Enhanced Quote_Before_Save_Stamp_Fields
6. **Flow F**: Enhanced Quote_After_Saved_Sync_Approved_Quote
7. **Flow G**: Quote_Update_Exchange_Rates (scheduled)

---

## 🔧 **DETAILED FLOW SPECIFICATIONS**

### **Flow B: Quote_Calculate_Rollup_Fields**
**API Name**: `Quote_Calculate_Rollup_Fields`  
**Type**: Record-Triggered Flow  
**Object**: QuoteLineItem  
**Trigger**: After Save, After Delete, After Update  

#### **Trigger Conditions**:
```
Run the flow when: A record is created or updated or deleted
```

#### **Entry Conditions**:
```
None (always run for QLI changes)
```

#### **Flow Elements**:

**Get Records - Quote Line Items**:
- **API Name**: `Get_Quote_Line_Items`
- **Object**: QuoteLineItem
- **Filter**: `QuoteId = {$Record.QuoteId}`
- **Fields to Get**: `Annual_Amount__c`, `TotalPrice`, `Product_Family__c`
- **Store in**: `varQLICollection`

**Assignment - Initialize Variables**:
- **API Name**: `Initialize_Calculation_Variables`
- **Variables**:
  - `varAnnualTotal` (Currency) = 0
  - `varOneOffCharges` (Currency) = 0  
  - `varTotalPaymentDue` (Currency) = 0

**Loop - Calculate Totals**:
- **API Name**: `Loop_Calculate_Quote_Totals`
- **Collection**: `varQLICollection`
- **Direction**: First item to last item

**Decision - Product Family Check** (Inside Loop):
- **API Name**: `Decision_Product_Family_Check`
- **Condition 1**: `{Loop_Calculate_Quote_Totals.Product_Family__c} Equals Software Subscriptions`
  - **Action**: Assignment - Add to Annual Total
    - `varAnnualTotal = {varAnnualTotal} + {Loop_Calculate_Quote_Totals.Annual_Amount__c}`
- **Condition 2**: `{Loop_Calculate_Quote_Totals.Product_Family__c} Not equal to Software Subscriptions AND NOT IsBlank`
  - **Action**: Assignment - Add to One-Off Charges
    - `varOneOffCharges = {varOneOffCharges} + {Loop_Calculate_Quote_Totals.TotalPrice}`
- **Always Execute**: Assignment - Add to Total Payment Due
  - `varTotalPaymentDue = {varTotalPaymentDue} + {Loop_Calculate_Quote_Totals.TotalPrice}`

**Update Records - Quote**:
- **API Name**: `Update_Quote_Rollup_Fields`
- **Object**: Quote
- **Filter**: `Id = {$Record.QuoteId}`
- **Field Values**:
  - `Annual_Total__c = {varAnnualTotal}`
  - `One_Off_Charges__c = {varOneOffCharges}`
  - `Total_Payment_Due__c = {varTotalPaymentDue}`

---

### **Flow C: QuoteLineItem_Calculate_Billing_Amount**
**API Name**: `QuoteLineItem_Calculate_Billing_Amount`  
**Type**: Record-Triggered Flow  
**Object**: QuoteLineItem  
**Trigger**: Before Save  

#### **Entry Conditions**:
```
Product_Family__c = "Software Subscriptions"
```

#### **Flow Elements**:

**Get Records - Quote Information**:
- **API Name**: `Get_Quote_Dates`
- **Object**: Quote
- **Filter**: `Id = {$Record.QuoteId}`
- **Fields**: `Order_Start_Date__c`, `Order_End_Date__c`

**Assignment - Determine Service Dates**:
- **API Name**: `Set_Effective_Service_Dates`
- **Variables**:
  - `varStartDate = IF(ISBLANK({$Record.Service_Start_Date__c}), {Get_Quote_Dates.Order_Start_Date__c}, {$Record.Service_Start_Date__c})`
  - `varEndDate = IF(ISBLANK({$Record.Service_End_Date__c}), {Get_Quote_Dates.Order_End_Date__c}, {$Record.Service_End_Date__c})`

**Decision - Date Validation**:
- **API Name**: `Decision_Valid_Service_Dates`
- **Condition**: `NOT(ISBLANK({varStartDate})) AND NOT(ISBLANK({varEndDate}))`
- **Default Outcome**: Skip calculation (use standard TotalPrice)

**Assignment - Calculate Service Period**:
- **API Name**: `Calculate_Service_Period_Details`
- **Variables**:
  - `varServiceDays = {varEndDate} - {varStartDate} + 1`
  - `varStartYear = YEAR({varStartDate})`
  - `varEndYear = YEAR({varEndDate})`

**Decision - Leap Year Detection**:
- **API Name**: `Decision_Leap_Year_Check`
- **Condition**: Complex leap year formula (reference existing Service_Year_Is_Leap__c logic)
- **True**: `varDaysInYear = 366`
- **False**: `varDaysInYear = 365`

**Assignment - Calculate Billing Amount**:
- **API Name**: `Calculate_Prorated_Amount`
- **Field Update**: `TotalPrice = {$Record.Annual_Amount__c} * ({varServiceDays} / {varDaysInYear})`

---

### **Flow D: Quote_Create_Line_Items_from_Opportunity**
**API Name**: `Quote_Create_Line_Items_from_Opportunity`  
**Type**: Record-Triggered Flow  
**Object**: Quote  
**Trigger**: After Save  

#### **Entry Conditions**:
```
Auto_Create_Line_Items__c = True
```

#### **Flow Elements**:

**Get Records - Opportunity Line Items**:
- **API Name**: `Get_Opportunity_Products`
- **Object**: OpportunityLineItem
- **Filter**: `OpportunityId = {$Record.OpportunityId}`
- **Fields**: All standard fields plus `Product_Family__c`

**Loop - Create Quote Line Items**:
- **API Name**: `Loop_Create_QLI_from_OLI`
- **Collection**: Get_Opportunity_Products
- **Direction**: First item to last item

**Create Records - Quote Line Item** (Inside Loop):
- **API Name**: `Create_Quote_Line_Item`
- **Object**: QuoteLineItem
- **Field Values**:
  - `QuoteId = {$Record.Id}`
  - `Product2Id = {Loop_Create_QLI_from_OLI.Product2Id}`
  - `PricebookEntryId = {Loop_Create_QLI_from_OLI.PricebookEntryId}`
  - `Quantity = {Loop_Create_QLI_from_OLI.Quantity}`
  - `UnitPrice = {Loop_Create_QLI_from_OLI.UnitPrice}`
  - `Annual_Amount__c = {Loop_Create_QLI_from_OLI.TotalPrice}`
  - `Description = {Loop_Create_QLI_from_OLI.Description}`

**Update Records - Reset Flag**:
- **API Name**: `Reset_Auto_Create_Flag`
- **Object**: Quote  
- **Filter**: `Id = {$Record.Id}`
- **Field Values**: `Auto_Create_Line_Items__c = False`

---

### **Flow E: Enhanced Quote_Before_Save_Stamp_Fields**
**Type**: Enhancement to Existing Flow  
**Integration Strategy**: Add new elements to existing flow

#### **New Elements to Add**:

**Decision - Exchange Rate Check**:
- **API Name**: `Decision_Exchange_Rate_Needed`
- **Condition**: `ISBLANK({$Record.Exchange_Rate_at_Creation__c})`
- **True Path**: Get current exchange rate from DatedExchangeRates

**Get Records - Current Exchange Rate**:
- **API Name**: `Get_Current_Exchange_Rate`
- **Object**: DatedConversionRate
- **Filter**: `IsoCode = {$Record.CurrencyIsoCode} AND StartDate <= TODAY() AND (NextStartDate > TODAY() OR NextStartDate = null)`
- **Fields**: `ConversionRate`
- **Store in**: `varCurrentExchangeRate`

**Assignment - Set Exchange Rate**:
- **API Name**: `Set_Frozen_Exchange_Rate`
- **Field Values**: `Exchange_Rate_at_Creation__c = {varCurrentExchangeRate.ConversionRate}`

**Decision - Order Date Check**:
- **API Name**: `Decision_Order_Dates_Needed`  
- **Condition**: `ISBLANK({$Record.Order_Start_Date__c}) OR ISBLANK({$Record.Order_End_Date__c})`
- **True Path**: Get opportunity dates and populate

**Get Records - Opportunity Contract Dates**:
- **API Name**: `Get_Opportunity_Contract_Info`
- **Object**: Opportunity
- **Filter**: `Id = {$Record.OpportunityId}`
- **Fields**: `Contract_Start_Date__c`, `Contract_End_Date__c`

**Assignment - Set Order Dates**:
- **API Name**: `Set_Order_Dates_from_Opportunity`
- **Field Values**:
  - `Order_Start_Date__c = {Get_Opportunity_Contract_Info.Contract_Start_Date__c}`
  - `Order_End_Date__c = {Get_Opportunity_Contract_Info.Contract_End_Date__c}`

---

### **Flow F: Enhanced Quote_After_Saved_Sync_Approved_Quote**
**Type**: Enhancement to Existing Flow  
**Integration Strategy**: Add Ready_for_Sync logic to existing flow

#### **New Elements to Add**:

**Decision - Ready for Sync Check**:
- **API Name**: `Decision_Ready_for_Sync`
- **Condition**: `{$Record.Ready_for_Sync__c} = True AND {$Record.IsSyncing} = False`
- **True Path**: Execute sync logic
- **False Path**: Skip sync

**Update Records - Set Syncing Flag**:
- **API Name**: `Set_Quote_as_Syncing`
- **Object**: Quote
- **Filter**: `Id = {$Record.Id}`
- **Field Values**: `IsSyncing = True`

---

### **Flow G: Quote_Update_Exchange_Rates**
**API Name**: `Quote_Update_Exchange_Rates`  
**Type**: Scheduled Flow  
**Frequency**: Daily at 12:01 AM  

#### **Flow Elements**:

**Get Records - Quotes Without Rates**:
- **API Name**: `Get_Quotes_Needing_Exchange_Rates`
- **Object**: Quote
- **Filter**: `Exchange_Rate_at_Creation__c = null`
- **Fields**: `Id`, `CurrencyIsoCode`

**Loop - Update Exchange Rates**:
- **API Name**: `Loop_Update_Quote_Exchange_Rates`
- **Collection**: Get_Quotes_Needing_Exchange_Rates

**Update Records - Set Exchange Rate** (Inside Loop):
- **API Name**: `Update_Quote_Exchange_Rate`
- **Object**: Quote
- **Filter**: `Id = {Loop_Update_Quote_Exchange_Rates.Id}`
- **Field Values**: `Exchange_Rate_at_Creation__c = 1` (or calculated rate)

---

## 🧪 **TESTING SPECIFICATIONS**

### **Test Scenario 1: Quote Line Item Creation**
**Objective**: Validate auto-creation of QLIs from OLIs

**Steps**:
1. Create Quote from Opportunity with multiple line items
2. Check `Auto_Create_Line_Items__c = True`
3. Save Quote
4. Verify QLIs created with correct Annual_Amount__c values
5. Verify flag reset to False

**Expected Results**:
- QLI count matches OLI count
- Annual_Amount__c = OLI.TotalPrice
- Product associations correct
- Auto flag reset

### **Test Scenario 2: Rollup Calculations**
**Objective**: Validate Product Family rollup logic

**Test Data**:
- QLI 1: Product Family = "Software Subscriptions", Annual_Amount__c = $12,000
- QLI 2: Product Family = "Professional Service", TotalPrice = $5,000
- QLI 3: Product Family = "Software Subscriptions", Annual_Amount__c = $8,000

**Expected Results**:
- Annual_Total__c = $20,000
- One_Off_Charges__c = $5,000
- Total_Payment_Due__c = $25,000

### **Test Scenario 3: Leap Year Billing Calculation**
**Objective**: Validate accurate billing amount calculation

**Test Data**:
- Annual_Amount__c = $36,600 (divisible by 366 for easy testing)
- Service period: Jan 1, 2024 → Dec 31, 2024 (366 days)
- Product Family = "Software Subscriptions"

**Expected Results**:
- TotalPrice = $36,600 (full year in leap year)
- Service_Year_Is_Leap__c = True
- Days_In_Service_Year__c = 366

### **Test Scenario 4: Ready for Sync Workflow**
**Objective**: Validate controlled sync process

**Steps**:
1. Create quote with Ready_for_Sync__c = False
2. Modify quote amounts
3. Verify opportunity unchanged
4. Set Ready_for_Sync__c = True
5. Save quote
6. Verify IsSyncing = True and opportunity updated

---

## 📚 **DOCUMENTATION TRACKING**

### **For Admin/Developer Guide**:
- [ ] Flow architecture diagrams
- [ ] Field dependency mapping
- [ ] Business logic documentation
- [ ] Troubleshooting guide
- [ ] Performance considerations
- [ ] Integration points with existing automation

### **For End User Experience Guide**:
- [ ] Quote creation workflow
- [ ] Line item management process
- [ ] Sync control procedures
- [ ] Field explanations and help text
- [ ] Common scenarios and use cases
- [ ] Error messages and resolutions

### **Implementation Log Requirements**:
- [ ] Complete deployment logs from Cursor
- [ ] Success/failure tracking per flow
- [ ] Performance metrics and timing
- [ ] Issue resolution steps
- [ ] Testing results and validation
- [ ] Configuration screenshots

---

## ⚠️ **CRITICAL SUCCESS FACTORS**

### **Integration Requirements**:
1. **Preserve Existing Automation**: No disruption to current Quote flows
2. **Maintain Data Integrity**: All calculations must be mathematically accurate
3. **Performance Optimization**: Flows must handle realistic data volumes
4. **Error Handling**: Graceful failure and recovery mechanisms
5. **User Experience**: Intuitive workflow with helpful feedback

### **Validation Checkpoints**:
- [ ] All flows activate without errors
- [ ] End-to-end testing passes all scenarios
- [ ] Integration with existing flows confirmed
- [ ] Performance acceptable with test data volumes
- [ ] User access and permissions working
- [ ] Documentation complete and accurate

---

## 🚀 **IMPLEMENTATION AUTHORIZATION**

**Architecture Approved**: ✅ Syl (Architecture Responsibility)  
**Ready for Implementation**: ✅ All prerequisites met  
**Implementation Agent**: Cursor (with detailed logging)  
**Environment**: seqera--partial.sandbox.my.salesforce.com  

**BEGIN PHASE 2 IMPLEMENTATION** 🎯