# Complete Flows Implementation Plan - All 4 Remaining

**Objective**: Complete the original 6-flow architecture as designed  
**Status**: 2/6 flows complete, implementing remaining 4 flows  
**Total Time**: ~70 minutes across 4 implementation sessions  
**Approach**: Sequential implementation with testing between each flow

---

## 🎯 **IMPLEMENTATION SEQUENCE**

### **Session 1: Flow D - Auto-Create Line Items** (15 minutes)
**Foundation**: ✅ Already deployed by Cursor  
**Status**: Trigger and entry condition ready, needs UI completion  
**Priority**: First (highest business value, integrates with existing trigger)

### **Session 2: Flow E - Exchange Rate & Date Management** (20 minutes)  
**Foundation**: Existing `Quote_Before_Save_Stamp_Fields` flow to enhance  
**Status**: Add new elements to existing flow  
**Priority**: Second (currency management foundation)

### **Session 3: Flow F - Sync Control Logic** (20 minutes)
**Foundation**: Existing `Quote_After_Saved_Sync_Approved_Quote` flow to enhance  
**Status**: Add new elements to existing flow  
**Priority**: Third (depends on Flow E for complete functionality)

### **Session 4: Flow G - Scheduled Exchange Rate Updates** (15 minutes)
**Foundation**: Net new scheduled flow  
**Status**: Create from scratch  
**Priority**: Fourth (maintenance feature, depends on Flow E)

---

## 🔧 **SESSION 1: FLOW D IMPLEMENTATION**

### **Flow**: Quote_Create_Line_Items_from_Opportunity
**Current**: Basic structure deployed with trigger (Quote After Save) and entry condition (Auto_Create_Line_Items__c = True)  
**Needs**: Complete the UI logic in Flow Builder

### **Elements to Add**:

**1. Get Records Element**:
- **API Name**: `Get_Opportunity_Products`
- **Object**: OpportunityLineItem
- **Filter**: `OpportunityId = {!$Record.OpportunityId}`
- **Fields**: `Product2Id`, `PricebookEntryId`, `Quantity`, `UnitPrice`, `TotalPrice`, `Description`, `ServiceDate`
- **Store in**: `varOLICollection`

**2. Decision Element**:
- **API Name**: `Check_OLIs_Exist`  
- **Condition**: `{!varOLICollection} IsNull {!$GlobalConstant.False}`
- **True**: Continue to create QLIs
- **False**: Skip to reset flag

**3. Loop Element**:
- **API Name**: `Loop_Create_QLIs`
- **Collection**: `{!varOLICollection}`
- **Direction**: First to last
- **Current Item**: `varCurrentOLI`

**4. Assignment Element (Inside Loop)**:
- **API Name**: `Prepare_QLI_Data`
- **Assignments**:
  - `{!varNewQLI.QuoteId}` = `{!$Record.Id}`
  - `{!varNewQLI.Product2Id}` = `{!varCurrentOLI.Product2Id}`
  - `{!varNewQLI.PricebookEntryId}` = `{!varCurrentOLI.PricebookEntryId}`
  - `{!varNewQLI.Quantity}` = `{!varCurrentOLI.Quantity}`
  - `{!varNewQLI.UnitPrice}` = `{!varCurrentOLI.UnitPrice}`
  - `{!varNewQLI.Annual_Amount__c}` = `{!varCurrentOLI.TotalPrice}`
  - `{!varNewQLI.Description}` = `{!varCurrentOLI.Description}`
  - `{!varNewQLI.ServiceDate}` = `{!varCurrentOLI.ServiceDate}`

**5. Assignment Element (Inside Loop)**:
- **API Name**: `Add_to_Collection`
- **Assignment**: `{!varQLICollection}` = `{!varNewQLI}`

**6. Create Records Element**:
- **API Name**: `Create_Quote_Line_Items`
- **Object**: QuoteLineItem
- **Records**: `{!varQLICollection}`

**7. Update Records Element**:
- **API Name**: `Reset_Auto_Create_Flag`
- **Object**: Quote
- **Filter**: `Id = {!$Record.Id}`
- **Field**: `Auto_Create_Line_Items__c = {!$GlobalConstant.False}`

**Variables Needed**:
- `varNewQLI` (SObject - QuoteLineItem)
- `varQLICollection` (SObject Collection - QuoteLineItem)

