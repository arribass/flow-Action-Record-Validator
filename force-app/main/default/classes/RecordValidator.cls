/**
 * This class encapsulates the Logic for the Record Validator Flow Action
 * 
 * @author: aarribas
 */
public with sharing class RecordValidator
{
    public RecordValidator()
    {}

    /**
     * Method to invoke the validation of a record
     */
    @InvocableMethod(label='Validate Record' description='Validates a record by attempting to insert it in a transaction that is rolled back')
    public static List<Response> invoke(List<SObject> records)
    {
        // Validate input
        if (records == null || records.isEmpty())
        {
            return new List<Response>();
        }

        List<Response> responses = new List<Response>();
        RecordValidator validator = new RecordValidator();
        for (SObject record : records)
        {
            Response res = new Response();
            res.parsedErrors = validator.validateRecord(record);
            responses.add(res);
        }

        return responses;
    }

    /**
     * Validates the record by attempting to insert it in a transaction that is rolled back
     * 
     * @return: String with the error message
     */
    private String validateRecord(SObject s)
    {
        String parsedErrors = '';
        
        Savepoint sp = Database.setSavepoint();
        try
        {
            System.debug('Attempting to insert record: ' + s);
            insert s;
        }
        catch (DmlException e) 
        {
            System.debug('DML Exception occurred: ' + e.getMessage());
            parsedErrors = parseErrorMessages(e);
        }
        finally
        {
            System.debug('Rolling back transaction for record: ' + s);
            // insert was correct?
            if (parsedErrors == '')
            {
                System.debug('No errors found for record: ' + s);
            }
            Database.rollback(sp);
        }

        return parsedErrors;
    }

    /**
     * Parses the error messages from a DMLException to a readable String
     *
     *  @return: String with the error message
     */
    private String parseErrorMessages(DmlException dmlEx)
    {
        String errorMessage = '';
        for (Integer i = 0; i < dmlEx.getNumDml(); i++)
        {
            // parse something like this 
            //DML Exception occurred: Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Name for the record cannot be Invalid Name: [Name]
            errorMessage += dmlEx.getDmlMessage(i) + ' ';
            System.debug('Parsed error message: ' + errorMessage);
        }
        return errorMessage;
    }

    /**
     * Payload class to hold the input parameters for the invocable method
     */
    public class Payload
    {
        @InvocableVariable(label='Records' description='List of records to validate')
        public List<SObject> records;
    }

    /**
     * Response class to hold the output parameters for the invocable method
     */
    public class Response
    {
        @InvocableVariable(label='Parsed Errors' description='Result of the validation')
        public String parsedErrors;
    }
}