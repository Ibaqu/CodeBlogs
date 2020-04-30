import ballerina/email;
import ballerina/log;

# Represents a mock SMTP Client, used to test the email API.
type MockSmtpClient object {
    
    public function send(email:Email email) returns email:Error? {
        log:printDebug("calling mock email send function");
    }
};
