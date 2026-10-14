@isTest
public class BankingAccountTriggerHandlerTest {

    @isTest
    static void testBankingAccountCreatesContact() {

        Account acc = new Account(
            Name = 'Banking Test Account',
            Phone = '9876543210',
            Industry = 'Banking'
        );

        Test.startTest();
        insert acc;
        Test.stopTest();

        Contact con = [
            SELECT LastName, Phone, AccountId
            FROM Contact
            WHERE AccountId = :acc.Id
            LIMIT 1
        ];

        System.assertEquals(
            'Banking Test Account',
            con.LastName
        );

        System.assertEquals(
            '9876543210',
            con.Phone
        );

        System.assertEquals(
            acc.Id,
            con.AccountId
        );
    }


    @isTest
    static void testNonBankingAccountDoesNotCreateContact() {

        Account acc = new Account(
            Name = 'Non Banking Test Account',
            Phone = '9123456780',
            Industry = 'Technology'
        );

        Test.startTest();
        insert acc;
        Test.stopTest();

        List<Contact> contacts = [
            SELECT Id
            FROM Contact
            WHERE AccountId = :acc.Id
        ];

        System.assertEquals(
            0,
            contacts.size()
        );
    }


    @isTest
    static void testBulk200BankingAccounts() {

        List<Account> accounts = new List<Account>();

        for (Integer i = 0; i < 200; i++) {

            accounts.add(
                new Account(
                    Name = 'Bulk Banking Account ' + i,
                    Phone = '9000000000',
                    Industry = 'Banking'
                )
            );
        }

        Test.startTest();
        insert accounts;
        Test.stopTest();

        List<Contact> contacts = [
            SELECT LastName, Phone, AccountId
            FROM Contact
            WHERE AccountId IN :accounts
        ];

        System.assertEquals(
            200,
            contacts.size(),
            'Each Banking Account should have exactly one Contact'
        );

        for (Contact con : contacts) {
            System.assertEquals(
                '9000000000',
                con.Phone
            );

            System.assertNotEquals(
                null,
                con.AccountId
            );
        }
    }
}