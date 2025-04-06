@isTest
public class ContactTriggerHandlerTest {

    @TestSetup
    public static void makeData(){
        //create sample accoounts
        List<Account> testAcc = new List<Account>();
        testAcc.add(new Account(Name = 'Unit Test I'));
        testAcc.add(new Account(Name = 'Unit Test II'));
        //insert the list of sample accounts
        insert testAcc;

        //create list of sample contacts
        List<Contact> testCon = new List<Contact>();
        //couple contacts with accounts 
        testCon.add(new Contact(LastName = 'Alpha Uno', AccountId = testAcc[0].Id, Active__c = true));
        testCon.add(new Contact(LastName = 'Beta Douis', AccountId = testAcc[0].Id, Active__c = true));
        testCon.add(new Contact(LastName = 'Charlie Trois', AccountId = testAcc[0].Id));
        testCon.add(new Contact(LastName = 'Delta Quatre', AccountId = testAcc[0].Id));
        testCon.add(new Contact(LastName = 'Echo Cinq', AccountId = testAcc[1].Id));
        //insert list of sample contacts 
        insert testCon;
    }

    @isTest
    public static void afterInsertTest2(){
        
        //retrieve accounts 
        List<Account> accList = [SELECT Id, Name, Active_Contacts__c FROM Account];
        System.assertEquals(2, accList.size(), 'list should contain 2 accounts'); //

        for (Account acc : accList){
            if (acc.Name == 'Unit Test I'){ //if account name is Unit Test I
                System.assertEquals(2, acc.Active_Contacts__c, 'active contacts field should have the value 2'); //
            }
            if (acc.Name == 'Unit Test II'){ //if account name is Unit Test II
                System.assertEquals(null, acc.Active_Contacts__c, 'active contacts field should be null'); //
            }
        }

        List<Contact> allContacts = [SELECT Id FROM Contact]; //retrieve all contacts
        System.assertEquals(5, allContacts.size(), '5 contacts should be returned'); //
    }
    //bulk test
    @isTest
    public static void afterInsertTestBulk(){

        Account testAcc = [SELECT Id FROM Account WHERE Name = 'Unit Test I'];
        List<Contact> testCon = new List<Contact>();
        for (Integer i = 0; i < 1000; i++){
            testCon.add(new Contact(LastName = 'Fox Con ' + 1, AccountId = testAcc.Id, Active__c = true));
        }

        insert testCon;
 
        List<Account> accList = [SELECT Id, Name, Active_Contacts__c FROM Account];
        System.assertEquals(2, accList.size(), '');

        for (Account acc : accList){
            if (acc.Name == 'Unit Test I'){
                System.assertEquals(1002, acc.Active_Contacts__c, '');
            }
            if (acc.Name == 'Unit Test II'){
                System.assertequals(null, acc.Active_Contacts__c, '');
            }
        }

        List<Contact> allContacts = [SELECT Id FROM Contact]; //retrieve all contacts
        System.assertEquals(1005, allContacts.size(), '5 contacts should be returned'); //
    }

    @isTest
    public static void afterUpdateTest1(){

        List<Contact> allContacts = [SELECT Id, LastName FROM Contact];

        for (Contact con : allContacts){
            if (con.Lastname == 'Charlie Trois' || con.LastName == 'Delta Quatre'){
                con.Active__c = true;
            }
        }
        Test.startTest();
        update allContacts;
        Test.stopTest();

        //retrieve accounts 
        List<Account> accList = [SELECT Id, Name, Active_Contacts__c FROM Account];
        System.assertEquals(2, accList.size(), 'list should contain 2 accounts'); //

        for (Account acc : accList){
            if (acc.Name == 'Unit Test I'){ //if account name is Unit Test I
                System.assertEquals(4, acc.Active_Contacts__c, 'active contacts field should have the value 2'); //
            }
            if (acc.Name == 'Unit Test II'){ //if account name is Unit Test II
                System.assertEquals(null, acc.Active_Contacts__c, 'active contacts field should be null'); //
            }
        }

        System.assertEquals(5, allContacts.size(), '5 contacts should be returned'); //
    }

    @isTest
    public static void afterUpdateTest2(){

        Account testAcc2 = [SELECT Id FROM Account WHERE Name = 'Unit Test II'];
        List<Contact> allContacts = [SELECT Id, LastName, Active__c FROM Contact];
        
        for (Contact con : allContacts){
            if (con.LastName == 'Charlie Trois'){
                con.Active__c = true;
                con.AccountId = testAcc2.Id;
            }
        }

        Test.startTest();
        update allContacts;
        Test.stopTest();

        List<Account> accList = [SELECT Id, Name, Active_Contacts__c FROM Account];
        System.assertequals(2, accList.size(), '');

        for (Account acc : accList){
            if (acc.Name == 'Unit Test I'){
                System.assertEquals(2, acc.Active_Contacts__c, '');
            }
            if (acc.Name == 'Unit Test II'){
                System.assertEquals(1, acc.Active_Contacts__c, '');
            }
        }

        System.assertEquals(5, allContacts.size(), '');

    } 

}