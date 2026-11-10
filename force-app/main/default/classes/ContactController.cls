public with sharing class ContactController {
    
    @AuraEnabled (cacheable=true)
    public static List<contact> getContacts() {
        
        return [select id,FirstName, LastName, Email from contact];
    }
}