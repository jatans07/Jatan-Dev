public with sharing class AccountController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(integer limitSize,integer offset) {
        return [
            SELECT Id, Name, AnnualRevenue, Industry
            FROM Account
            WITH SECURITY_ENFORCED
            ORDER BY Name
            limit :limitSize  offset :offset
        ];
    }
}