import ballerina/test;
import ballerina/http;
import ballerina/config;


// Create a new Client Ep under the same name with the mock url
string mockAirlineEP = "http://" + config:getAsString("AIRLINE_RESERVATION_HOST") + ":" + config:getAsString("AIRLINE_RESERVATION_PORT");

string travelEndpoint = "http://localhost:" + config:getAsString("TRAVEL_AGENCY_SERVICE_PORT");
http:Client clientEP = new(travelEndpoint + "/travel");


@test:Config {
}
public function testReservation() {
    airlineReservationEP = new(mockAirlineEP + "/airline");

    json payload = {
        "Name":"Alice",
        "email": "alice@gmail.com",
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
            test:assertFail("Recieved error");
        }
    }

}
