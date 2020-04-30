# Writing Ballerina Unit Tests

Writing test cases in Ballerina aims to verify the logic of a part of code or the overall flow of the program, taking into account both happy and sad
circumstances that can occur when the code runs. Having an automated test suite ensures that your program or service performs as expected under different conditions.

The aim of writing tests is to have an extensive coverage of the code, taking into consideration as many possibilities within the limits of the Testing Framework.

Inorder to understand the scope of testing code in general, we need to understand the concept of the Testing Pyramid. The Testing Pyramid applies to Ballerina code as it does to many other languages.

__Testing Pyramid__

The Testing Pyramid is a guideline on how different kinds of automated tests can be created depending on the program we are testing.

![alt text](Writing_Ballerina_Unit_Tests/Blog/Pyramid.png)

There are 3 main kinds of tests that can be written keeping the Pyramid as a reference.

- UI Tests
- Service Tests / Integration Tests
- Unit Tests

Its important to note that you should have more low-level unit tests than high level UI tests. We will be focusing on the writing Unit tests in this blog.

## Writing Unit Tests

Regardless of language, Unit tests generally have similar characteristics. They are used to test the code at a low level with as much coverage as possible, while taking into account happy and sad scenarios as well.

In this blog we will be going through the following aspects of Unit testing in Ballerina code

- Project structure for Unit tests
- Writing some simple unit tests for a Ballerina service
- Generating a Code coverage report
- Writing negative test cases

### Project Structure for Unit Tests

In a Ballerina project, test cases are written in a separate directory/folder named tests. This is automatically generated when creating a new module.  It allows you to isolate the test files from the source, making it easy to maintain and execute.  In a standard Ballerina project, a module is mapped to a single test suite, and every test file within the tests folder is considered part of the same test suite.

// Have an image of the program structure here

It is recommended to keep Unit tests within the same module that we are testing. This has the benefit of getting a more understandable code coverage when dealing with the code functionality that a Ballerina program or service can provide

### Writing simple Unit tests for a Ballerina service

As with other languages, Ballerina follows a similar way of writing Unit tests.

1. Define the expected and desired output of the test case
2. Use `@test:config` to annotate the test function
3. Call the functions you are trying to test within the test function
4. Assert the results

Testing code is better explained with a demonstration. We shall use a real life example to write some basic test cases.

```ballerina
import ballerina/http;
import ballerina/log;

// Service endpoint
listener http:Listener airlineEP = new(9091);

// Available flight classes
final string ECONOMY = "Economy";
final string BUSINESS = "Business";
final string FIRST = "First";

// Airline reservation service to reserve airline tickets
@http:ServiceConfig {
    basePath:"/airline"
}
service airlineReservationService on airlineEP {

    // Resource to reserve a ticket
    @http:ResourceConfig {
        methods:["POST"], 
        path:"/reserve", 
        consumes:["application/json"],
        produces:["application/json"]
    }
    resource function reserveTicket(http:Caller caller, http:Request request) {
        http:Response response = new;
        json reqPayload = {};
        var payload = request.getJsonPayload();
        // Try parsing the JSON payload from the request
        if (payload is json) {
            // Valid JSON payload
            reqPayload = payload;
        } else {
            // NOT a valid JSON payload
            response.statusCode = 400;
            response.setJsonPayload({"Message":"Invalid payload - Not a valid JSON payload"});
            var result = caller->respond(response);
            handleError(result);
            return;
        }

        json|error name = reqPayload.Name;
        json|error arrivalDate = reqPayload.ArrivalDate;
        json|error departDate = reqPayload.DepartureDate;
        json|error preferredClass = reqPayload.Preference;

        // If payload parsing fails, send a "Bad Request" message as the response
        if (name is error || arrivalDate is error || departDate is error || preferredClass is error) {
            response.statusCode = 500;
            response.setJsonPayload({"Message":"Internal Server Error - Error while processing request parameters"});
            var result = caller->respond(response);
            handleError(result);
            return;
        }

        // Mock logic
        // If request is for an available flight class, send a reservation successful status
        string preferredClassStr = preferredClass.toString();
        if (equalIgnoreCase(preferredClassStr, ECONOMY) || equalIgnoreCase(preferredClassStr, BUSINESS)) {
            response.setJsonPayload({"Status":"Success"});
        }
        else {
            // If request is not for an available flight class, send a reservation failure status
            response.setJsonPayload({"Status":"Failed"});
        }

        // Send the response
        var result = caller->respond(response);
        handleError(result);
    }

}

function equalIgnoreCase(string string1, string string2) returns boolean {
    return (string1.toLowerAscii() == string2.toLowerAscii());
}

function handleError(error? result) {
    if (result is error) {
        log:printError(result.reason(), err = result);
    }
}

```

In the provided example code, the Unit tests can be written for both the defined functions as well as the service resource. The difference between testing normal functions and service resources is that we will be sending an http request directly to the service inorder to test the resource.

Let us write a test case for the normal function first.

```ballerina
function equalIgnoreCase(string string1, string string2) returns boolean {
    return (string1.toLowerAscii() == string2.toLowerAscii());
}
```

This is a fairly simple function to test. We simply have to call the function with different parameters and assert to see if the value returned is true or false.

