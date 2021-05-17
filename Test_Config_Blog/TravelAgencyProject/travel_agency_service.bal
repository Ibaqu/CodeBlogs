import ballerina/http;

string AIRLINE_RESERVATION_HOST = "localhost";
string AIRLINE_RESERVATION_PORT = "9092";

int TRAVEL_AGENCY_SERVICE_PORT = 9093;

string EMAIL_SERVICE_HOST = "localhost";
string EMAIL_SERVICE_PORT = "8083";
string EMAIL_SENDER_ADDR = "virgin-travels@bookings.com";

string airlineEP = "http://" + AIRLINE_RESERVATION_HOST + ":" + AIRLINE_RESERVATION_PORT;
string emailEP = "http://" + EMAIL_SERVICE_HOST + ":" + EMAIL_SERVICE_PORT;

http:Client airlineReservationEP = check new (airlineEP + "/airline");
http:Client mailingEP = check new (emailEP + "/email");

# Travel Reservation Service
service /travel on new http:Listener(TRAVEL_AGENCY_SERVICE_PORT) {

    resource function post reserve(http:Caller caller, http:Request request) {
        http:Response response = new;
        json reqPayload = {};

        // Get the payload
        json|error payload = request.getJsonPayload();

        if (payload is json) {
            reqPayload = payload;
        } else {
            response.statusCode = 400;
            response.setJsonPayload({"Message": "Invalid payload"});

            var result = caller->respond(response);
            handleError(result);
            return;
        }

        http:Request outReqAirline = new;
        outReqAirline.setJsonPayload(reqPayload);

        // Send the payload to Airline service
        http:Response|error inResponseAirline = airlineReservationEP->post("/reserve", outReqAirline);

        if (inResponseAirline is http:Response) {
            json|error jsonResponse = inResponseAirline.getJsonPayload();

            if (jsonResponse is json) {

                json|error jsonResponseMessage = jsonResponse.Message;

                if (jsonResponseMessage is json) {

                    if (jsonResponseMessage == "Success") {
                        response.statusCode = 200;
                        response.setJsonPayload({"Message": "Reservation success"});

                    } else {
                        response.statusCode = 500;
                        response.setJsonPayload({"Message": "Reservation failed"});
                    }

                } else {
                    response.statusCode = 404;
                    response.setJsonPayload({"Message" : "Reservation failed"});
                }

            } else {
                response.statusCode = 404;
                response.setJsonPayload({"Message": "Reservation failed"});
            }
        } else {
            response.statusCode = 400;
            response.setJsonPayload({"Message": "Reservation failed"});
        }

        var result = caller->respond(response);
        handleError(result);
        return;
    }

}
