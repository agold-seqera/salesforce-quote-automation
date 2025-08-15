# Slack Integration Implementation Guide

**Date:** August 11, 2025  
**Purpose:** Implementation guide for Flow-based Quote approval with Slack integration  
**Author:** Alex Goldstein  

## 🎯 **Architecture Overview**

### **Flow-Based Approval System:**
- **Main Flow:** `Quote_After_Save_Flow_Based_Approval` 
- **Slack Subflow:** `Quote_Subflow_Send_Slack_Message`
- **Slack View:** `QuoteApprovalView.view`
- **Data Provider:** `QuoteApprovalDataProvider.cls`
- **Action Handler:** `QuoteApprovalHandler.cls`

## 🔧 **Implementation Components**

### **1. Slack View Definition (`QuoteApprovalView.view`)**
**Purpose:** Interactive Slack interface for quote approvals  
**Location:** `force-app/main/default/viewdefinitions/QuoteApprovalView.view`

**Key Features:**
- ✅ **Dynamic Content** based on approval stage (Sales vs Ops/Legal)
- ✅ **Interactive Buttons** for Approve/Reject actions
- ✅ **Quote Details** display with financial breakdown
- ✅ **Direct Links** to Salesforce record
- ✅ **Contextual Information** about approval workflow

**Schema Properties:**
```yaml
quoteId: string (required) - Quote record ID
quoteName: string (required) - Quote name/number
accountName: string (required) - Associated account
totalAmount: string (required) - Total quote amount
approvalStage: string (required) - Current stage (Sales/Ops_Legal)
approverGroup: string (required) - Current approver group
firstOverride: boolean - First approval override flag
secondOverride: boolean - Second approval override flag
```

### **2. Data Provider (`QuoteApprovalDataProvider.cls`)**
**Purpose:** Supplies quote data to Slack views  

**Key Methods:**
- `getQuoteDetails()` - Retrieves comprehensive quote information
- `determineApprovalStage()` - Calculates current approval stage
- `determineApproverGroup()` - Identifies current approver group

**Data Provided:**
- Quote metadata (name, account, amounts)
- Approval context (stage, overrides, history)
- Financial breakdown (annual, services, one-off)
- Contract details (terms, billing, signer)

### **3. Action Handler (`QuoteApprovalHandler.cls`)**
**Purpose:** Processes approval decisions from Slack interface

**Key Methods:**
- `approveQuote()` - Processes approval decisions
- `rejectQuote()` - Processes rejection decisions  
- `getApprovalStatus()` - Retrieves current approval state

**Approval Logic:**
```apex
Sales Approval → Set First_Approval_Override__c = true → Continue to Ops/Legal
Ops/Legal Approval → Set Second_Approval_Override__c = true + Status = 'Approved'
Any Rejection → Set Status = 'Rejected'
```

## 🔄 **Flow Integration Points**

### **Current Flow Structure:**
1. **Trigger:** Quote status → "Needs Review"
2. **Move to In Review Stage** → Set status
3. **Require Approval Process?** → Check overrides + admin bypass
4. **First Approval Stage** → Sales team + Slack notification
5. **Second Approval Stage** → Ops/Legal team + potential additional notifications
6. **Approval Outcomes** → Approved/Rejected stages

### **Slack Integration Points:**
- **Sales Approval Stage:** Sends Slack notification with approval view
- **Approval Decisions:** Slack buttons trigger Apex handlers
- **Status Updates:** Flow continues based on override field updates

## 📱 **Slack View User Experience**

### **Sales Approval View:**
```
📋 Quote Approval Required

Quote Details:
• Quote: Q-12345 - Seqera Enterprise License
• Account: Acme Corporation  
• Total Amount: $50,000
• Approval Stage: Sales
• Approver Group: Sales_Approver

🎯 Sales Approval Required
This quote requires Sales team approval before proceeding to Operations/Legal review.

Override Flags:
• First Override: ❌ Disabled
• Second Override: ❌ Disabled

[✅ Approve] [❌ Reject] [👀 View Quote in Salesforce]
```