---

## 🔧 **SESSION 2: FLOW E IMPLEMENTATION**

### **Flow**: Enhanced Quote_Before_Save_Stamp_Fields  
**Current**: Existing flow handles name/email stamping  
**Action**: Add new elements to existing flow

### **New Elements to Add**:

**1. Decision Element - Exchange Rate Check**:
- **API Name**: `Decision_Exchange_Rate_Needed`
- **Condition**: `ISBLANK({!$Record.Exchange_Rate_at_Creation__c})`
- **True**: Get and set exchange rate
- **False**: Skip rate setting

**2. Get Records Element - Current Exchange Rate**:
- **API Name**: `Get_Current_Exchange_Rate`
- **Object**: DatedConversionRate
- **Filter**: `IsoCode = {!$Record.CurrencyIsoCode} AND StartDate <= TODAY() AND (NextStartDate > TODAY() OR NextStartDate = null)`
- **Fields**: `ConversionRate`
- **Store in**: `varCurrentExchangeRate`

**3. Assignment Element - Set Exchange Rate**:
- **API Name**: `Set_Frozen_Exchange_Rate`
- **Assignment**: `{!$Record.Exchange_Rate_at_Creation__c}` = `{!varCurrentExchangeRate.ConversionRate}`

**4. Decision Element - Order Date Check**:
- **API Name**: `Decision_Order_Dates_Needed`
- **Condition**: `ISBLANK({!$Record.Order_Start_Date__c}) OR ISBLANK({!$Record.Order_End_Date__c})`
- **True**: Get opportunity dates
- **False**: Skip date setting

**5. Get Records Element - Opportunity Contract Dates**:
- **API Name**: `Get_Opportunity_Contract_Info`
- **Object**: Opportunity
- **Filter**: `Id = {!$Record.OpportunityId}`
- **Fields**: `Contract_Start_Date__c`, `Contract_End_Date__c`
- **Store in**: `varOpportunityDates`

**6. Assignment Element - Set Order Dates**:
- **API Name**: `Set_Order_Dates_from_Opportunity`
- **Assignments**:
  - `{!$Record.Order_Start_Date__c}` = `{!varOpportunityDates.Contract_Start_Date__c}`
  - `{!$Record.Order_End_Date__c}` = `{!varOpportunityDates.Contract_End_Date__c}`

**7. Assignment Element - Calculate Term Length**:
- **API Name**: `Calculate_Term_Length`
- **Assignment**: `{!$Record.Term_Length_Months__c}` = `{!formula_TermLengthMonths}`

**Formula Resource**:
- **API Name**: `formula_TermLengthMonths`
- **Formula**: `ROUND(({!$Record.Order_End_Date__c} - {!$Record.Order_Start_Date__c}) / 30.44, 1)`

---

## 🔧 **SESSION 3: FLOW F IMPLEMENTATION**

### **Flow**: Enhanced Quote_After_Saved_Sync_Approved_Quote
**Current**: Existing flow handles opportunity sync on approval  
**Action**: Add new elements to existing flow

### **New Elements to Add**:

**1. Decision Element - Ready for Sync Check**:
- **API Name**: `Decision_Ready_for_Sync`
- **Conditions**: 
  - `{!$Record.Ready_for_Sync__c} = {!$GlobalConstant.True}`
  - `{!$Record.IsSyncing} = {!$GlobalConstant.False}`
- **Logic**: AND
- **True**: Proceed with sync
- **False**: Skip sync

**2. Update Records Element - Set Syncing Flag**:
- **API Name**: `Set_Quote_as_Syncing`
- **Object**: Quote
- **Filter**: `Id = {!$Record.Id}`
- **Field**: `IsSyncing = {!$GlobalConstant.True}`

**3. Decision Element - Term Length Change Check**:
- **API Name**: `Decision_Term_Length_Changed`
- **Condition**: `{!$Record.Term_Length_Months__c} != {!$Record__Prior.Term_Length_Months__c}`
- **True**: Sync term to opportunity
- **False**: Skip term sync

**4. Update Records Element - Sync Term to Opportunity**:
- **API Name**: `Sync_Term_to_Opportunity`
- **Object**: Opportunity
- **Filter**: `Id = {!$Record.OpportunityId}`
- **Field**: `Term_Length_Months__c = {!$Record.Term_Length_Months__c}`

