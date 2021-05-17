import ballerina/email;
import ballerina/log;
import ballerina/http;
import ballerina/lang.'int as ints;

string MAIL_SMTP_HOST = "smtp.serveraddress.com";
string MAIL_SMTP_AUTH_USERNAME = "test";
string MAIL_SMTP_AUTH_PASSWORD = "test";

string EMAIL_SERVICE_HOST = "localhost";
string EMAIL_SERVICE_PORT = "8083";
string EMAIL_SENDER_ADDR = "virgin-travels@bookings.com";

string SENDER_MAIL = "email@gmail.com";

// Initializing the SMTP Client globale
email:SmtpClient smtpClient = check new (
    MAIL_SMTP_HOST,
    MAIL_SMTP_AUTH_USERNAME,
    MAIL_SMTP_AUTH_PASSWORD
);

# Email sender service
service /email on new http:Listener(check ints:fromString(EMAIL_SERVICE_PORT)) {

    resource function post sendEmail(http:Caller caller, http:Request request) returns error? {
        http:Response res = new;

        json | error payload = request.getJsonPayload();

        if (payload is json) {
            json payloadSender = check payload.sender;
            string sender =  payloadSender.toString();

            string[] recipient = [];

            json payloadReceivers = check payload.receivers;

            json[] receivers = <json[]>payloadReceivers;
            foreach var receiver in receivers {
                recipient.push(receiver.toString());
            }

            string mailContent = "Your booking has been confirmed!";
            string mailSubject = "[Virgin Airlines] Booking confirmation";

             //create email
            email:Message msg = {
                'from: sender,
                to: recipient,
                subject: mailSubject,
                body: mailContent
            };

            // send email
            email:Error? response = smtpClient->sendMessage(msg);
            if (response is email:Error) {
                string errMsg = response.detail().toString();
                log:printError("error while sending the email: ", 'error = response);
                createErrorResponse(res, errMsg);
            }

        } else {
            log:printError("invalid request recived. payload should be json.");
            createPayloadErrResponse(res);
        }

        error? respondResult = caller->respond(res);
        if (respondResult is error) {
            log:printError("error occurred while sending response", 'error = respondResult);
        }

    }

}

