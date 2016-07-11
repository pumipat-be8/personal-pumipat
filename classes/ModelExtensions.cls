/**
* @author komsan.wi@beryl8.com
* @25/03/2015 create new
*/
public with sharing class ModelExtensions {
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
    public class Picklist {
        public String pvalue;
        public String pname;
        public Picklist(String pvalue,String pname){
            this.pvalue = pvalue;
            this.pname = pname;
        }
    }
    public class PicklistByFilterKey {
        public String pvalue;
        public String pname;
        public String pkey;
        public PicklistByFilterKey(String pvalue,String pname,String pkey){
            this.pvalue = pvalue;
            this.pname = pname;
            this.pkey = pkey;
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
    public class PicklistByFilterKeyResponse {
        public Boolean success;
        public String errorMessage;
        public List<PicklistByFilterKey> records;
        public Integer total;
        public PicklistByFilterKeyResponse() {
            records = new List<PicklistByFilterKey>();
            success = true;
        }
    }
    public class MapsResponse {
        public Boolean success;
        public String errorMessage;
        public Map<String,Map<String, String>> records;
        public Integer total;
        public MapsResponse() {
            records = new Map<String,Map<String, String>>();
            success = true;
        }
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
        public String segment;
        public String province;
        public String team;
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