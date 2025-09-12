/**
 * Test class for RecordValidator
 * 
 * @author: aarribas
 */
@IsTest
public with sharing class RecordValidatorTest
{
    public RecordValidatorTest() {}

    @IsTest
    static void testValidateRecordScenario1()
    {
        // Arrange
        Test_Object__c testRecord = (Test_Object__c) Test_Object__c.SObjectType.newSObject();
       
        // Set up the test record with invalid data
        testRecord.Name = 'Invalid Name';

        // Act
        Test.startTest();
            List<RecordValidator.Response> result = RecordValidator.invoke(new List<SObject>{testRecord});
        Test.stopTest();
        
        // Assert
        // Use tooling API to get the Validation Rule error message
        System.assertEquals(1, result.size());
        System.assertEquals('Error Message is: Expected error message', result[0].parsedErrors);
    }
}