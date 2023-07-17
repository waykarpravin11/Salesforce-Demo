/*
* Purpose : Apex class used for parsing the results from the Calendric API to fetch holidays
* @author         Pravin Waykar
* @modifiedBy     Pravin Waykar
* @version        1.0
* @created        2023-07-15
* @modified       2023-07-15
*/
public class JSON2ApexHoliday{
    public cls_meta meta;
	public cls_response response;
	public class cls_meta {
		public Integer code;	//200
	}
	public class cls_response {
		public cls_holidays[] holidays;
	}
	public class cls_holidays {
        public String name{get;set;}	//Name of holiday goes here
		public String description{get;set;}	//Description of holiday goes here
		public cls_date date_x{get;set;}
		//public cls_type[] type;
	}
	public class cls_date {
		public String iso{get;set;}	//2018-12-31
	}
	
}