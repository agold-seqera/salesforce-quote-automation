# Seqera Revenue Calculation Analysis Report

**Date**: December 20, 2024  
**Objective**: Analyze current Opportunity revenue calculation architecture to design accurate QLI → OLI sync  
**Environment**: seqera--partial.sandbox.my.salesforce.com  

---

## 🎯 **EXECUTIVE SUMMARY**

Successfully reverse-engineered Seqera's Opportunity revenue calculation architecture. The system uses **Product_Family__c-based categorization** to separate Software Subscriptions from Professional Services, with rollup summary fields feeding into calculated revenue metrics.

**Key Finding**: Revenue calculations are **entirely dependent on OpportunityLineItem.Product_Family__c** field population, making this the critical sync point for Quote-Opportunity integration.

---

## 📊 **REVENUE CALCULATION ARCHITECTURE**

### **Core Categorization Logic**
```
Product2.Family → OpportunityLineItem.Product_Family__c → Opportunity Rollups
```

**Product Family Values (Inferred from Analysis):**
- `"Professional Service"` - One-time services, implementation, training
- `"Software Subscriptions"` (or any non-"Professional Service") - Recurring subscription revenue

### **Revenue Field Hierarchy**

#### **1. Base Rollup Summary Fields**
```xml
Professional_Service_Amount_RUS__c (Rollup Summary)
├─ Summarizes: OpportunityLineItem.TotalPrice  
├─ Filter: OpportunityLineItem.Product_Family__c = "Professional Service"
└─ Operation: SUM

Software_Subscription_Amount_RUS__c (Rollup Summary)  
├─ Summarizes: OpportunityLineItem.TotalPrice
├─ Filter: OpportunityLineItem.Product_Family__c != "Professional Service"  
└─ Operation: SUM

ARR_RUS__c (Rollup Summary)
├─ Summarizes: OpportunityLineItem.TotalPrice
├─ Filter: OpportunityLineItem.Product_Family__c != "Professional Service"
└─ Operation: SUM (Same as Software_Subscription_Amount_RUS__c)
```

#### **2. Calculated Revenue Metrics**
```xml
ACV__c (Formula)
├─ Formula: Amount
└─ Purpose: Annual Contract Value = Standard Opportunity Amount

TCV__c (Formula)  
├─ Formula: (((ACV__c - Professional_Service_Amount_RUS__c) /12) * Term_Length_Months__c) + Professional_Service_Amount_RUS__c
└─ Logic: (Monthly Subscription × Term) + One-time Services

MRR__c (Formula)
├─ Formula: ARR_RUS__c / 12  
└─ Purpose: Monthly Recurring Revenue from subscriptions only
```

#### **3. Manual Entry Fields**
```xml
Software_Subscription_Amount__c (Manual Currency)
Professional_Service_Amount__c (Manual Currency)  
ARR__c (Manual Currency)
Incremental_ARR__c (Manual Currency)
```

---

## 🔍 **CRITICAL BUSINESS LOGIC ANALYSIS**

### **TCV Calculation Breakdown**
Based on screenshot values: ARR=$25K, Professional Service=$2.5K, TCV=$27.5K

```
TCV Formula: (((ACV - PS_Amount_RUS) / 12) * Term_Months) + PS_Amount_RUS

Example Calculation:
ACV__c = $27,500 (Opportunity Amount)
Professional_Service_Amount_RUS__c = $2,500  
Term_Length_Months__c = 12

TCV = (((27500 - 2500) / 12) * 12) + 2500
    = ((25000 / 12) * 12) + 2500  
    = 25000 + 2500
    = $27,500 ✓
```

### **ARR vs Software Subscription Logic**
- **ARR_RUS__c**: Rollup of all non-"Professional Service" OLI TotalPrice values
- **Software_Subscription_Amount_RUS__c**: Identical rollup logic  
- Both fields should always match in current architecture

### **Product Family Population Flow**
```
OpportunityLineItem Before Save Flow:
Product2.Family → OpportunityLineItem.Product_Family__c

Flow: "Opportunity Product | Before Save"  
Logic: $Record.Product_Family__c = $Record.PricebookEntry.Product2.Family
```

---

## 🔄 **QUOTE → OPPORTUNITY SYNC IMPLICATIONS**

### **Critical Success Factors**

#### **1. Product Family Preservation**
```
QuoteLineItem.Product_Family__c → OpportunityLineItem.Product_Family__c
```
**REQUIREMENT**: QLI must populate Product_Family__c field to maintain revenue categorization.

#### **2. Billing Amount vs Annual Amount**  
**Current OLI Architecture**: `TotalPrice` represents **annual amounts** for subscriptions
**Quote Architecture**: Fields store **actual billing amounts** (prorated)

**MISMATCH IDENTIFIED**: Our Quote billing calculation produces prorated amounts, but Opportunity revenue calculations expect annual amounts.

### **Sync Design Requirements**

#### **Option A: Annual Amount Sync (Recommended)**
```
QuoteLineItem.Annual_Amount__c → OpportunityLineItem.TotalPrice
QuoteLineItem.Product_Family__c → OpportunityLineItem.Product_Family__c  
```

