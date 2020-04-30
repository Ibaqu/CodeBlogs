import ballerina/http;

@http:ServiceConfig {
    basePath:"/airline"
}
service airlineReservationService on new http:Listener(8081) {

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