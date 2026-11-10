@RestResource(urlMapping='/cases/*')
global with sharing class CasesRestResource {
    private static final Integer MAX_CASES = 200;

    @HttpGet
    global static void getCases() {
        String caseIdText = getPathId();
        if (caseIdText == null) {
            try {
                List<Case> cases = [
                    SELECT Id, CaseNumber, Subject, Status, Origin, Priority,
                        Description, AccountId, ContactId, OwnerId, CreatedDate,
                        LastModifiedDate
                    FROM Case
                    WITH USER_MODE
                    ORDER BY CreatedDate DESC
                    LIMIT :MAX_CASES
                ];
                writeJson(200, cases);
            } catch (QueryException ex) {
                writeError(403, 'You do not have permission to read Case records.');
            }
            return;
        }

        Id caseId = parseCaseId(caseIdText);
        if (caseId == null) {
            return;
        }

        try {
            List<Case> cases = [
                SELECT Id, CaseNumber, Subject, Status, Origin, Priority,
                    Description, AccountId, ContactId, OwnerId, CreatedDate,
                    LastModifiedDate
                FROM Case
                WHERE Id = :caseId
                WITH USER_MODE
                LIMIT 1
            ];
            if (cases.isEmpty()) {
                writeError(404, 'Case not found.');
                return;
            }
            writeJson(200, cases[0]);
        } catch (QueryException ex) {
            writeError(403, 'You do not have permission to read this Case.');
        }
    }

    @HttpPost
    global static void createCase() {
        Case caseRecord = readCaseBody();
        if (caseRecord == null) {
            return;
        }

        try {
            Database.insert(caseRecord, AccessLevel.USER_MODE);
            writeJson(201, caseRecord);
        } catch (TypeException ex) {
            writeError(403, 'You do not have permission to create Case records.');
        } catch (DmlException ex) {
            writeError(400, ex.getDmlMessage(0));
        }
    }

    @HttpPut
    global static void replaceCase() {
        updateCase();
    }

    @HttpPatch
    global static void updateCaseFields() {
        updateCase();
    }

    @HttpDelete
    global static void deleteCase() {
        Id caseId = getRequiredCaseId();
        if (caseId == null) {
            return;
        }

        try {
            List<Case> cases = [
                SELECT Id
                FROM Case
                WHERE Id = :caseId
                WITH USER_MODE
                LIMIT 1
            ];
            if (cases.isEmpty()) {
                writeError(404, 'Case not found.');
                return;
            }

            Database.delete(cases[0], AccessLevel.USER_MODE);
            RestContext.response.statusCode = 204;
        } catch (QueryException ex) {
            writeError(403, 'You do not have permission to delete this Case.');
        } catch (TypeException ex) {
            writeError(403, 'You do not have permission to delete this Case.');
        } catch (DmlException ex) {
            writeError(400, ex.getDmlMessage(0));
        }
    }

    private static void updateCase() {
        Id caseId = getRequiredCaseId();
        if (caseId == null) {
            return;
        }

        Case caseRecord = readCaseBody();
        if (caseRecord == null) {
            return;
        }
        if (caseRecord.Id != null && caseRecord.Id != caseId) {
            writeError(400, 'The Case ID in the body must match the URL.');
            return;
        }
        caseRecord.Id = caseId;

        try {
            List<Case> cases = [
                SELECT Id
                FROM Case
                WHERE Id = :caseId
                WITH USER_MODE
                LIMIT 1
            ];
            if (cases.isEmpty()) {
                writeError(404, 'Case not found.');
                return;
            }

            Database.update(caseRecord, AccessLevel.USER_MODE);
            writeJson(200, caseRecord);
        } catch (QueryException ex) {
            writeError(403, 'You do not have permission to update this Case.');
        } catch (TypeException ex) {
            writeError(403, 'You do not have permission to update this Case.');
        } catch (DmlException ex) {
            writeError(400, ex.getDmlMessage(0));
        }
    }

    private static Case readCaseBody() {
        if (RestContext.request.requestBody == null) {
            writeError(400, 'A JSON Case body is required.');
            return null;
        }

        try {
            return (Case) JSON.deserialize(
                RestContext.request.requestBody.toString(),
                Case.class
            );
        } catch (JSONException ex) {
            writeError(400, 'The request body must be valid Case JSON.');
            return null;
        }
    }

    private static Id getRequiredCaseId() {
        String caseIdText = getPathId();
        if (caseIdText == null) {
            writeError(400, 'A Case ID is required in the URL.');
            return null;
        }
        return parseCaseId(caseIdText);
    }

    private static String getPathId() {
        String requestUri = RestContext.request.requestURI;
        Integer lastSlash = requestUri.lastIndexOf('/');
        if (lastSlash < 0 || lastSlash == requestUri.length() - 1) {
            return null;
        }
        String pathId = requestUri.substring(lastSlash + 1);
        return pathId == 'cases' ? null : pathId;
    }

    private static Id parseCaseId(String caseIdText) {
        if (caseIdText.length() != 15 && caseIdText.length() != 18) {
            writeError(400, 'The Case ID in the URL is invalid.');
            return null;
        }

        try {
            Id caseId = (Id) caseIdText;
            if (caseId.getSObjectType() != Case.SObjectType) {
                writeError(400, 'The URL ID must belong to a Case.');
                return null;
            }
            return caseId;
        } catch (StringException ex) {
            writeError(400, 'The Case ID in the URL is invalid.');
            return null;
        }
    }

    private static void writeJson(Integer statusCode, Object responseBody) {
        RestContext.response.statusCode = statusCode;
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(responseBody));
    }

    private static void writeError(Integer statusCode, String message) {
        writeJson(statusCode, new Map<String, String>{ 'error' => message });
    }
}
