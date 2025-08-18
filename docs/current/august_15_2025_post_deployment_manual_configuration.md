# Post-Deployment Manual Configuration Guide

**Date**: August 15, 2025  
**Priority**: Critical Post-Deployment Tasks  
**Status**: 🔄 **PENDING MANUAL COMPLETION IN PRODUCTION**

## 🚨 **Important Note**

Several configuration items **cannot be deployed through metadata** and require manual setup in the target org after deployment. This includes Lightning page assignments, field additions to layouts, and logo usage setup.



## 📋 **Lightning Pages Requiring Manual Activation**

### **🎯 Quote Lightning Pages**

#### **`Quote_Record_Page.flexipage`**
- **Purpose**: Custom Quote record page with specialized actions and layout
- **Key Features**:
  - Custom action buttons (Get Opportunity Products, Sync Quote to Opportunity, Refresh Contact Roles)
  - Status-based visibility rules for actions
  - Specialized field layout for Quote System workflow

**Manual Activation Steps**:
1. Navigate to **Setup → Object Manager → Quote → Lightning Record Pages**
2. Click **Quote_Record_Page**
3. Click **Activation**
4. **Assign to Apps**: Select relevant Lightning apps
5. **Set as Org Default**: Make default for Quote object
6. **Assign to Record Types**: Assign to all Quote record types (if any exist)
7. **Assign to Profiles**: Assign to all user profiles that work with quotes
8. Click **Save**

---

### **🎯 Opportunity Lightning Pages**

#### **`ExistingCustomer_Opportunity_Record_Page_v31.flexipage`**
- **Purpose**: Specialized layout for existing customer opportunities
- **Record Type**: `Existing_Customer_Opportunity`

**Manual Activation Steps**:
1. Navigate to **Setup → Object Manager → Opportunity → Lightning Record Pages**
2. Click **ExistingCustomer_Opportunity_Record_Page_v31**
3. Click **Activation**
4. **Assign to Record Types**: `Existing_Customer_Opportunity`
5. **Assign to Profiles**: All relevant user profiles
6. Click **Save**

#### **`NewSale_Opportunity_Record_Page_v3.flexipage`**
- **Purpose**: Specialized layout for new sales opportunities
- **Record Type**: `New_Sales_Opportunity`

**Manual Activation Steps**:
1. Navigate to **Setup → Object Manager → Opportunity → Lightning Record Pages**
2. Click **NewSale_Opportunity_Record_Page_v3**
3. Click **Activation**
4. **Assign to Record Types**: `New_Sales_Opportunity`
5. **Assign to Profiles**: All relevant user profiles
6. Click **Save**

#### **`POC_Opportunity_Record_Page.flexipage`**
- **Purpose**: Specialized layout for Proof of Concept opportunities
- **Record Type**: `Proof_of_Concept`

**Manual Activation Steps**:
1. Navigate to **Setup → Object Manager → Opportunity → Lightning Record Pages**
2. Click **POC_Opportunity_Record_Page**
3. Click **Activation**
4. **Assign to Record Types**: `Proof_of_Concept`
5. **Assign to Profiles**: All relevant user profiles
6. Click **Save**

---

### **🎯 Quote Line Item Lightning Pages**

#### **`Quote_Line_Item_Record_Page.flexipage`**
- **Purpose**: Custom Quote Line Item record page

**Manual Activation Steps**:
1. Navigate to **Setup → Object Manager → Quote Line Item → Lightning Record Pages**
2. Click **Quote_Line_Item_Record_Page**
3. Click **Activation**
4. **Set as Org Default**: Make default for Quote Line Item object
5. **Assign to Profiles**: All relevant user profiles
6. Click **Save**

---

### **🎯 Approval System Lightning Pages**

#### **`Approval_Request_Record_Page.flexipage`**
- **Purpose**: Custom layout for approval requests

#### **`Approval_Submission_Record_Page.flexipage`**
- **Purpose**: Custom layout for approval submissions

#### **`Approval_Submission_Detail_Record_Page.flexipage`**
- **Purpose**: Detailed view for approval submission details

#### **`Approval_Work_Item_Record_Page.flexipage`**
- **Purpose**: Custom layout for approval work items

**Manual Activation Steps for Each**:
1. Navigate to **Setup → Object Manager → [Object Name] → Lightning Record Pages**
2. Click the respective page name
3. Click **Activation**
4. **Set as Org Default** or **Assign to Record Types** as appropriate
5. **Assign to Profiles**: All relevant user profiles
6. Click **Save**

