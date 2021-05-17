import ballerina/test;
import ballerina/http;


// Create a new Client Ep under the same name with the mock url
http:Client clientEP = check new("http://localhost:9090/travel");



@test:Config {
}
public function testReservation() returns error? {
    airlineReservationEP = check new http:Client("http://localhost:8081/airline");

    json payload = {
        "Name":"Alice",
        "ArrivalDate":"12-03-2018",
        "DepartureDate":"13-04-2018",
        "Preference":"Business"
    };

    json expectedPayload = {
        "Message" : "Reservation success"
    };

    http:Request request = new;
    request.setJsonPayload(payload);

    http:Response|error response = clientEP->post("/reserve", request);

    if (response is http:ResponseMessage) {
        var jsonResponse = response.getJsonPayload();

        if (jsonResponse is json) {
            test:assertEquals(jsonResponse, expectedPayload);
        } else {
            test:assertFail("Recieved error "+ jsonResponse.toString());
        }
    }
}

@test:Config {
}
public function testReservationNegative() returns error? {
    airlineReservationEP = check new("http://localhost:8081/airline");

    json payload = {
        "Name":"Alice",
        "ArrivalDate":"12-03-2018",
        "DepartureDate":"13-04-2018",
        "Preference":"First"
    };

    json expectedPayload = {
        "Message" : "Reservation failed"
    };

    http:Request request = new;
    request.setJsonPayload(payload);

    http:Response|error response = clientEP->post("/reserve", request);

    if (response is http:ResponseMessage) {
        var jsonResponse = response.getJsonPayload();

        if (jsonResponse is json) {
            test:assertEquals(jsonResponse, expectedPayload);
        } else {
            test:assertFail("Recieved error "+ jsonResponse.toString());
        }
    }
}