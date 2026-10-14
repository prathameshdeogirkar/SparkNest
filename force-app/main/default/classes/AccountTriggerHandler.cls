public class AccountTriggerHandler {

    public static void handleBeforeDelete(List<Account> accounts) {

        Set<Id> accountIds = new Set<Id>();

        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

        List<Contact> contacts = [
            SELECT Id, AccountId
            FROM Contact
            WHERE AccountId IN :accountIds

            
        ];

        Map<Id, Integer> contactCountByAccountId = new Map<Id, Integer>();

for (Contact con : contacts) {

    if (!contactCountByAccountId.containsKey(con.AccountId)) {
        contactCountByAccountId.put(con.AccountId, 0);
    }

    contactCountByAccountId.put(
        con.AccountId,
        contactCountByAccountId.get(con.AccountId) + 1
    );
}

for (Account acc : accounts) {
    Integer contactCount = contactCountByAccountId.containsKey(acc.Id)
        ? contactCountByAccountId.get(acc.Id)
        : 0;

    if (contactCount >= 2) {
        acc.addError(
            'This Account cannot be deleted because it has two or more associated Contacts.'
        );
    }
}


    }

    public static void handleBeforeInsertOrUpdate (List <Account> accounts) {

    for (Account acc : accounts) {
        acc.Sales_Rep__c = acc.OwnerId;
    }

    
}

}