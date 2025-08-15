# Quote Approval Orchestration Testing Strategy

## 🎯 **Testing Overview**

This document outlines the comprehensive testing approach for the new Quote Approval Orchestration system, covering all approval paths, edge cases, and integration points.

## 📋 **Test Categories**

### **1. 🔐 Admin Bypass Testing**

**Test Scenario: Admin Auto-Approval**
- **Setup**: User with "System Administrator" profile
- **Expected**: Auto-approval without manual intervention
- **Validation**:
  - Quote status moves directly to "Approved"
  - No approval work items created
  - `approvalProcess` variable = "Auto-Approval"

**Test Data Required:**
```apex
// Test user with System Administrator profile
User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
```

### **2. 🎛️ Override Field Logic Testing**

**Test Scenario 2.1: Both Overrides Set**
- **Setup**: `First_Approval_Override__c = true` AND `Second_Approval_Override__c = true`
- **Expected**: Auto-approval bypass
- **Validation**: Status = "Approved", `approvalProcess` = "Auto-Approval"

**Test Scenario 2.2: First Override Only**
- **Setup**: `First_Approval_Override__c = true`, `Second_Approval_Override__c = false`
- **Expected**: Ops/Legal approval only
- **Validation**: Single approval step assigned to `Ops_Legal_Queue`

**Test Scenario 2.3: Second Override Only**
- **Setup**: `First_Approval_Override__c = false`, `Second_Approval_Override__c = true`
- **Expected**: Sales approval only
- **Validation**: Single approval step assigned to `joel.hutter@seqera.io.partial`

**Test Scenario 2.4: No Overrides**
- **Setup**: Both override fields = `false`
- **Expected**: Dual approval process
- **Validation**: Two approval steps (Sales + Ops/Legal)

### **3. 🔄 Dual Approval Path Testing**

**Test Scenario 3.1: Both Approvals Granted**
- **Setup**: Standard quote requiring dual approval
- **Steps**:
  1. Sales approver approves
  2. Ops/Legal approver approves
- **Expected**: Quote status = "Approved"

**Test Scenario 3.2: Sales Approves, Ops/Legal Rejects**
- **Expected**: Quote status = "Rejected"

**Test Scenario 3.3: Sales Rejects**
- **Expected**: Quote status = "Rejected" (early termination)

**Test Scenario 3.4: Ops/Legal Approves, Sales Rejects**
- **Expected**: Quote status = "Rejected"

### **4. 📋 Single Approval Path Testing**

**Test Scenario 4.1: Sales Only - Approved**
- **Setup**: Second override set
- **Expected**: Single approval, quote approved

**Test Scenario 4.2: Sales Only - Rejected**
- **Setup**: Second override set
- **Expected**: Single rejection, quote rejected

**Test Scenario 4.3: Ops/Legal Only - Approved**
- **Setup**: First override set
- **Expected**: Single approval, quote approved

**Test Scenario 4.4: Ops/Legal Only - Rejected**
- **Setup**: First override set
- **Expected**: Single rejection, quote rejected

### **5. 🔍 Validation & Field Testing**

**Test Scenario 5.1: Required Field Validation**
- **Setup**: Quote missing required fields
- **Fields to Test**:
  - `Contract_Signer__c`
  - `Billing_Frequency__c`
  - `Payment_Terms__c`
- **Expected**: Validation rule fires, prevents status change

**Test Scenario 5.2: Valid Required Fields**
- **Setup**: All required fields populated
- **Expected**: Approval process initiates successfully

### **6. 🎭 Status Transition Testing**

**Test Scenario 6.1: Draft → Needs Review**
- **Trigger**: Manual status change to "Needs Review"
- **Expected**: Orchestration launches, status → "In Review"

**Test Scenario 6.2: In Review → Approved**
- **Trigger**: Successful approval completion
- **Expected**: Status updates to "Approved"

**Test Scenario 6.3: In Review → Rejected**
- **Trigger**: Rejection in approval process
- **Expected**: Status updates to "Rejected"

### **7. 🎨 UI/UX Testing**

**Test Scenario 7.1: Approval Screen Functionality**
- **Component**: `Approval_Screen_Standard_Decision`
- **Test Points**:
  - Approve button functionality
  - Reject button functionality
  - Comments field capture
  - Required field validation

