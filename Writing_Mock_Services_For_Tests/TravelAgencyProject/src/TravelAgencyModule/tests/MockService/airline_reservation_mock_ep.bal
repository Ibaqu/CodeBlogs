import ballerina/http;
import ballerina/io;

json successPayload = {
    "Status" : "Success"
};

json failurePayload = {
    "Status" : "Failure"
};

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
    resource function reserveTicket(http:Caller caller, http:Request request) returns @tainted error?{
        http:Response response = new;

        //Get the payload content of the request
        json|error payload = request.getJsonPayload();
        
        //Do some mock computation
        if (payload is json) {
            json preferredClass = check payload.Preference;
            string preferredClassStr = preferredClass.toString();
                
            if (equalIgnoreCase(preferredClassStr, "Economy") || equalIgnoreCase(preferredClassStr, "Business")) {
                io:println("HIt economy or buisiness");
                response.setJsonPayload(successPayload);
            } else {
                // If request is not for an available flight class (first class), send a reservation failure status
                io:println("Unavailable");
                response.setJsonPayload(failurePayload);
            }
            
        } else {
            io:println("Not json");
            response.setJsonPayload(failurePayload);
        }

        var result = caller->respond(response);
        return;
    }
}