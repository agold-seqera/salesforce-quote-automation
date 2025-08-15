# Slack Channel Configuration Note

**Date**: August 15, 2025  
**Priority**: Critical Production Configuration  
**Status**: 🔄 **PENDING MANUAL UPDATE IN PRODUCTION**

## 🚨 **Current State**

The `Quote_Subflow_Send_Slack_Message` flow is currently configured to send notifications to:

**Current Channel**: `#test-alex-alerts` (Testing/Development Channel)

## 🎯 **Production Requirement**

For production deployment, the flow must be updated to send notifications to:

**Production Channel**: `#deal-desk-approvals` (Official Approval Channel)

## 📋 **Action Required**

### **Post-Deployment Task:**
1. **Navigate to**: Setup → Flows → `Quote_Subflow_Send_Slack_Message`
2. **Edit the flow** in Flow Builder
3. **Locate**: "Send Message to Slack" action element
4. **Update Channel field**: Change from `#test-alex-alerts` to `#deal-desk-approvals`
5. **Save and Activate** the flow

### **Testing Validation:**
- ✅ Create test quote requiring approval
- ✅ Trigger approval process (change status to "Needs Review")
- ✅ **Verify message appears in `#deal-desk-approvals`**
- ✅ **Confirm NO messages sent to `#test-alex-alerts`**

## ⚠️ **Important Notes**

- The approval team must have access to the `#deal-desk-approvals` channel
- This is a **critical configuration** - quotes approval notifications must reach the correct team
- Test thoroughly before going live with production approvals

**Reference**: Detailed instructions included in [`august_15_2025_post_deployment_manual_configuration.md`](august_15_2025_post_deployment_manual_configuration.md)
