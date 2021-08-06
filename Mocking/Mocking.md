# Using Function Mocking and Object Mocking

Mocking is a way of isolating the behaviour of certain functionality allowing us to run unit tests without worrying about dependencies.
It is primarily used in Unit testing code where it replaces dependent components with mocks that simulate similar behaviour.
This gives the freedom of mocking dependent functions and objects to behave in ways that broadens the scope of unit testing the particular code.
The Ballerina Test Framework offers Function Mocking and Object Mocking as means of unit testing.

## Function Mocking

Function Mocking in the Ballerina Test Framework replaces the function calls of the mocked function with a `MockFunction` object. This object can be used to perform several useful functions.

### Calling a Mock function

- The MockFunction object `call` functi0n allows us to call other functions of the same signature
- The behaviour of the function is upto the testers descretion as long as the parameter types and the return value remains the same.
- This can allow us to override the behaviour of the original function with some new behaviour

### Stubbing

- The MockFunction object `thenReturn` function allows us to return a particular value as long as the value matches the return value of the original function
- This happens without any function calls or attached behaviour. It simply provides a value
- Coupled with the `withArguments` function, specific values can be returned based on the arguments

### Calling the original function or do nothing

- In certain cases during testing, the `callOriginal` function may need to be used to call the orignal function
- The `doNothing` function

## Object Mocking

Object Mocking in the Ballerina Test Framework replaces the original object with a mock object that has a similar structure but behaves in a different way. Object Mocking can be used to call certain functions, or return certain values without relying on the original.

This can be particularly useful when dealing with external HTTP calls or queries to a database which can be difficult to unit test. Object Mocking essentially allows us to bypass these calls or queries by replacing the object with a mock object that can be defined in a certain way that simulates a real counterpart.

## Applying Mocking in a real-world example

The usefulness of mocking is better demonstrated with a real life example. Consider the case of an Airport Reservation System that allows the user to view airlines, reserve tickets, view reservations and cancel them if needed. In this case, the service interacts with an external service to get data on flights and relies on a database to store and retrieve reservation information. The following is a brief overview of the service functionality

![Screenshot](/Mocking/AirlineReservation1.png)

Each resource in this service either calls an external resource or relies on a database call which can be mocked during testing to return specific values.

Let us consider the case of the `reserveFlight` resource function which makes an external call to the `Airline` service.

```ballerina
// Airline Service client
http:Client airlineServiceEp = check new ("http://localhost:9091/airline");

// Send a get request for the flight details
        http:Response response = check airlineServiceEp->get("/getFlight/UL160");
```

The response that the service recieves is used to see if the flight is exists and if its available or not. The `reserveFlight` resource function is built to handle cases where the flight doesnt exist, or if the flight is not available. These cases can be covered by mocking the `airlineServiceEp->get()` function to return specific responses that cover these scenarios without having to have the `Airline` service actually running.

The following is the test case that demonstrates this functionality.

```ballerina
// Mock HTTP Client
// Make use of thenReturn and withArguments
```

Cases such as malformed data or invalid responses can also be simulated using the same mock object

```ballerina
// Mock HTTP Client
// Make use of stubbing
```

Object Mocking is not reserved to only HTTP Clients. After making a successful reservation, a JDBC query is sent to the database to update relevant reservation information. This can also be mocked to skip the database calls entirely.

```ballerina
// Mock JDBC client
// Cover mysql functions
```

Cases where certain functionality needs to be skipped can be handled by using `doNothing` appropriately. This can be used to simulate invalid responses or cases where something has failed to see how the service behaves.