### **Ops/Legal Approval View:**
```
📋 Quote Approval Required

Quote Details:
• Quote: Q-12345 - Seqera Enterprise License  
• Account: Acme Corporation
• Total Amount: $50,000
• Approval Stage: Ops_Legal
• Approver Group: Ops_Legal_Approver

⚖️ Operations/Legal Approval Required
Sales approval completed. This quote now requires Operations/Legal team approval.

Approval Path:
• Sales Approval: ✅ Completed
• Ops/Legal Approval: ⏳ Pending

[✅ Approve] [❌ Reject] [👀 View Quote in Salesforce]
```

## 🚀 **Deployment Steps**

### **1. Deploy Apex Classes:**
```bash
sf project deploy start --source-dir force-app/main/default/classes/QuoteApprovalDataProvider.cls* --target-org [your-org]
sf project deploy start --source-dir force-app/main/default/classes/QuoteApprovalHandler.cls* --target-org [your-org]
```

### **2. Deploy Slack View:**
```bash
sf project deploy start --source-dir force-app/main/default/viewdefinitions/ --target-org [your-org]
```

### **3. Update Slack Subflow:**
Update `Quote_Subflow_Send_Slack_Message` to use the new view:
- **Action:** `slackSendView` (instead of `slackPostMessage`)
- **View Name:** `QuoteApprovalView`  
- **Parameters:** Pass quote data to view schema

### **4. Configure Slack App Permissions:**
Ensure Slack app has permissions for:
- ✅ **Interactive Components** (buttons, modals)
- ✅ **View Rendering** (custom views)
- ✅ **Message Posting** (conversations)

## 🧪 **Testing Strategy**

### **Unit Testing:**
- **QuoteApprovalDataProvider:** Test data retrieval and stage calculation
- **QuoteApprovalHandler:** Test approval/rejection logic and quote updates
- **Flow Integration:** Test end-to-end approval workflow

### **Integration Testing:**
1. **Create test quote** with "Needs Review" status
2. **Verify Slack notification** sent with correct view
3. **Test approval actions** from Slack interface
4. **Verify quote status updates** and workflow progression
5. **Test rejection flow** and final status

### **User Acceptance Testing:**
- **Sales Team:** Test sales approval stage in Slack
- **Ops/Legal Team:** Test ops/legal approval stage in Slack  
- **End-to-End:** Complete approval workflow from start to finish

## 🔍 **Troubleshooting**

### **Common Issues:**

1. **View Not Rendering:**
   - Check view YAML syntax and indentation
   - Verify ViewDefinition deployment
   - Check Slack app permissions

2. **Data Not Loading:**
   - Verify QuoteApprovalDataProvider is deployed and accessible
   - Check SOQL query permissions
   - Validate quote record exists and has required fields

3. **Buttons Not Working:**
   - Check QuoteApprovalHandler method signatures
   - Verify @InvocableMethod annotations
   - Check Slack app interactive component permissions

4. **Flow Not Triggering:**
   - Verify Quote_After_Save_Flow_Based_Approval is Active
   - Check flow entry criteria (Status = 'Needs Review')
   - Verify user has flow execution permissions

## 📚 **Additional Resources**

- **Salesforce Slack SDK:** [Views Documentation](https://developer.salesforce.com/docs/platform/salesforce-slack-sdk/guide/views_create.html)
- **Flow Approval Orchestrations:** Salesforce Flow Builder documentation
- **Slack Interactive Components:** Slack API documentation
- **Testing Framework:** Salesforce Apex testing best practices

## 🎯 **Success Criteria**

- ✅ **Quote approvals** work seamlessly in Slack
- ✅ **Dynamic content** displays correctly for each approval stage  
- ✅ **Interactive buttons** successfully approve/reject quotes
- ✅ **Workflow progression** continues correctly after Slack actions
- ✅ **User experience** is intuitive and efficient
- ✅ **Error handling** gracefully manages edge cases

---

*Implementation guide created by Alex Goldstein - August 11, 2025* 