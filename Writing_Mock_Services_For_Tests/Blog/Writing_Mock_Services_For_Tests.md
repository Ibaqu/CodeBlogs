# Writing Mock Services for Tests

When testing pieces of code that make use of external endpoints, it makes sense to mock these services when writing simple unit tests. By generating a client exclusive to the test suite, you can call your own mock service which will respond with specific responses that will help you test more extensively.

We will be using a Reservation service example to demonstrate how the service mocking can be done. The Reservation service makes use of 2 service endpoints that will need to be mocked. The following is an overview of the service :

![alt text](Writing_Mock_Services_For_Tests/Blog/service-composition.png)

## Making mockable porjects

In the interest of writing test cases for your project, it is advisable to think about mocking certain services before hand. This makes it easier when writing test cases that make use of your mock endpoints. 

For example, keeping the http client object as a global object allows us to easily override the URL of the original from within the test case.

## Writing a Mock service

### Project structure

While mock services can be defined anywhere within the project, it is advisable to create a specific Mock directory within the project inorder to maintain a certain degree of organization.

Consider the following project structure

```
TravelAgencyProject/
├── Ballerina.toml
└── src
    └── TravelAgencyModule
        ├── tests
        │   ├── MockServices
        │   │   └── mock_services.bal
        │   └── travel_agency_service_test.bal
        └── travel_agency_service.bal
```

### Implementing a Mock service

A Mock service aims to emulate, to a reasonable degree, the functionality of the actual service it is trying to mock. The key difference in this case is that, while the structure of the mock service generally remains the same, the way the mock interacts with different requests is up to the tester to decide.

In other words, the tester can tailor the mock service to respond to certain types of requests with the aim of emulating a range of possibilities. This allows the tester to extensively cover the external service and possibly improve apon the existing test suite as well as the project itself.

Creating a Mock service is simply a matter of creating a service that best emulates the original service, with a certain degree of abstraction.

### Running the Mock service

As long as an http Listener is defined, when building the project, the mock services will also start up, allowing you to run the test suite automatically. Please keep in mind that the port defined for the mock service must be an available port and must not conflict with any exsiting open ports on the system, else this may cause some errors.

However, keep in mind that the mock service will be closed once the module finishes building. The service will not remain open for other modules to take advantage of.

### Defining mock URLs in a Config file

It is also possible to define the mock URL in a separate test config file, which will take effect only when running test cases. This makes is so that you wont have to override the URL form the test suite, but rather, simply pass different config files during the build process. 

More on how to write test configurations using the Ballerina config API [here](). // Add link to other blog

## Key Takeaways

* Ideally, Mock services should go into a separate folder within the Test suite.
* The ports that the mock service uses must not clash with any existing open ports on the system.
* Users should keep in mind the compatability of their project in terms of mocking clients, preferably taking steps such as declaing global clients or creating suitable config files.