```ballerina
@test:Config {
}
public function equalsIgnoreCaseTest() {

    string string1 = "Foo";
    string string2 = "foo";
    test:assertTrue(equalIgnoreCase(string1, string2));

    string string3 = "bar";
    test:assertFalse(equalIgnoreCase(string1, string3));
}
```

Let us write a test case for the service resource

```ballerina
// Airline reservation service to reserve airline tickets
@http:ServiceConfig {
    basePath:"/airline"
}
service airlineReservationService on airlineEP {

    // Resource to reserve a ticket
    @http:ResourceConfig {
        methods:["POST"], 
        path:"/reserve", 
        consumes:["application/json"],
        produces:["application/json"]
    }
    resource function reserveTicket(http:Caller caller, http:Request request) {
        http:Response response = new;
        json reqPayload = {};
        var payload = request.getJsonPayload();
        // Try parsing the JSON payload from the request
        if (payload is json) {
            // Valid JSON payload
            reqPayload = payload;
        } else {
            // NOT a valid JSON payload
            response.statusCode = 400;
            response.setJsonPayload({"Message":"Invalid payload - Not a valid JSON payload"});
            var result = caller->respond(response);
            handleError(result);
            return;
        }

        json|error name = reqPayload.Name;
        json|error arrivalDate = reqPayload.ArrivalDate;
        json|error departDate = reqPayload.DepartureDate;
        json|error preferredClass = reqPayload.Preference;

        // If payload parsing fails, send a "Bad Request" message as the response
        if (name is error || arrivalDate is error || departDate is error || preferredClass is error) {
            response.statusCode = 500;
            response.setJsonPayload({"Message":"Internal Server Error - Error while processing request parameters"});
            var result = caller->respond(response);
            handleError(result);
            return;
        }

        // Mock logic
        // If request is for an available flight class, send a reservation successful status
        string preferredClassStr = preferredClass.toString();
        if (equalIgnoreCase(preferredClassStr, ECONOMY) || equalIgnoreCase(preferredClassStr, BUSINESS)) {
            response.setJsonPayload({"Status":"Success"});
        }
        else {
            // If request is not for an available flight class, send a reservation failure status
            response.setJsonPayload({"Status":"Failed"});
        }

        // Send the response
        var result = caller->respond(response);
        handleError(result);
    }
```

To test the service, we will be creating an http client that sends requests directly to the service and gets a response. It is this response that we will be asserting.

Since this particular service returns a payload when the reservation is made, we can assert for that particular response message by calling the resource function. 

```
@test:Config {
}
public function reserveTicketTest() {

    // Define the test payload we will be sending to the service
    json payload = {
        "Name":"Alice",
        "ArrivalDate":"12-03-2018",
        "DepartureDate":"13-04-2018",
        "Preference":"Business"
    };

    // Define expected payload
    json expectedPayload = {
        "Status":"Success"
    };

    // Generate new request
    http:Request request = new;
    request.setJsonPayload(payload);

    // Send request to service
    http:Response|error response = clientEP->post("/reserve", request);

    if (response is http:Response) {
        test:assertEquals(response.getJsonPayload(), expectedPayload, "Assertion failed");
    } else {
        test:assertFail("Recieved error : "+ response.reason());
    }
}
```

Now that we have 2 test cases, we can run the tests and generate a code coverage report. This will give us an indication to what extent the code coverage of our tests are, and how we can proceed further.

### Generating a Code Coverage report

Ballerina comes with an option of generating a code coverage report when running test cases.

This can be done by using the `--code-coverage` option as follows

Build command :
`$ ballerina build --code-coverage <module_name>`

Test command :
`$ ballerina test --code-coverage <module_name>`

As you can see in the code coverage report, there are some lines that are not covered by our test cases. These are the sad tests that feature errors when things go wrong. We shall cover these test cases as well. 

### Writing negative? test cases

We can add the following test cases to cover the negative aspects as well.

```
@test:Config{
}
public function incompletePayloadTest() {
    
    // Define the test payload we will be sending to the service
    json payload = {
        "Name":"Alice",
        "DepartureDate":"13-04-2018",
        "Preference":"Business"
    };

    // Define expected payload
    json expectedPayload = {
        "Message":"Internal Server Error - Error while processing request parameters"
    };

    // Generate new request
    http:Request request = new;
    request.setJsonPayload(payload);

    // Send request to service
    http:Response|error response = clientEP->post("/reserve", request);

    if (response is http:Response) {
        test:assertEquals(response.getJsonPayload(), expectedPayload, "Assertion failed");
    } else {
        test:assertFail("Recieved error : "+ response.reason());
    }
}

@test:Config{
}
public function endpointErrorTest() {
    
    // Define the test payload we will be sending to the service
    json payload = {
        "Name":"Alice",
        "ArrivalDate":"12-03-2018",
        "DepartureDate":"13-04-2018",
        "Preference":"First"
    };

    // Define expected payload
    json expectedPayload = {
        "Status":"Failed"
    };

    // Generate new request
    http:Request request = new;
    request.setJsonPayload(payload);

    // Send request to service
    http:Response|error response = clientEP->post("/reserve", request);

    if (response is http:Response) {
        test:assertEquals(response.getJsonPayload(), expectedPayload, "Assertion failed");
    } else {
        test:assertFail("Recieved error : "+ response.reason());
    }
}

```

Now when we generate the code coverage report, all of the negative aspects of the Ballerina code are taken into consideration as well. 
