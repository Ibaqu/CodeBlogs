import ballerina/http;
import ballerina/log;
import ballerina/config;

string airlineEP = "http://" + config:getAsString("AIRLINE_RESERVATION_HOST") + ":" + config:getAsString("AIRLINE_RESERVATION_PORT");
string emailEP = "http://" + config:getAsString("EMAIL_SERVICE_HOST") + ":" + config:getAsString("EMAIL_SERVICE_PORT");

http:Client airlineReservationEP = new(airlineEP + "/airline");
http:Client mailingEndpoint = new (emailEP + "/service");

@http:ServiceConfig {
    basePath:"/travel"
}
service travelReservationService on new http:Listener(config:getAsInt("TRAVEL_AGENCY_SERVICE_PORT")) {

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
                    //send ticket by email
                    json emailJson = <@untainted json>reqPayload.email;
                    http:Response|error sendEmailResult = sendEmail(emailJson.toString(), config:getAsString("EMAIL_SENDER_ADDR"));
                    if (sendEmailResult is http:Response) {
                        response.statusCode = 200;
                        response.setJsonPayload({"Message" : "Reservation success"});
                    } else {
                        response.statusCode = 404;
                        response.setJsonPayload({"Message" : "Reservation failed. Could not send reservation confirmation email."});
                    }
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

# Handles the confirmation email sending.
# 
# + sender - Email id of the sender
# + email - Email ids of the recipients
# + return - http:Response if success, else error
function sendEmail(string email, string sender) returns http:Response|error {
    
    http:Request outReq = new;
    json params = {
        "sender": sender,
        "receivers": [email]
    };
    outReq.setJsonPayload(params);
    var mailSendResponse = mailingEndpoint->post("/sendEmail", outReq);
    if (mailSendResponse is http:Response) {
        if (mailSendResponse.statusCode == http:STATUS_OK) {
	        return mailSendResponse;
	    } else {
	       return error("email sending failed. Received response code " + mailSendResponse.statusCode.toString());
	    }
    } else {
        return error("error occurred when sending the invitation");
    }
}
