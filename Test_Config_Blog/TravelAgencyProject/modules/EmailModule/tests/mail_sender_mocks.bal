import ballerina/email;
import ballerina/log;

public client class MockSmtpClient {

    public function sendMessage(email:Message email) returns email:Error? {
        log:printDebug("calling mock email send function");
    }
}