---

## 🏢 **Account Layout Configuration**

### **⚠️ Missing Customer Logo Use Field**

The Quote Record Page references `Account.Customer_Logo_Use__c` field which **does not exist** in our deployment package.

**Manual Setup Required:**

#### **Step 1: Create Customer Logo Use Field**
1. Navigate to **Setup → Object Manager → Account → Fields & Relationships**
2. Click **New**
3. **Field Type**: Picklist or Text (determine business requirement)
4. **Field Label**: `Customer Logo Use`
5. **API Name**: `Customer_Logo_Use__c`
6. **Values** (if picklist): 
   - `Approved`
   - `Not Approved` 
   - `Pending Review`
   - `Not Applicable`
7. **Field-Level Security**: Set appropriate profile permissions
8. Click **Save**

#### **Step 2: Add Field to Account Layout**
1. Navigate to **Setup → Object Manager → Account → Page Layouts**
2. Edit the **Account Layout** (or create record-type specific layouts)
3. **Drag `Customer Logo Use` field** to appropriate section (suggest: Account Information or Company Information)
4. **Set field properties** (required, read-only, etc. based on business needs)
5. Click **Save**

#### **Step 3: Verify Quote Page Display**
1. **Create or edit a Quote** 
2. **Verify** that `Account.Customer_Logo_Use__c` displays correctly in the Quote Record Page
3. **Test data entry** - ensure field updates properly

---

## 📄 **Quote Template Configuration**

### **⚠️ Quote Templates Cannot Be Deployed via Metadata**

Quote Templates are **not supported by the Salesforce Metadata API** and must be manually recreated in each org.

**Manual Setup Required:**

#### **Step 1: Export Template from Partial Org**
1. **Login to partial org** (`seqera--partial`)
2. Navigate to **Setup → Object Manager → Quote → Quote Templates**
3. **Open existing quote template**
4. **Document template configuration**:
   - Template name and description
   - Page layout and field positioning
   - Header/footer content
   - Line item table configuration
   - Terms and conditions text
   - Company branding elements
5. **Take screenshots** of template layout for reference

#### **Step 2: Create Template in Production**
1. **Login to production org** (`seqera.my.salesforce.com`)
2. Navigate to **Setup → Object Manager → Quote → Quote Templates**
3. Click **New Quote Template**
4. **Configure template** to match partial org:
   - Set template name and description
   - Configure page layout and field positioning
   - Add header/footer content
   - Set up line item table with proper columns
   - Add terms and conditions
   - Apply company branding
5. **Add Seqera Logo**: Reference the deployed static resource `{!$Resource.Seqera_Logo}` in template header/footer for branding
6. **Test template** by generating a sample quote PDF
7. **Set as default** if this should be the primary template

#### **Step 3: Verify Template Functionality**
1. **Create a test quote** in production
2. **Generate PDF** using the new template
3. **Compare output** with partial org template
4. **Test all template features** (conditional fields, calculations, etc.)
5. **Verify branding** and formatting appear correctly

---

## 💬 **Slack Integration Configuration**

### **⚠️ Slack App Connection Required**

The `Quote_Subflow_Send_Slack_Message` flow uses Slack integration for approval notifications, but **Slack app connections are org-specific** and don't transfer through metadata deployment.

**Manual Setup Required:**

#### **Step 1: Verify Slack App Connection**
1. Navigate to **Setup → Flows**
2. Search for and open **`Quote_Subflow_Send_Slack_Message`**
3. **Edit the flow** in Flow Builder
4. Locate the **"Send Message to Slack"** action element
5. **Verify the Slack connection** shows the correct app
6. If connection is missing or incorrect, **reconnect to the production Slack app**

#### **Step 2: Configure Slack Channel/Webhook**
1. In the **"Send Message to Slack"** action element
2. **Current channel**: `#test-alex-alerts` (testing channel)
3. **Update to production channel**: `#deal-desk-approvals`
4. **Change the Channel field** from `#test-alex-alerts` to `#deal-desk-approvals`
5. **Save the flow changes**

#### **Step 3: Test Slack Integration**
1. **Create a test quote** that requires approval
2. **Change status to "Needs Review"** to trigger the approval flow
3. **Verify Slack message** is sent to `#deal-desk-approvals` channel (NOT `#test-alex-alerts`)
4. **Check message formatting** and action links work correctly
5. **Confirm approval team** has access to the `#deal-desk-approvals` channel

