trigger contactTrigger on Contact (After insert) {
system.debug('Inside Contact trigger');
    List<account> accountToUpdate = new List<account>();
        system.debug('Contact >>>>> '+ Trigger.New);
        List<Contact> con = [select id, name,Email, account.name,account.totalNumberOfChild__c,accountid from contact where id IN :Trigger.New];
	for(contact c: con){
        if(c.AccountId !=null){
            
       
        account ac = new account();
        ac.Id = c.AccountId;
        if(c.account.totalNumberOfChild__c == null ){
            ac.totalNumberOfChild__c =1;
        }
        else{
            ac.totalNumberOfChild__c =c.account.totalNumberOfChild__c + 1;
        }
        accountToUpdate.add(ac);
	}
	if(accountToUpdate.size()>0)
	{
	update accountToUpdate;
	}
    }
    
}