**Pros**: Preserves existing Opportunity revenue calculations exactly  
**Cons**: Loses visibility into actual billing amounts on Opportunity

#### **Option B: New Billing Amount Field**
```
QuoteLineItem.TotalPrice → OpportunityLineItem.Billing_Amount__c (NEW)
QuoteLineItem.Annual_Amount__c → OpportunityLineItem.TotalPrice  
QuoteLineItem.Product_Family__c → OpportunityLineItem.Product_Family__c
```

**Pros**: Maintains both billing visibility and revenue accuracy  
**Cons**: Requires new OLI field creation

---

## 📋 **SYNC FIELD MAPPING**

### **Required QLI → OLI Mappings**
```
CRITICAL MAPPINGS:
├─ QuoteLineItem.Product_Family__c → OpportunityLineItem.Product_Family__c
├─ QuoteLineItem.Annual_Amount__c → OpportunityLineItem.TotalPrice  
├─ QuoteLineItem.Product2Id → OpportunityLineItem.Product2Id
├─ QuoteLineItem.Quantity → OpportunityLineItem.Quantity
└─ QuoteLineItem.UnitPrice → OpportunityLineItem.UnitPrice

OPTIONAL MAPPINGS:
├─ QuoteLineItem.Description → OpportunityLineItem.Description
├─ QuoteLineItem.Discount → OpportunityLineItem.Discount  
└─ QuoteLineItem.TotalPrice → OpportunityLineItem.Billing_Amount__c (if created)
```

### **Product Family Logic Requirements**  
```
Quote Line Item Product Family Population:
IF Product2.Family = "Professional Service" 
THEN QuoteLineItem.Product_Family__c = "Professional Service"
ELSE QuoteLineItem.Product_Family__c = Product2.Family (subscription types)

Sync Flow Must Preserve This Categorization
```

---

## ⚠️ **CRITICAL RISKS & MITIGATION**

### **Risk 1: Revenue Calculation Breakage**
**Risk**: Incorrect Product_Family__c values break ARR/TCV calculations  
**Mitigation**: Implement validation rules and test coverage for family categorization

### **Risk 2: Billing vs Annual Amount Confusion**
**Risk**: Syncing billing amounts to TotalPrice understates revenue  
**Mitigation**: Use Annual_Amount__c field for sync, maintain billing visibility separately

### **Risk 3: Missing Product Family Data**  
**Risk**: Quote products without family data break rollups
**Mitigation**: Default family assignment logic and validation rules

---

## 🚀 **IMPLEMENTATION RECOMMENDATIONS**

### **Phase 1: Foundation (Immediate)**
1. **Validate Product Family Coverage**: Ensure all Quote products have proper Product2.Family values
2. **Implement QLI Product Family Population**: Mirror OLI flow logic in Quote system
3. **Create Annual Amount Sync Logic**: Use Annual_Amount__c for OLI.TotalPrice sync

### **Phase 2: Enhancement (Future)**  
1. **Add Billing Amount Visibility**: Create OpportunityLineItem.Billing_Amount__c field
2. **Implement Dual Amount Sync**: Maintain both billing and annual amounts  
3. **Enhanced Reporting**: Revenue reports showing both billing and annual perspectives

### **Phase 3: Validation (Testing)**
1. **End-to-End Revenue Testing**: Validate ARR/TCV calculations post-sync
2. **Product Family Scenarios**: Test all family combinations  
3. **Multi-Currency Validation**: Ensure exchange rates don't break calculations

---

## 📊 **ARCHITECTURE DIAGRAM**

```
Quote System                    Opportunity System
┌─────────────────┐            ┌──────────────────────┐
│ QuoteLineItem   │            │ OpportunityLineItem  │
│ ├─Annual_Amount │───────────▶│ ├─TotalPrice         │
│ ├─Product_Family│───────────▶│ ├─Product_Family__c  │
│ ├─TotalPrice    │            │ └─(Billing_Amount)   │  
│ └─(billing amt) │            └──────────┬───────────┘
└─────────────────┘                       │
                                          ▼
                               ┌──────────────────────┐
                               │ Opportunity Revenue  │  
                               │ ├─ARR_RUS__c (Rollup)│
                               │ ├─PS_Amount_RUS__c   │
                               │ ├─TCV__c (Formula)   │
                               │ └─MRR__c (Formula)   │
                               └──────────────────────┘
```

---

## ✅ **VALIDATION CHECKLIST**

- [✓] Revenue field formulas documented
- [✓] Product family categorization logic identified  
- [✓] Rollup summary field logic analyzed
- [✓] Critical sync mappings defined
- [✓] Risk mitigation strategies outlined
- [✓] Implementation phases planned
- [ ] End-to-end sync testing (pending implementation)

---

**CONCLUSION**: The revenue calculation architecture is well-structured and maintainable. Success of Quote-Opportunity sync depends entirely on accurate Product_Family__c categorization and using Annual_Amount__c values for revenue rollups.

**NEXT STEPS**: Implement QLI Product_Family__c population logic and Annual_Amount__c sync to preserve Seqera's existing revenue accuracy. 