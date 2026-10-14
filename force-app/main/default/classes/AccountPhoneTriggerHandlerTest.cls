@isTest
public class AccountPhoneTriggerHandlerTest {

    @isTest
    static void testAccountPhoneSynchronization() {

        Account acc = new Account(
            Name = 'Phone Sync Test',
            Phone = '1111111111'
        );
        insert acc;

        Contact con = new Contact(
            LastName = 'Test Contact',
            AccountId = acc.Id
        );
        insert con;

        Test.startTest();

        acc.Phone = '2222222222';
        update acc;

        Test.stopTest();

        Contact updatedContact = [
            SELECT HomePhone, OtherPhone
            FROM Contact
            WHERE Id = :con.Id
        ];

        System.assertEquals(
            '2222222222',
            updatedContact.HomePhone
        );

        System.assertEquals(
            '1111111111',
            updatedContact.OtherPhone
        );
    }


    @isTest
    static void testBulk200AccountPhoneSynchronization() {

        List<Account> accounts = new List<Account>();

        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(
                Name = 'Bulk Phone Account ' + i,
                Phone = '1000000000'
            ));
        }

        insert accounts;

        List<Contact> contacts = new List<Contact>();

        for (Account acc : accounts) {
            contacts.add(new Contact(
                LastName = 'Bulk Contact',
                AccountId = acc.Id
            ));
        }

        insert contacts;

        for (Account acc : accounts) {
            acc.Phone = '2000000000';
        }

        Test.startTest();
        update accounts;
        Test.stopTest();

        List<Contact> updatedContacts = [
            SELECT AccountId, HomePhone, OtherPhone
            FROM Contact
            WHERE AccountId IN :accounts
        ];

        System.assertEquals(
            200,
            updatedContacts.size()
        );

        for (Contact con : updatedContacts) {
            System.assertEquals(
                '2000000000',
                con.HomePhone
            );

            System.assertEquals(
                '1000000000',
                con.OtherPhone
            );
        }
    }
}