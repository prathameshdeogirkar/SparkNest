@isTest
public class AccountTriggerHandlerTest {

    @isTest
    static void testAccountWithTwoContactsCannotBeDeleted() {

        Account acc = new Account(
            Name = 'Test Account 2 Contacts'
        );
        insert acc;

        List<Contact> contacts = new List<Contact>{
            new Contact(
                LastName = 'Contact One',
                AccountId = acc.Id
            ),
            new Contact(
                LastName = 'Contact Two',
                AccountId = acc.Id
            )
        };
        insert contacts;

        Test.startTest();
        Database.DeleteResult result = Database.delete(acc, false);
        Test.stopTest();

        System.assertEquals(false, result.isSuccess());
        System.assertEquals(
            'This Account cannot be deleted because it has two or more associated Contacts.',
            result.getErrors()[0].getMessage()
        );
    }


    @isTest
    static void testAccountWithZeroContactsCanBeDeleted() {

        Account acc = new Account(
            Name = 'Test Account 0 Contacts'
        );
        insert acc;

        Test.startTest();
        Database.DeleteResult result = Database.delete(acc, false);
        Test.stopTest();

        System.assertEquals(true, result.isSuccess());
    }


    @isTest
    static void testAccountWithOneContactCanBeDeleted() {

        Account acc = new Account(
            Name = 'Test Account 1 Contact'
        );
        insert acc;

        Contact con = new Contact(
            LastName = 'Single Contact',
            AccountId = acc.Id
        );
        insert con;

        Test.startTest();
        Database.DeleteResult result = Database.delete(acc, false);
        Test.stopTest();

        System.assertEquals(true, result.isSuccess());
    }


    @isTest
    static void testBulk200AccountsCannotBeDeleted() {

        List<Account> accounts = new List<Account>();

        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(
                Name = 'Bulk Test Account ' + i
            ));
        }

        insert accounts;

        List<Contact> contacts = new List<Contact>();

        for (Account acc : accounts) {
            contacts.add(new Contact(
                LastName = 'Contact One',
                AccountId = acc.Id
            ));

            contacts.add(new Contact(
                LastName = 'Contact Two',
                AccountId = acc.Id
            ));
        }

        insert contacts;

        Test.startTest();
        List<Database.DeleteResult> results =
            Database.delete(accounts, false);
        Test.stopTest();

        System.assertEquals(200, results.size());

        Integer failedDeletes = 0;

        for (Database.DeleteResult result : results) {
            if (!result.isSuccess()) {
                failedDeletes++;
            }
        }

        System.assertEquals(
            200,
            failedDeletes,
            'All 200 Accounts should be prevented from deletion'
        );
    }
}