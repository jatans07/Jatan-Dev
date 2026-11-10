@restresource (URLmapping='/postman/*')
global class postmanRestResource {

@httpget
    global static List<Postman__c> getData(){
        return [select id, Name,First_Name__c,Last_Name__c from Postman__c];
    }    
@httppost

    global static id saveData(string name,string firstname,string lastname){
        Postman__c p = new Postman__c();
        p.First_Name__c = firstname;
        p.Last_Name__c = lastname;
        p.Name = name;
        insert p;
        
        return p.Id;
         
    }
@httpdelete
    global static string deletedata(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        system.debug('req '+req);
        system.debug('req '+req.requestURI);
        system.debug('id '+accountId);
    Postman__c post = [select id from Postman__c where id =: accountId];
        delete post;
        return 'deleted succesfully';
    }    
}