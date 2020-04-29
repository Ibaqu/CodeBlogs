import ballerina/http;
import ballerina/log;

// Service endpoint
listener http:Listener airlineEP = new(9091);

// Available flight classes
final string ECONOMY = "Economy";
final string BUSINESS = "Business";
final string FIRST = "First";

// Airline reservation service to reserve airline tickets
@http:ServiceConfig {
    basePath:"/airline"
}
service airlineReservationService on airlineEP {

    // Resource to reserve a ticket
    @http:ResourceConfig {
        methods:["POST"], 
        path:"/reserve", 
        consumes:["application/json"],
        produces:["application/json"]
    }
    resource function reserveTicket(http:Caller caller, http:Request request) {
        http:Response response = new;
        json reqPayload = {};
        var payload = request.getJsonPayload();
        // Try parsing the JSON payload from the request
        if (payload is json) {
            // Valid JSON payload
            reqPayload = payload;
        } else {
            // NOT a valid JSON payload
            response.statusCode = 400;
            response.setJsonPayload({"Message":"Invalid payload - Not a valid JSON payload"});
            var result = caller->respond(response);
            handleError(result);
            return;
        }

        json|error name = reqPayload.Name;
        json|error arrivalDate = reqPayload.ArrivalDate;
        json|error departDate = reqPayload.DepartureDate;
        json|error preferredClass = reqPayload.Preference;

        // If payload parsing fails, send a "Bad Request" message as the response
        if (name is error || arrivalDate is error || departDate is error || preferredClass is error) {
            response.statusCode = 500;
            response.setJsonPayload({"Message":"Internal Server Error - Error while processing request parameters"});
            var result = caller->respond(response);
            handleError(result);
            return;
        }

        // Mock logic
        // If request is for an available flight class, send a reservation successful status
        string preferredClassStr = preferredClass.toString();
        if (equalIgnoreCase(preferredClassStr, ECONOMY) || equalIgnoreCase(preferredClassStr, BUSINESS)) {
            response.setJsonPayload({"Status":"Success"});
        }
        else {
            // If request is not for an available flight class, send a reservation failure status
            response.setJsonPayload({"Status":"Failed"});
        }

        // Send the response
        var result = caller->respond(response);
        handleError(result);
    }

}

function equalIgnoreCase(string string1, string string2) returns boolean {
    return (string1.toLowerAscii() == string2.toLowerAscii());
}

function handleError(error? result) {
    if (result is error) {
        log:printError(result.reason(), err = result);
    }
}