/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   A global constants class for the project

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
05/28/2015  Charnun.T           First Create
------------------------------------------------------------*/
public with sharing class GlobalConstants {

    //LOG_LEVEL
    public static final String DEBUG_LOG = 'DEBUG';
    public static final String ERROR_LOG = 'ERROR';
    public static final String INFO_LOG = 'INFO';
    public static final String WARN_LOG = 'WARN';

    public static final String CREDIT_APPROVAL_PROCESS = 'Credit Approval Process';
    public static final String CREDIT_WRITE_UP = 'Credit Write Up';
    public static final String STOCK_NEGOTIATION = 'Stock Negotiation';
    public static final String WAITING_FOR_CREDIT_APPROVAL = 'Waiting for Credit Approval';

    public static final String CANNOT_INSERT_CAMMEM = 'Invited Guest is not Target Customer for this Event';

    public static final String STATUS_NEW = 'New';
    public static final String STATUS_DONE = 'Done';
    public static final String STATUS_GO = 'Going';
    public static final String STATUS_SHOW_UP = 'Show Up';
    public static final String STATUS_COMPLETED = 'Completed';

    public static final String CUSTOMER_INTERESTED = 'Customer Interested';
    public static final String NOT_INTERESTED_THIS_TIME = 'Not Interested This Time';
    public static final String APP_IN = 'App In';

    public static final String CANNOT_APPLY = 'Cannot apply';
    public static final String FACE_TO_FACE = 'Face to Face';
    public static final String NOT_INTEREST = 'Not interest';
    public static final String INTEREST_AND_CAN_APPLY = 'Interest and can apply';
    public static final String INTEREST_WITH_CONDITION = 'Interest with condition';

    public static final String READ = 'Read';
    public static final String PLAN = 'Plan';
    public static final String PLANNED = 'Planned';
    public static final String CANCEL = 'Cancel';
    public static final String ACTIVE = 'Active';
    public static final String EVENT = 'Event';
    public static final String INVITATION = 'Invitation';
    public static final String POOL = 'Pool';
    public static final String PORT = 'Port';
    public static final String RELATIONSHIP_MANAGER = 'Relationship Manager';
    public static final String ASSIGN_TO_SUBJECT = '{0} : {1}';
    public static final String CHANGE_DATE_SUBJECT = 'Change Call Plan/Call Report Date : {0}';

    public static final String ROLE = 'Role';
    public static final String ROLE_AND_SUBORDINATE = 'RoleAndSubordinates';

    public static final Set<String> RM_JOB_CODE = new Set<String>{'ME4A','ME4B','ME3D','SE4A'};
    public static final Set<String> TM_JOB_CODE = new Set<String>{'ME3A','SE3A'};
    public static final Set<String> AH_JOB_CODE = new Set<String>{'ME2A','SE2A'};
    public static final Set<String> NH_JOB_CODE = new Set<String>{'ME1A','SE1A'};

    public static final String SYSTEM_ADMIN = 'System Administrator';
    public static final String SME_RM = 'SME-RM';
    public static final String SME_TM = 'SME-TM';
    public static final String SME_NH = 'SME-NH';
    public static final String SME_AH = 'SME-AH';
    public static final String SME_SUPER_USER = 'SME-Super User';
    public static final String SME_ADMIN = 'SME-Admin';
    public static final String SME_CAMPAIGN = 'SME-Campaign';
    public static final String SME_EVENT = 'SME-Event';
    public static final String SME_EVENT_NON_TARGET = 'SME-Event (Non-Targeted)';
    public static final String SME_LEAD_CAMPAIGN_DEVNAME = 'SME_Lead_Campaign';
    public static final String SME_EVENT_NON_TARGET_DEVNAME = 'SME_Event_Non_Targeted';
    public static final String SME_EVENT_DEVNAME = 'SME_Event';

    public static final String SME_EMAIL_TEMPLATE_NEW_EVENT = 'SME_New_Event';
    public static final String SME_EMAIL_TEMPLATE_MODIFIED_EVENT = 'SME_Modified_Event';
    public static final String SME_EMAIL_TEMPLATE_CANCEL_EVENT = 'SME_Cancel_Event';

    public static final String SME_EMAIL_TEMPLATE_NEW_EVENT_EXTERNAL = 'SME_New_Event_for_External_User';
    public static final String SME_EMAIL_TEMPLATE_MODIFIED_EVENT_EXTERNAL = 'SME_Modified_Event_for_External_User';
    public static final String SME_EMAIL_TEMPLATE_CANCEL_EVENT_EXTERNAL = 'SME_Cancel_Event_for_External_User';

    public static final String APPROVED = 'Approved';

    public static final String AH_SUMMITED = 'AH Submitted';
    public static final String SUBMITTED = 'Submitted';
    
    public static final String REQUEST_OWNERSHIP = 'Request Ownership';
    public static final String REFER_OUT = 'Refer Out';
    public static final String RELEASE_OWNERSHIP = 'Release Ownership';
    public static final String RELEASE_OWNERSHIP_DEVNAME = 'Release_Ownership';
    public static final String YEAR_END_ASSIGNMENT = 'Year End Assignment';
    public static final String AUTO_CLOSED = 'Auto Closed';
    public static final String CLOSED = 'Closed';
    public static final String CONTACTED = 'Contacted';
    public static final String CALLREPORT_CLOSED = 'Closed / Cancelled Call Plan';
    public static final String SME_PROSPECT = 'SME-Prospect';
    public static final String SME_CUSTOMER = 'SME-Customer';
    public static final String CALL_REPORT = 'Call Report';
    public static final String CALL_REPORT_NO_PLAN = 'Call Report (No Plan)';
    public static final String SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN = 'Secondary Call Report Main Borrower (No plan)';
    public static final String CALL_PLAN = 'Call Plan';
    public static final String CLOSE_WON = 'Close Won';
    public static final String OPP = 'Opp';
    
    public static final String NEW_CALL_PLAN = 'New Call Plan';
    public static final String LEAD_FOR_SALES = 'Lead For Sales';
    public static final String LEAD_TO_DO = 'Lead To Do';
    public static final String LEAD_TO_INFORM = 'Lead To Inform';

    public static final String CAMPAIGN_REC = 'SME- Lead / Campaign';

    public static final String INTEGRATION_USER = 'KBANK-Integration';

    public static final String CREATE_WRITE_UP = 'Create Write Up';
    public static final String CMAS = 'CMAS';
    public static final String NON_CMAS = 'Non CMAS';
    public static final String NO_RC_CODE = 'NORCCODE';

    public static final String BAD = 'Bad';
    public static final String DEAD = 'Dead';
    public static final String CLOSED_BUSINESS = 'Closed Business';
    public static final String AMLO_LIST = 'AMLO List';
    public static final String EXIT_PLAN = 'Exit Plan';
    public static final String CRIMINAL_OFFENSE = 'Criminal Offense';
    public static final String OTHER_SEGMENT = 'Other Segment';
    public static final String REJECT = 'Reject';
    public static final String CLOSED_BY_SYSTEM = 'Closed by System';

    public static final String CAMPAIGN = 'Campaign';
    public static final String CANCEL_CAMPAIGN = 'Cancel Campaign';
    public static final String CANCEL_PROCESS = 'Cancelling Process';
    public static final String EXPIRE_PROCESS = 'Expiry Process';

    public static final String CANCEL_LEAD = 'Cancel Lead';
    public static final String EXPIRED = 'Expired';
    public static final String LEAD_EXPIRED = 'Lead Expired';

    public static final String PARTIAL_LOAN_SETUP = 'Partial Loan Setup';
    public static final String ALL_LOAN_SETUP = 'All Loan Setup';
    public static final String CLOSE_LOST = 'Closed Lost';

    public static final String CALL_REPORT_NO_PLAN_DEVNAME = 'CallReportNoPlan';
    public static final String CALL_PLAN_DEVNAME = 'CallPlan';
    public static final String NEW_CALL_PLAN_DEVNAME = 'New_Call_Plan';
    public static final String CALL_REPORT_DEVNAME = 'CallReport';
    public static final String SME_PROSPECT_DEVNAME = 'SME_Prospect';
    public static final String SME_CUSTOMER_DEVNAME = 'SME_Customer';
    public static final String SECONDARY_CALL_REPORT_NO_PLAN_DEVNAME = 'Secondary_Call_Report_No_plan';
    public static final String SECONDARY_CALL_REPORT_MAIN_BORROWER_NO_PLAN_DEVNAME = 'Secondary_Call_Report_Main_Borrower_No_plan';
    public static final String CLOSED_CANCELLED_CALLPLAN_DEVNAME = 'ClosedCancelledCallPlan';
    public static final String CLOSED_CANCELLED_CALLREPORT_NO_P_DEVNAME = 'ClosedCancelledCallReportNoPlan';
    public static final String CLOSED_CANCELLED_CALLREPORT_DEVNAME = 'ClosedCancelledCallReport';
    public static final String CONTACTED_CALLREPORT_NO_P_E_DEVNAME = 'Closed_Contacted_Call_Report_No_Plan_Editable';
    public static final String CONTACTED_CALLREPORT_E_DEVNAME = 'Closed_Contacted_Call_Report_Editable';

    public static final String OWNERSHIP_PERMANENT = 'Permanent';
    public static final String OWNERSHIP_TEMPORARY = 'Temporary';

    public static final String POOL_TEMPORARY = 'Pool (Temporary)';
    public static final String REASON_OTHER_TEAM = 'Other Team';
    public static final String REASON_WRONG_AREA = 'Wrong Area';
    public static final String REASON_NOT_SME = 'Not SME Segment';

    public static final String OWNERSHIP_REQUEST_POOL_DEVNAME = 'Request_Ownership_Pool_Temporary';
    public static final String OWNERSHIP_REQUEST_PORT_DEVNAME = 'Request_Ownership_Port';

    public static final String PRIMARY_SEGMENT_CODE_LM = 'LM';
    public static final String PRIMARY_SEGMENT_CODE_MI = 'MI';
    public static final String PRIMARY_SEGMENT_CODE_PC = 'PC';
    public static final String PRIMARY_SEGMENT_CODE_SM = 'SM';
    public static final String PRIMARY_SEGMENT_CODE_TC = 'TC';
    public static final String PRIMARY_SEGMENT_CODE_UM = 'UM';
    public static final String PRIMARY_SEGMENT_CODE_XS = 'XS';
    public static final String PRIMARY_SEGMENT_CODE_UR = 'UR';
    public static final String PRIMARY_SEGMENT_CODE_SR = 'SR';
    public static final String PRIMARY_SEGMENT_CODE_LR = 'LR';

    public static final String SEGMENT_SE = 'SE';
    public static final String SEGMENT_ME = 'ME';  
}