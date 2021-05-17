import ballerina/http;

function createPayloadErrResponse(http:Response response) {
    json errorJson = {message: "error while extracting payload"};
    response.statusCode = http:STATUS_BAD_REQUEST;
    response.setJsonPayload(errorJson);
}

function createErrorResponse(http:Response response, string errMsg) {
    json errorJson = {message: errMsg};
    response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
    response.setJsonPayload(errorJson);
}
