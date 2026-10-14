public class BankingAccountTriggerHandler {

    public static void handleAfterInsert(List<Account> accounts) {

        List<Contact> contactsToCreate = new List<Contact>();

        for (Account acc : accounts) {

            if (acc.Industry == 'Banking') {

                contactsToCreate.add(
                    new Contact(
                        LastName = acc.Name,
                        Phone = acc.Phone,
                        AccountId = acc.Id
                    )
                );
            }
        }

        if (!contactsToCreate.isEmpty()) {
            insert contactsToCreate;
        }
    }
}