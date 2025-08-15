# 🔧 Scripts & Utilities Guide
**Date**: August 14, 2025  
**Purpose**: Development tools and utilities for Quote System maintenance  
**Status**: Minimal utility scripts - most development artifacts archived

## 📋 **Current Active Scripts**

### **🎯 UI Demo Data Creation**

#### **`refresh_ui_demo_data.apex` (RECOMMENDED)**
**Purpose**: Clean up existing demo data and create fresh comprehensive Quote System test data  
**Last Updated**: August 15, 2025  
**Usage**: Execute in Salesforce Developer Console or via SFDX CLI

**Execute via CLI**:
```bash
sf apex run --target-org <your-org> --file scripts/refresh_ui_demo_data.apex
```

**Features**:
- **Smart Cleanup**: Removes existing demo data before creating fresh data
- **Comprehensive Data**: Creates complete sales scenarios with relationships
- **Contact Roles**: Includes Opportunity Contact Roles for realistic testing
- **Existing Product Handling**: Reuses existing products and pricebook entries

**Creates Demo Data**:
- **4 Demo Accounts**: Different customer types (Direct, Channel, Prospect)
- **8 Demo Contacts**: 2 per account with realistic titles and details
- **12 Contact Roles**: Primary Contact, Invoice Contact, and Legal Contact for each opportunity (exact role names from TestDataFactory)
- **4 Demo Opportunities**: Various deal sizes and stages with **Type**, **LeadSource**, and **NextStep** populated
- **4 Demo Quotes**: Ready for UI testing scenarios with proper contact mappings
- **4 Quote Line Items**: Realistic pricing and service dates

#### **`create_ui_demo_data.apex` (LEGACY)**
**Purpose**: Original demo data creation script  
**Status**: Superseded by refresh script for most use cases
**Note**: May fail if demo data already exists due to duplicate detection

### **📊 SOQL Templates**

#### **`soql/account.soql`**
**Purpose**: Basic SOQL query template for development  
**Last Updated**: July 28, 2025  
**Usage**: Execute in VS Code with SFDX extension

**Current Content**:
```sql
// Use .soql files to store SOQL queries.
// You can execute queries in VS Code by selecting the
//     query text and running the command:
//     SFDX: Execute SOQL Query with Currently Selected Text

SELECT Id, Name FROM Account
```

**Intended Use**: Template for storing commonly used SOQL queries. Add additional `.soql` files for specific business scenarios as needed.

---

## 🗂️ **Minimal Script Structure**

### **Current Structure**
```
scripts/
├── SCRIPTS_GUIDE.md          # 📋 This documentation file
├── refresh_ui_demo_data.apex  # 🎯 UI demo data refresh script (RECOMMENDED)
├── create_ui_demo_data.apex   # 🎯 UI demo data creation script (legacy)
├── create_ui_test_data.apex   # 🧪 Original test data script (archived approach)
└── soql/
    └── account.soql          # 📊 Basic SOQL query template
```

### **Archived Development Scripts** (`docs/archive/august-2025/testing-scripts/`)
- `analyze_flows.py` - Flow analysis with hardcoded August 7, 2025 data (one-time use)
- `generate_deployment_inventory.py` - Deployment inventory generator (created file conflicts)
- `debug_utilities.apex` - Debug tools based on classic approval processes (not applicable to Flow-based system)
- `test_slack_rich_message.apex` - Slack testing for archived QuoteApprovalDataProvider

---

## 🎯 **Key Findings: Scripts Were Development Artifacts**

### **❌ Issues Identified**
1. **Stale Hardcoded Data**: Flow analyzer contained static JSON from August 7, 2025
2. **Wrong Architecture**: Debug utilities designed for classic approval processes (we use Flow orchestration)
3. **File Conflicts**: Deployment generator created duplicate files in wrong locations
4. **Limited Utility**: Most scripts were one-time development tools, not ongoing utilities

### **✅ Resolution**
- **Archived Non-Functional Scripts**: Moved development artifacts to archive
- **Preserved Template**: Kept basic SOQL template for future development needs
- **Clean Structure**: Eliminated confusion between development tools and production utilities

---

## 🚀 **Recommendations for Future Development**

### **For New Scripts**
1. **Verify Ongoing Utility**: Ensure scripts will be used repeatedly, not just for one-time analysis
2. **Current Architecture**: Base tools on Flow orchestration, not classic approval processes
3. **Dynamic Data**: Avoid hardcoding org-specific data that becomes stale
4. **Clear Documentation**: Include usage examples and maintenance requirements

### **For Quote System Debugging**
Since we archived the outdated debug utilities, here are current debugging approaches:

#### **1. Use Salesforce Debug Logs**
- Enable debug logs for users experiencing issues
- Monitor Flow execution and trigger behavior
- Review approval orchestration decision trees

#### **2. Flow Interview History**
- Check Flow execution history for approval workflow troubleshooting
- Review decision points in Flow orchestration steps
- Monitor Flow error handling and retry logic

#### **3. Quote System Monitoring**
- Monitor Quote.Status field changes for approval flow progression
- Check `First_Approval_Override__c` and `Second_Approval_Override__c` fields
- Validate sync tracking via `Synced_Quote__c` fields

#### **4. Test Class Execution**
- Run Quote System test classes for validation:
  ```bash
  sf apex run test --test-level RunLocalTests --target-org <your-org>
  ```

---

## 📚 **Development Guidelines**

### **When to Create Scripts**
- ✅ **Repeated Operations**: Tasks performed multiple times across development lifecycle
- ✅ **Production Utilities**: Tools needed for ongoing system maintenance
- ✅ **Automation**: Processes that save significant manual effort

### **When NOT to Create Scripts**
- ❌ **One-Time Analysis**: Use ad-hoc SOQL queries or reports instead
- ❌ **Development Testing**: Use test classes and debug logs
- ❌ **Static Data**: Avoid hardcoding org-specific information

### **Script Standards**
- **Documentation**: Clear purpose, usage instructions, and maintenance requirements
- **Architecture Alignment**: Based on current system design (Flow orchestration)
- **Error Handling**: Graceful failure with informative messages
- **Maintenance**: Regular review and update schedule

---

## 🔍 **Alternative Debugging Approaches**

### **For Quote System Issues**
1. **Salesforce Setup → Debug Logs**: Enable for specific users
2. **Developer Console → Query Editor**: Ad-hoc SOQL for data investigation
3. **Flow Runtime → Interview History**: Review Flow execution details
4. **Test Classes**: Comprehensive system validation via `sf apex run test`

### **For Approval Workflow Issues**
1. **Quote Record Details**: Check Status, override fields, approval history
2. **Flow Orchestration Logs**: Review approval decision routing
3. **User Assignment**: Verify group membership for approval assignments
4. **Override Field Testing**: Test admin bypass functionality

---

## 📈 **Minimal Maintenance**

### **Current Status**
- **Active Scripts**: 3 (UI demo data refresh + creation + SOQL template)
- **Recommended**: Use `refresh_ui_demo_data.apex` for comprehensive demo data with cleanup
- **Maintenance Required**: Minimal - update demo data as business requirements evolve
- **Next Review**: Only if new development utilities are needed

### **Archive Management**
- **Preserved History**: All development scripts archived for reference
- **No Ongoing Maintenance**: Archived scripts are historical artifacts
- **Future Reference**: Available if development approaches need to be revisited

---

**Guide Status**: ✅ **MINIMAL & CLEAN**  
**Last Updated**: August 14, 2025  
**Philosophy**: Essential utilities only - development artifacts archived  
**Recommendation**: Use Salesforce native debugging tools for Quote System troubleshooting