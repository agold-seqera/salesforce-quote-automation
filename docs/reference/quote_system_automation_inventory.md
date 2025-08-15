# Quote System Automation Inventory

## 🎯 **CURRENT ACTIVE APPROVAL FLOWS (User-Created)**

### **Main Approval Architecture**
| Flow Name | Type | Status | Purpose | Notes |
|-----------|------|--------|---------|-------|
| `Quote_After_Save_Flow_Based_Approval` | Record-Triggered | ✅ **ACTIVE** | Complete approval process logic | Handles all approval paths, admin bypass, and status management |

### **Supporting Subflows**
| Flow Name | Type | Status | Purpose | Notes |
|-----------|------|--------|---------|-------|
| `Quote_Subflow_Set_Quote_Status_to_Approved` | Autolaunched | ✅ **ACTIVE** | Updates quote status to Approved | Called by main approval flow |
| `Quote_Subflow_Set_Quote_Status_to_In_Review` | Autolaunched | ✅ **ACTIVE** | Updates quote status to In Review | Called by main approval flow |
| `Quote_Subflow_Set_Quote_Status_to_Rejected` | Autolaunched | ✅ **ACTIVE** | Updates quote status to Rejected | Called by main approval flow |

## 🗑️ **DEPRECATED FLOWS (Assistant-Created - Deactivated)**

### **Previous Approval Implementation**
| Flow Name | Type | Status | Reason for Deprecation |
|-----------|------|--------|----------------------|
| `Quote_After_Save_Approval_Subflow_Validation` | Autolaunched | 🔴 **DEPRECATED** | Replaced by user's orchestration approach |
| `Quote_After_Save_Approval_Subflow_Process_Selection` | Autolaunched | 🔴 **DEPRECATED** | Replaced by `Quote_After_Save_Flow_Based_Approval` |
| `Quote_After_Save_Approval_Subflow_Submission` | Autolaunched | 🔴 **DEPRECATED** | Replaced by orchestration steps |
| `Quote_After_Save_Approval_Subflow_Notifications` | Autolaunched | 🔴 **DEPRECATED** | Replaced by orchestration native capabilities |
| `Quote_After_Save_Trigger_Approval_Orchestration` | Record-Triggered | 🔴 **DEPRECATED** | Replaced by `Quote_After_Save_Flow_Based_Approval` |
| `Quote_After_Save_Approval_Orchestration_Main` | Autolaunched | 🔴 **DEPRECATED** | Replaced by `Quote_After_Save_Flow_Based_Approval` |

## 🔄 **EXISTING BUSINESS LOGIC FLOWS (Unchanged)**

### **Quote Line Item Processing**
| Flow Name | Type | Status | Purpose |
|-----------|------|--------|---------|
| `Quote_Line_Item_After_Save_Calculate_Rollup_Fields` | Record-Triggered | ✅ **ACTIVE** | Calculate rollup fields on QLI changes |
| `Quote_Line_Item_After_Save_Professional_Services_Flag` | Record-Triggered | ✅ **ACTIVE** | Set professional services flags |
| `QuoteLineItem_Calculate_Billing_Amount` | Autolaunched | ✅ **ACTIVE** | Calculate billing amounts |

### **Quote Management Flows**
| Flow Name | Type | Status | Purpose |
|-----------|------|--------|---------|
| `Quote_After_Save_Create_Line_Items_from_Opportunity` | Record-Triggered | ✅ **ACTIVE** | Auto-create QLIs from Opp Products |
| `Quote_After_Save_Clear_Auto_Created_Line_Items` | Record-Triggered | ✅ **ACTIVE** | Clear auto-created line items |
| `Quote_After_Saved_Sync_Approved_Quote` | Record-Triggered | 🔴 **DEPRECATED** | Automatic sync disabled - now manual only via button |
| `Quote_Before_Save_Stamp_Fields` | Record-Triggered | ✅ **ACTIVE** | Stamp quote fields before save |
| `Quote_Name_Stamp` | Record-Triggered | ✅ **ACTIVE** | Auto-generate quote names |

