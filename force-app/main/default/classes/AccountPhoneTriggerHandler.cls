public class AccountPhoneTriggerHandler {

    public static void handleAfterUpdate(
        List<Account> newAccounts,
        Map<Id, Account> oldMap,
        Map<Id, Account> newMap
    ) {
        Set<Id> accountIds = new Set<Id>();

        for (Account acc : newAccounts) {
            Account oldAcc = oldMap.get(acc.Id);

            if (acc.Phone != oldAcc.Phone) {
                accountIds.add(acc.Id);
            }
        }

        if (accountIds.isEmpty()) {
    return;
}

        List<Contact> contacts = [
    SELECT Id, AccountId, HomePhone, OtherPhone
    FROM Contact
    WHERE AccountId IN :accountIds
];

for (Contact con : contacts) {
    Account newAcc = newMap.get(con.AccountId);
    Account oldAcc = oldMap.get(con.AccountId);

    con.HomePhone = newAcc.Phone;
    con.OtherPhone = oldAcc.Phone;
}

if (!contacts.isEmpty()) {
    update contacts;
}
    }
}