**Integration**: These elements should be added at the beginning of the existing flow, before the current approval logic.

---

## 🔧 **SESSION 4: FLOW G IMPLEMENTATION**

### **Flow**: Quote_Update_Exchange_Rates (New Scheduled Flow)
**Type**: Scheduled Flow  
**Frequency**: Daily at 12:01 AM

### **Complete Flow Structure**:

**1. Start Element**:
- **Type**: Scheduled
- **Frequency**: Daily
- **Time**: 12:01 AM

**2. Get Records Element**:
- **API Name**: `Get_Quotes_Needing_Rates`
- **Object**: Quote
- **Filter**: `Exchange_Rate_at_Creation__c = null`
- **Fields**: `Id`, `CurrencyIsoCode`
- **Store in**: `varQuotesNeedingRates`

**3. Decision Element**:
- **API Name**: `Check_Quotes_Exist`
- **Condition**: `{!varQuotesNeedingRates} IsNull {!$GlobalConstant.False}`
- **True**: Update rates
- **False**: End flow

**4. Loop Element**:
- **API Name**: `Loop_Update_Rates`
- **Collection**: `{!varQuotesNeedingRates}`
- **Current Item**: `varCurrentQuote`

**5. Get Records Element (Inside Loop)**:
- **API Name**: `Get_Rate_for_Currency`
- **Object**: DatedConversionRate
- **Filter**: `IsoCode = {!varCurrentQuote.CurrencyIsoCode} AND StartDate <= TODAY() AND (NextStartDate > TODAY() OR NextStartDate = null)`
- **Fields**: `ConversionRate`
- **Store in**: `varExchangeRate`

**6. Assignment Element (Inside Loop)**:
- **API Name**: `Prepare_Rate_Update`
- **Assignment**: `{!varCurrentQuote.Exchange_Rate_at_Creation__c}` = `{!varExchangeRate.ConversionRate}`

**7. Assignment Element (Inside Loop)**:
- **API Name**: `Add_to_Update_Collection`
- **Assignment**: `{!varQuotesToUpdate}` = `{!varCurrentQuote}`

**8. Update Records Element**:
- **API Name**: `Batch_Update_Exchange_Rates`
- **Object**: Quote
- **Records**: `{!varQuotesToUpdate}`

**Variables Needed**:
- `varQuotesToUpdate` (SObject Collection - Quote)

---

## 🧪 **TESTING PLAN FOR EACH SESSION**

### **Flow D Testing**:
1. Create Quote from Opportunity with multiple OLIs
2. Check `Auto_Create_Line_Items__c = True`
3. Save Quote
4. **Expected**: QLIs created, trigger calculates Total_Price__c, Flow B updates rollups
5. **Verify**: Flag reset to False

### **Flow E Testing**:
1. Create Quote in non-corporate currency without exchange rate
2. Save Quote
3. **Expected**: Exchange_Rate_at_Creation__c populated
4. Create Quote without Order dates
5. **Expected**: Dates inherited from Opportunity

### **Flow F Testing**:
1. Create Quote, set `Ready_for_Sync__c = True`
2. Save Quote
3. **Expected**: `IsSyncing = True`
4. Update Quote term length
5. **Expected**: Term synced back to Opportunity

### **Flow G Testing**:
1. Create Quote with `Exchange_Rate_at_Creation__c = null`
2. Wait for scheduled execution (or test via debug)
3. **Expected**: Exchange rate populated automatically

---

## 📋 **IMPLEMENTATION ORDER & DEPENDENCIES**

**Session 1 (Flow D)**: ✅ **START HERE**
- **No dependencies**: Uses existing fields and trigger
- **High value**: Immediate productivity gain
- **Integration**: Works with existing billing calculation trigger

**Session 2 (Flow E)**: 
- **Dependency**: Multi-currency must be enabled
- **Foundation**: For currency management across other flows

**Session 3 (Flow F)**:
- **Dependency**: Flow E should be complete (for full sync functionality)
- **Integration**: Enhances existing sync behavior

**Session 4 (Flow G)**:
- **Dependency**: Flow E must be complete (maintains what E creates)
- **Maintenance**: Cleanup feature, can be last

**Total Time**: ~70 minutes for complete architecture  
**Approach**: One session at a time with testing between each

Ready to start with **Session 1: Flow D**? 🚀