/**
* @author Chrnun.t@beryl8.com
* @08/09/2015 create new
*/
public without sharing class SME_BulkAssignment_Model{
    public class SelectedName {
    	public String selectedbyname;
    	public String selectedByRMName;
    	public String selectedbyAHname;
    	public String filterByRMName;
        public String portPoolpanel;
        public String serviceRMpanel;
        public String temporaryRMpanel;
    }
    public class SavingRequest {
        public String contx;
        public SelectedName selectName;
        public List<String> bulkCISlist;
        public String gridName;
    }
}