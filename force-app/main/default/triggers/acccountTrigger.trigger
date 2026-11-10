trigger acccountTrigger on Account (before update) {
    
    system.debug('Inside Account trigger');
	List<contact> con= [select id , name ,accountid from contact where accountid in :trigger.new];
    
    Map<id,List<Contact>> accountContactMap = new Map<id,List<Contact>>();
	
    for(contact c : con){
        if (accountContactMap.containsKey(c.AccountId)){
            List<Contact> newContact = accountContactMap.get(c.AccountId);
            newContact.add(c);
            accountContactMap.put(c.AccountId,newContact);
        }
        else{
            accountContactMap.put(c.AccountId,new List<contact>{c});
        }
    }
    
    for(id key : accountContactMap.keySet()){
        for(contact contact : accountContactMap.get(key) ){
            contact.Email ='jsharma@wm.com';
            update contact;
        }
    }
}