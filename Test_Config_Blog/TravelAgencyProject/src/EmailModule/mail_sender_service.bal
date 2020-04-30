import ballerina/config;
import ballerina/http;
import ballerina/log;
import ballerina/email;


//Initializing the SMTP Client globally to be able to unit test the service resources
email:SmtpClient smtpClient = new(
    config:getAsString("MAIL_SMTP_HOST"), 
    config:getAsString("MAIL_SMTP_AUTH_USERNAME"),
    config:getAsString("MAIL_SMTP_AUTH_PASSWORD")
);

// Service initialization
@http:ServiceConfig {
    basePath: "/service"
}
service EmailSenderService on new http:Listener(config:getAsInt("EMAIL_SERVICE_PORT")) {
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/sendEmail"
    }
    resource function sendEmail(http:Caller caller, http:Request clientRequest) returns error? {
        http:Response res = new;
        json | error payload = clientRequest.getJsonPayload();

        if (payload is json) {
            string sender = payload.sender.toString();
            string[] recipient = [];
            json[] receivers = <json[]>payload.receivers;
            foreach var receiver in receivers {
                recipient.push(receiver.toString());
            }

            string mailContent = "Your booking has been confirmed!";
            string mailSubject = "[Virgin Airlines] Booking confirmation";

            //create email
            email:Email msg = {
                'from: config:getAsString("SENDER_MAIL"),
                to: recipient,
                subject: mailSubject,
                body: mailContent
            };

            // send email
            email:Error? response = smtpClient->send(msg);
            if (response is email:Error) {
                string errMsg = <string> response.detail()["message"];
                log:printError("error while sending the email: " + errMsg);
                createErrorResponse(res, errMsg);
            }
            
        } else {
            log:printError("invalid request received. payload should be json.", err = payload);
            createPayloadErrResponse(res);
        }

        error? respondResult = caller->respond(res);
        if (respondResult is error) {
            log:printError("error occurred while sending response", err = respondResult);
        }
    }
}

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
