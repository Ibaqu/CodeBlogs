import ballerina/http;
import ballerina/test;
import ballerina/log;
import ballerina/email;


string emailEPUrl = "http://" + EMAIL_SERVICE_HOST + ":" + EMAIL_SERVICE_PORT;

http:Client emailEP = check new (emailEPUrl + "/service");
MockSmtpClient mockSmtpClient = new;

@test:BeforeSuite
public function setup() {
    log:printDebug("assigning mock SMTP client");
    smtpClient = test:mock(email:SmtpClient, new MockSmtpClient());
}

@test:Config {}
public function sendConfirmationEmailTest() {
    http:Request req = new;
    json payload = {
        sender: EMAIL_SENDER_ADDR,
        mailType: "confirmation",
        receivers: ["alice@gmail.com"]
    };
    req.setJsonPayload(payload);
    http:Response res = checkpanic emailEP->post("/sendEmail", req);
    test:assertEquals(res.statusCode, http:STATUS_OK);

    payload = {
        sender: "",
        mailType: "cancellation",
        receivers: ["alice@gmail.com"]
    };
    req.setJsonPayload(payload);
    res = checkpanic emailEP->post("/sendEmail", req);
    test:assertEquals(res.statusCode, http:STATUS_OK);
    
}



