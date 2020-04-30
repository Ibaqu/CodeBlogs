import ballerina/http;
import ballerina/log;

http:Client airlineReservationEP = new("http://localhost:9091/airline");

@http:ServiceConfig {
    basePath:"/travel"
}
service travelReservationService on new http:Listener(9090) {

    @http:ResourceConfig {
        methods : ["POST"],
        path:"/reserve"
    }
    resource function reserveTicket(http:Caller caller, http:Request request) {
        http:Response response = new;
        json reqPayload = {};

        // Get the payload
        var payload = request.getJsonPayload();

        if (payload is json) {
            reqPayload = payload;
        } else {
            response.statusCode = 400;
            response.setJsonPayload({"Message":"Invalid payload"});
            var result = caller->respond(response);
            handleError(result);
            return;
        }

        http:Request outReqAirline = new;
        outReqAirline.setJsonPayload(<@untainted>reqPayload);


        // we send the payload to the airline service
        http:Response|error inResponseAirline = airlineReservationEP->post("/reserve", outReqAirline);

        if (inResponseAirline is http:Response) {
            var jsonResponse = inResponseAirline.getJsonPayload();

            if (jsonResponse is json) {
                if (jsonResponse.Message == "Success") {
                    response.statusCode = 200;
                    response.setJsonPayload({"Message" : "Reservation success"});
                }
            } else {
                response.statusCode = 404;
                response.setJsonPayload({"Message" : "Reservation failed"});
            }
        } else {
            response.statusCode = 400;
            response.setJsonPayload({"Message" : "Reservation failed"});
        }

        var result = caller->respond(response);
        handleError(result);
        return;
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

function generatePayload(json payload) returns json|error {

}