**Test Scenario 7.2: Work Item Display**
- **Validation**:
  - Approval work items appear correctly
  - Assigned users receive notifications
  - Work item completion updates orchestration

### **8. 🔗 Integration Testing**

**Test Scenario 8.1: Orchestration → Subflow Integration**
- **Validation**:
  - `Quote_Subflow_Set_Approval_Process` executes correctly
  - Status subflows update records properly
  - Variable passing between flows

**Test Scenario 8.2: Record Trigger → Orchestration**
- **Validation**:
  - `Quote_After_Save_Launch_Approval_Orchestration` triggers correctly
  - `requestApproval` action type functions properly

## 🔧 **Test Data Setup Scripts**

### **Create Test Quotes**
```apex
// Standard dual approval quote
Quote dualApprovalQuote = new Quote(
    Name = 'Test Dual Approval Quote',
    OpportunityId = testOpp.Id,
    Status = 'Draft',
    Contract_Signer__c = 'John Doe',
    Billing_Frequency__c = 'Annual',
    Payment_Terms__c = 'Net 30',
    First_Approval_Override__c = false,
    Second_Approval_Override__c = false
);

// Sales only quote
Quote salesOnlyQuote = new Quote(
    Name = 'Test Sales Only Quote',
    OpportunityId = testOpp.Id,
    Status = 'Draft',
    Contract_Signer__c = 'Jane Smith',
    Billing_Frequency__c = 'Monthly',
    Payment_Terms__c = 'Net 15',
    First_Approval_Override__c = false,
    Second_Approval_Override__c = true
);

// Auto-approval quote
Quote autoApprovalQuote = new Quote(
    Name = 'Test Auto Approval Quote',
    OpportunityId = testOpp.Id,
    Status = 'Draft',
    Contract_Signer__c = 'Auto Approve',
    Billing_Frequency__c = 'Quarterly',
    Payment_Terms__c = 'Net 45',
    First_Approval_Override__c = true,
    Second_Approval_Override__c = true
);
```

## 📊 **Performance Testing**

### **SOQL Limit Validation**
- **Test**: Process 200 quotes simultaneously
- **Monitor**: SOQL query consumption in orchestration
- **Expected**: Under governor limits

### **Bulk Processing**
- **Test**: Multiple approval requests in single transaction
- **Validation**: No limit exceptions, proper bulkification

## 🎯 **Acceptance Criteria**

### **Functional Requirements**
- ✅ All approval paths function correctly
- ✅ Admin bypass works for System Administrators
- ✅ Override fields properly route approval processes
- ✅ Status transitions occur at correct stages
- ✅ Required field validation prevents incomplete submissions

### **Non-Functional Requirements**
- ✅ Response time < 5 seconds for approval initiation
- ✅ SOQL queries stay within governor limits
- ✅ Error handling gracefully manages failures
- ✅ User notifications work correctly

### **User Experience**
- ✅ Approval screens are intuitive and responsive
- ✅ Work items display correctly in assigned user's queue
- ✅ Comments capture and display properly
- ✅ Status updates are immediate and accurate

## 🐛 **Error Scenario Testing**

### **System Failures**
- **Test**: Database connection issues during approval
- **Expected**: Graceful error handling, retry mechanisms

### **Invalid Data**
- **Test**: Malformed input data
- **Expected**: Validation errors, no partial processing

### **Permission Issues**
- **Test**: User lacks approval permissions
- **Expected**: Proper error messaging, fallback behavior

## 📋 **Test Execution Checklist**

- [ ] Admin bypass scenarios (2 tests)
- [ ] Override field combinations (4 tests)
- [ ] Dual approval paths (4 tests)
- [ ] Single approval paths (4 tests)
- [ ] Validation testing (2 tests)
- [ ] Status transitions (3 tests)
- [ ] UI/UX functionality (2 tests)
- [ ] Integration testing (2 tests)
- [ ] Performance testing (2 tests)
- [ ] Error scenarios (3 tests)

**Total Test Cases: 28**

## 📝 **Documentation Requirements**

- [ ] Test results documented for each scenario
- [ ] Performance metrics captured
- [ ] Error logs reviewed and analyzed
- [ ] User feedback collected on approval experience
- [ ] Final sign-off from stakeholders

---

*Testing Strategy Version: 1.0*  
*Created: January 30, 2025*  
*Status: Ready for Execution* 