/**
* @author komsan.wi@beryl8.com
* @08/09/2015 create new
*/
public without sharing class YearEndModel {

    public class SavingResponse {
        public Boolean success;
        public Boolean duplicate;
        public String errorMessage;
        public SavingResponse() {
            success = true;
            duplicate = false;
        }
    }
    public virtual class CRUDResponse {
        public Boolean success;
        public String errorMessage;
        public List<SObject> records;
        public Integer total;
        public CRUDResponse() {
            records = new List<SObject>();
            success = true;
        }
    }
    /*public class YearEndCRUDResponse extends CRUDResponse{
        //public List<YearEnd> yearRecords;
        public YearEndCRUDResponse(CRUDResponse parents){
        	//yearRecords = new List<YearEnd>();
        	this.success = parents.success;
        	this.errorMessage = parents.errorMessage;
        	this.records = parents.records;
        	this.total = parents.total;
        }
    }*/
    public class Picklist {
        public String pvalue;
        public String pname;
        public Picklist(String pvalue,String pname){
            this.pvalue = pvalue;
            this.pname = pname;
        }
    }
    public class PicklistResponse {
        public Boolean success;
        public String errorMessage;
        public List<Picklist> records;
        public Integer total;
        public PicklistResponse() {
            records = new List<Picklist>();
            success = true;
        }
    }
    public class ReferOut {
        public String referoutSegment;
        public String referoutReason;
        public String referoutProvince;
        public String referoutAumpur;
        public String referoutTumbon;
        public String referoutTeam;
    }
    public class SelectedName {
        public String selectedbyTeampanel;
        public String selectedbyNamepanel;
        public String portPoolpanel;
        public String serviceRMpanel;
        public String selectedbyNameRequestpanel;
        public String portPoolRequestpanel;
        public String serviceRMRequestpanel;
    }
    public class SavingRequest {
        //public Context contx;
        public String contx;
        public Boolean deleteFinalAssign;
        public ReferOut referOut;
        public SelectedName selectName;
        public List<String> yearlist;
        //public String submitStatus;
    }
    public class QueryObj {
        public String sobjname;
        public String extraquery;
        public String fields;
        public String filter_en;
        public List<Map<String, String>> filter;
        public Integer start;
        public Integer recordCount;
        public List<Map<String, String>> sortParams;
    }
    public class QueryPickListObj {
        //public Integer limit;
        public String scope;
        public String subScope;
        public Boolean isAH;
        public Boolean selfInclude;
        public String query;
        public Integer start;
        public String extra;
    }
    public class FieldInfo {
        public String name;
        public Boolean modifiable;
        public Boolean sortable;
        public Boolean nillable;
        public String fieldType;
        public String label;
        public Boolean locked;
        public List<List<String> > picklistValues;
    }
    public class DescribeException extends Exception {}
}