### **Button/Screen Flows**
| Flow Name | Type | Status | Purpose |
|-----------|------|--------|---------|
| `Quote_Button_Sync_Quote_to_Opportunity` | Screen Flow | ✅ **ACTIVE** | **ONLY** sync method - manual quote to opportunity sync |
| `Quote_Button_Auto_Sync_Line_Items_from_Opportunity` | Screen Flow | ✅ **ACTIVE** | Manual line item sync |
| `Quote_Button_Refresh_Contact_Roles` | Screen Flow | ✅ **ACTIVE** | Refresh contact roles from opportunity |

### **Path Assistants**
| Path Name | Object | Status | Purpose |
|-----------|--------|--------|---------|
| `Default_Opportunity_Path` | Opportunity | ✅ **ACTIVE** | Default opportunity stage guidance |
| `New_Sale_Path` | Opportunity | ✅ **ACTIVE** | New sales opportunity guidance |
| `New_Sales_with_POC` | Opportunity | ✅ **ACTIVE** | POC opportunity stage guidance |
| `Quote_Path` | Quote | ✅ **ACTIVE** | Quote status progression guidance |
| `Existing_Customer_Path` | Opportunity | ✅ **ACTIVE** | **NEW** - Existing customer opportunity guidance |

## 🎯 **NEW APPROVAL PROCESS FLOW**

### **Approval Path Logic:**
1. **Admin Bypass**: System Admin profiles auto-approve
2. **Override Field Logic**:
   - Both overrides = Auto-approve
   - First override only = Ops/Legal approval only  
   - Second override only = Sales approval only
   - No overrides = Dual approval (both Sales + Ops/Legal)

### **Approval Stages:**
1. **Stage 1**: Determine approval process + Set status to "In Review"
2. **Stage 2**: Execute appropriate approval path
3. **Post-Approval**: Update status (Approved/Rejected)

### **Assignees:**
- **Sales Approval**: `joel.hutter@seqera.io.partial`
- **Ops/Legal Approval**: `Ops_Legal_Queue`

## 📋 **VALIDATION RULES STATUS**

| Rule Name | Status | Notes |
|-----------|--------|-------|
| `VR_Draft_to_Needs_Review_Required_Fields` | ✅ **ACTIVE** | Still validating required fields (Contract_Signer__c, Billing_Frequency__c, Payment_Terms__c) |
| `VR_Quote_Order_Dates_Logical` | ✅ **ACTIVE** | Date validation remains active |

## 🧪 **TESTING REQUIREMENTS**

### **Test Scenarios Needed:**
1. **Admin Bypass Testing**
2. **Override Field Combinations Testing**  
3. **Dual Approval Path Testing**
4. **Single Approval Path Testing (Sales/Ops)**
5. **Rejection Flow Testing**
6. **Status Update Validation**
7. **UI/UX Testing for Approval Screens**

## 📊 **SOQL Optimization**

### **Improvements Achieved:**
- **Consolidated approval logic** into orchestration reduces individual flow SOQL queries
- **Reusable subflows** minimize duplicate queries
- **Single approval process determination** replaces multiple approval process lookups

## 🔗 **CRITICAL AUTOMATION CHAIN: Term_Length_Months__c Synchronization**

**Added**: August 8, 2025 at 12:17 PM EDT

**Complete Data Consistency Flow**:
1. **QLI Effective Dates Change** → `QuoteLineItemTriggerHandler` executes
2. **Quote Order Dates Updated** → `updateQuoteOrderDates()` syncs MIN/MAX from QLIs  
3. **Quote Save Triggered** → `Order_Start_Date__c` and `Order_End_Date__c` changes
4. **Flow Recalculation** → `Quote_Before_Save_Stamp_Fields` recalculates `Term_Length_Months__c`
5. **Complete Sync** → Quote term length automatically synchronized with QLI effective dates

**Business Impact**: Ensures Quote-level term calculations remain accurate when individual QuoteLineItem service dates are modified, maintaining pricing consistency across the entire system.

**Components Involved**:
- `QuoteLineItemTriggerHandler.updateQuoteOrderDates()`
- `Quote_Before_Save_Stamp_Fields` flow
- Formula: `ROUND((Order_End_Date__c - Order_Start_Date__c) / 30.44, 1)`

---

*Last Updated: August 8, 2025 at 12:17 PM EDT*  
*Architecture Status: ✅ Complete Implementation with Full Data Synchronization*