#### **Step 4: Production Slack App Setup** (If Needed)
If no production Slack app exists:
1. Navigate to **Setup → Apps → Connected Apps**
2. **Create new Connected App** for Slack integration
3. **Configure OAuth settings** for Slack
4. **Install Slack app** in production Slack workspace
5. **Update flow** to use new Slack app connection

---

## ✅ **Complete Post-Deployment Checklist**

### **🎯 CRITICAL - Lightning Page Activation (Required for UI)**

- [ ] **Quote Record Page** - Activate as org default
- [ ] **ExistingCustomer Opportunity Page** - Assign to Existing Customer record type
- [ ] **NewSale Opportunity Page** - Assign to New Sales record type  
- [ ] **POC Opportunity Page** - Assign to Proof of Concept record type
- [ ] **Quote Line Item Page** - Activate as org default
- [ ] **Approval Request Page** - Activate as org default
- [ ] **Approval Submission Page** - Activate as org default
- [ ] **Approval Submission Detail Page** - Activate as org default
- [ ] **Approval Work Item Page** - Activate as org default

### **🏢 CRITICAL - Account Layout Configuration (Required for Quote System)**

- [ ] **Create Customer Logo Use Field** on Account object
- [ ] **Add Customer Logo Use Field** to Account page layout(s)
- [ ] **Set Field-Level Security** for Customer Logo Use field
- [ ] **Test Quote Record Page** - Verify Account.Customer_Logo_Use__c displays correctly

### **📄 CRITICAL - Quote Template Configuration (Required for Quote PDFs)**

- [ ] **Document Quote Template** configuration from partial org
- [ ] **Take screenshots** of template layout and settings
- [ ] **Create Quote Template** manually in production org
- [ ] **Configure template layout** to match partial org template
- [ ] **Add Seqera Logo** using static resource `{!$Resource.Seqera_Logo}` (✅ Already deployed)
- [ ] **Test template** by generating sample quote PDF
- [ ] **Set as default** template if applicable

### **💬 CRITICAL - Slack Integration Configuration (Required for Approval Notifications)**

- [ ] **Verify Slack App Connection** in Quote_Subflow_Send_Slack_Message flow
- [ ] **Update Slack Channel/Webhook** if needed for production notifications
- [ ] **Test Slack Notification Flow** - Verify messages are sent to correct channel
- [ ] **Configure Slack App Permissions** for production environment

### **✅ Testing After All Manual Setup:**

- [ ] **Test Quote creation and editing** - Verify custom actions appear
- [ ] **Test Quote Record Page** - Verify Account logo use field displays
- [ ] **Test Opportunity record types** - Verify correct page layouts load
- [ ] **Test Quote Line Item creation** - Verify custom layout works
- [ ] **Test Approval workflows** - Verify approval pages display correctly
- [ ] **Test Account field updates** - Verify Customer Logo Use field functions properly
- [ ] **Test Slack Integration** - Create test quote, trigger approval, verify Slack notification sent to `#deal-desk-approvals` (NOT `#test-alex-alerts`)

---

## 🔧 **Why Manual Activation is Required**

Lightning page assignments involve:
- **App assignments** - Which Lightning apps use the page
- **Profile assignments** - Which user profiles see the page
- **Record type mappings** - Which record types use specific pages
- **Default settings** - Org-wide default page configurations

Slack integrations involve:
- **Connected App credentials** - Org-specific OAuth connections
- **Channel configurations** - Environment-specific Slack channels
- **Webhook URLs** - Unique per Slack workspace/environment
- **App permissions** - Workspace-specific authorization

These settings are **environment-specific** and cannot be reliably deployed via metadata because they depend on:
- Existing profiles in the target org
- Existing Lightning apps
- User permission configurations
- Org-specific customizations
- External system connections (Slack workspaces)
- Environment-specific configurations

## 📚 **Documentation References**

- **Salesforce Help**: [Assign Lightning Record Pages](https://help.salesforce.com/s/articleView?id=sf.lightning_app_builder_assign_record_pages.htm)
- **Slack Integration Guide**: [`docs/reference/slack_integration_implementation_guide.md`](../reference/slack_integration_implementation_guide.md)
- **Quote System Flows**: Ensure flows work correctly with activated pages
- **Custom Actions**: Verify quote custom actions (Get Opportunity Products, Sync Quote to Opportunity) function properly

---

**⚠️ Remember**: Always test in a sandbox environment before production activation to ensure Lightning pages work as expected with your org's specific configuration.
