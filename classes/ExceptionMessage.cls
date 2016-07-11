/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   A exception message class for the project

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
05/28/2015  Charnun.T           First Create
------------------------------------------------------------*/
public with sharing class ExceptionMessage {
    
    public static String ERROR_HEADER = '[Error] : ';
    public static String ADMIN_VALUE = 'Please contact Admin.';

    // Database Error
    public static String CANNOT_INSERT_TRANSACTION = ERROR_HEADER + 'Can\'t insert data on system.' + ADMIN_VALUE;
    public static String CANNOT_UPDATE_TRANSACTION = ERROR_HEADER + 'Can\'t update data on system.' + ADMIN_VALUE;
    public static String CANNOT_UPSERT_TRANSACTION = ERROR_HEADER + 'Can\'t upsert data on system.' + ADMIN_VALUE;
    public static String CANNOT_DELETE_TRANSACTION = ERROR_HEADER + 'Can\'t delete data on system.' + ADMIN_VALUE;
    public static String CANNOT_ROOLBACK_TRANSACTION = ERROR_HEADER + 'Can\'t rollback data on system.' + ADMIN_VALUE;

    // Batch Error

    
    // Trigger Error


    // Query Error
    public static String QUERY_TIMEOUT = '' + ADMIN_VALUE;

    // REST Satisfaction Survey
    public static String NO_SGID_ACCOUNT = ERROR_HEADER + 'This error began when didn\'t found SFIG account. ';
    public static String NO_CONTACT_WITH_THIS_PHONE = ERROR_HEADER + 'This error began when didn\'t found Contact according phone number :';

    // Class Error
    public static String COMPANY_CODE_IS_NULL = ERROR_HEADER + 'Please provide Company Code' + ADMIN_VALUE;
    public static String ADDRESS_INFORMATION_IS_NULL = ERROR_HEADER + 'Please provide address information' + ADMIN_VALUE;
    public static String NO_AUTHORIZATION_USER = 'No authorization to change user information';


    // CustomerSearchController
    public static String ALREADY_SUBMMITTED = 'This Customer already submitted for ownership request, cannot re-submit';
    public static String ALL_PARAM_ARE_NULL = 'One search field must be entered';
    public static String ALL_PARAM_ARE_NULL_TH = 'ระบุเงื่อนไขในการค้นหา';
    public static String TIME_OUT = 'Time out, please try again.';
    public static String NO_MATCH_RECORD = 'No matching record found';
    public static String NO_MATCH_RECORD_TH = 'ไม่พบข้อมูล';
    public static String UNEXPECTED_ERROR = 'Unexpected Error has occurred.';
    public static String SORT_FAILED = 'Failed to sort data';
    public static String SEARCH_FAILED = 'Failed to search data';
    // HTTP Call 
    public static String BACKEND_ERROR = 'Found Error from the backend';
    public static String INVALID_RESPONSE = 'Got Invalid format response from the backend:';
    public static String HTTP_CONNECTION_FAILED = 'Connection problem occurred:';
    public static String CI_RESPONSE_ERROR = 'Found error message from CI Webservice:';
    public static String PARSE_FAILED = 'Failed to parse the invalid format response:';

    public static String APPLICATION_SERVER_NOT_AVAILABLE = 'Application server is not available';
    public static String APPLICATION_TIMEOUT = 'Application Time Out';
    public static String DATABASE_NOT_AVAILABLE = 'Database is not available';
    public static String DATABASE_CONNECTION_FAILED = 'Database connection Fail';
    public static String ADAPTER_NOT_AVAILABLE = 'Adapter is not available';
    public static String HOST_NOT_AVAILABLE = 'Host is not available';
    public static String HOST_TIMEOUT = 'Host Time Out';
    public static String HOST_EXCEPTION = 'Host Connection Exception';
    public static String AUTHENTICATION_FAILED = 'Authentication is possible but has failed';
}