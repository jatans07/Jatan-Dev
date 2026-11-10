@IsTest
private class CasesRestResourceTest {
    @IsTest
    static void getCollectionAndSingleCase() {
        Case caseRecord = createCase('GET test');
        insert caseRecord;

        setRequest('GET', '/services/apexrest/cases');
        Test.startTest();
        CasesRestResource.getCases();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('GET test'));

        setRequest('GET', '/services/apexrest/cases/' + caseRecord.Id);
        CasesRestResource.getCases();
        System.assertEquals(200, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('GET test'));
    }

    @IsTest
    static void createCaseFromJson() {
        Case caseRecord = createCase('POST test');
        setRequest('POST', '/services/apexrest/cases', JSON.serialize(caseRecord));

        Test.startTest();
        CasesRestResource.createCase();
        Test.stopTest();

        System.assertEquals(201, RestContext.response.statusCode);
        System.assertNotEquals(
            null,
            [SELECT Id FROM Case WHERE Subject = 'POST test' LIMIT 1].Id
        );
    }

    @IsTest
    static void updateCaseWithPutAndPatch() {
        Case caseRecord = createCase('Original subject');
        insert caseRecord;

        setRequest(
            'PATCH',
            '/services/apexrest/cases/' + caseRecord.Id,
            '{"Subject":"PATCH subject"}'
        );
        Test.startTest();
        CasesRestResource.updateCaseFields();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(
            'PATCH subject',
            [SELECT Subject FROM Case WHERE Id = :caseRecord.Id].Subject
        );

        setRequest(
            'PUT',
            '/services/apexrest/cases/' + caseRecord.Id,
            '{"Subject":"PUT subject"}'
        );
        CasesRestResource.replaceCase();
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(
            'PUT subject',
            [SELECT Subject FROM Case WHERE Id = :caseRecord.Id].Subject
        );
    }

    @IsTest
    static void deleteCase() {
        Case caseRecord = createCase('DELETE test');
        insert caseRecord;
        setRequest('DELETE', '/services/apexrest/cases/' + caseRecord.Id);

        Test.startTest();
        CasesRestResource.deleteCase();
        Test.stopTest();

        System.assertEquals(204, RestContext.response.statusCode);
        System.assertEquals(0, [SELECT COUNT() FROM Case WHERE Id = :caseRecord.Id]);
    }

    @IsTest
    static void rejectInvalidRequests() {
        setRequest('GET', '/services/apexrest/cases/not-an-id');
        CasesRestResource.getCases();
        System.assertEquals(400, RestContext.response.statusCode);

        setRequest('GET', '/services/apexrest/cases/000000000000000');
        CasesRestResource.getCases();
        System.assertEquals(400, RestContext.response.statusCode);

        Account accountRecord = new Account(Name = 'Wrong object ID');
        insert accountRecord;
        setRequest('GET', '/services/apexrest/cases/' + accountRecord.Id);
        CasesRestResource.getCases();
        System.assertEquals(400, RestContext.response.statusCode);

        setRequest('POST', '/services/apexrest/cases');
        CasesRestResource.createCase();
        System.assertEquals(400, RestContext.response.statusCode);

        setRequest('POST', '/services/apexrest/cases', '{"Subject":');
        CasesRestResource.createCase();
        System.assertEquals(400, RestContext.response.statusCode);

        Case caseRecord = createCase('Mismatch test');
        Case otherCase = createCase('Other test');
        insert new List<Case>{ caseRecord, otherCase };
        setRequest(
            'PATCH',
            '/services/apexrest/cases/' + caseRecord.Id,
            '{"Id":"' + otherCase.Id + '","Subject":"Mismatch"}'
        );
        CasesRestResource.updateCaseFields();
        System.assertEquals(400, RestContext.response.statusCode);

        delete otherCase;
        setRequest('DELETE', '/services/apexrest/cases/' + otherCase.Id);
        CasesRestResource.deleteCase();
        System.assertEquals(404, RestContext.response.statusCode);
    }

    @IsTest
    static void handlePermissionFailures() {
        User noCaseAccessUser = createUser('Minimum Access - Salesforce');
        User readOnlyUser = createUser('Read Only');
        Case caseRecord = createCase('Permission test');
        caseRecord.OwnerId = readOnlyUser.Id;
        insert caseRecord;

        System.runAs(noCaseAccessUser) {
            setRequest('GET', '/services/apexrest/cases');
            CasesRestResource.getCases();
            System.assertEquals(403, RestContext.response.statusCode);

            setRequest('GET', '/services/apexrest/cases/' + caseRecord.Id);
            CasesRestResource.getCases();
            System.assertEquals(403, RestContext.response.statusCode);

            setRequest(
                'PATCH',
                '/services/apexrest/cases/' + caseRecord.Id,
                '{"Subject":"No access"}'
            );
            CasesRestResource.updateCaseFields();
            System.assertEquals(403, RestContext.response.statusCode);

            setRequest('DELETE', '/services/apexrest/cases/' + caseRecord.Id);
            CasesRestResource.deleteCase();
            System.assertEquals(403, RestContext.response.statusCode);
        }

        System.runAs(readOnlyUser) {
            setRequest(
                'POST',
                '/services/apexrest/cases',
                '{"Subject":"Cannot create","Status":"' + caseRecord.Status +
                    '","Origin":"' + caseRecord.Origin + '"}'
            );
            CasesRestResource.createCase();
            System.assertEquals(403, RestContext.response.statusCode);

            setRequest(
                'PATCH',
                '/services/apexrest/cases/' + caseRecord.Id,
                '{"Subject":"Cannot update"}'
            );
            CasesRestResource.updateCaseFields();
            System.assertEquals(403, RestContext.response.statusCode);

            setRequest('DELETE', '/services/apexrest/cases/' + caseRecord.Id);
            CasesRestResource.deleteCase();
            System.assertEquals(403, RestContext.response.statusCode);
        }
    }

    @IsTest
    static void handleDmlValidationFailures() {
        Account accountRecord = new Account(Name = 'Invalid Case owner');
        insert accountRecord;

        Case invalidCreate = createCase('Invalid owner');
        invalidCreate.OwnerId = accountRecord.Id;
        setRequest('POST', '/services/apexrest/cases', JSON.serialize(invalidCreate));
        CasesRestResource.createCase();
        System.assertEquals(400, RestContext.response.statusCode);

        Case caseRecord = createCase('Update validation test');
        insert caseRecord;
        Case invalidUpdate = new Case(
            Id = caseRecord.Id,
            OwnerId = accountRecord.Id
        );
        setRequest(
            'PATCH',
            '/services/apexrest/cases/' + caseRecord.Id,
            JSON.serialize(invalidUpdate)
        );
        CasesRestResource.updateCaseFields();
        System.assertEquals(400, RestContext.response.statusCode);
    }

    private static User createUser(String profileName) {
        String uniqueName = 'case.rest.' + profileName.replace(' ', '.') + '.' +
            DateTime.now().getTime() + '@example.com';
        User userRecord = new User(
            Alias = 'caserest',
            Email = uniqueName,
            EmailEncodingKey = 'UTF-8',
            LastName = 'Case REST Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = uniqueName
        );
        insert userRecord;
        return userRecord;
    }

    private static Case createCase(String subject) {
        List<Schema.PicklistEntry> statuses = Case.Status.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> origins = Case.Origin.getDescribe().getPicklistValues();
        return new Case(
            Subject = subject,
            Status = statuses[0].getValue(),
            Origin = origins[0].getValue()
        );
    }

    private static void setRequest(String method, String uri) {
        setRequest(method, uri, null);
    }

    private static void setRequest(String method, String uri, String body) {
        RestRequest request = new RestRequest();
        request.requestURI = uri;
        request.httpMethod = method;
        if (body != null) {
            request.requestBody = Blob.valueOf(body);
        }
        RestContext.request = request;
        RestContext.response = new RestResponse();
    }
}
