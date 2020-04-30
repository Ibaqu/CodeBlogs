import ballerina/http;
import ballerina/config;

@http:ServiceConfig {
    basePath:"/airline"
}
service airlineReservationService on new http:Listener(config:getAsInt("AIRLINE_RESERVATION_PORT")) {

     // Resource to reserve a ticket
    @http:ResourceConfig {
        methods:["POST"], 
        path:"/reserve", 
        consumes:["application/json"],
        produces:["application/json"]
    }
    resource function reserveTicket(http:Caller caller, http:Request request) {
        http:Response response = new;
        response.setJsonPayload({"Message" : "Success"});

        var result = caller->respond(response);
        return;
    }
}

@http:ServiceConfig {
    basePath:"/service"
}
service emailSenderService on new http:Listener(config:getAsInt("EMAIL_SERVICE_PORT")) {

     // Resource to reserve a ticket
    @http:ResourceConfig {
        methods:["POST"], 
        path:"/sendEmail"
    }
    resource function sendEmail(http:Caller caller, http:Request request) {
        http:Response response = new;
        response.setJsonPayload({"Message" : "Success"});

        var result = caller->respond(response);
        return;
    }
}
