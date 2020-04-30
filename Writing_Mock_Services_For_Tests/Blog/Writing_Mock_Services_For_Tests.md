# Writing Mock Services for Tests

When testing pieces of code that make use of external endpoints, it makes sense to mock these services when writing simple unit tests. By generating a client exclusive to the test suite, you can call your own mock service which will respond with specific responses that will help you test more extensively.

We will be using a Reservation service example to demonstrate how the service mocking can be done. The Reservation service makes use of 2 service endpoints that will need to be mocked. The following is an overview of the service :

![alt text](Writing_Mock_Services_For_Tests/Blog/service-composition.png)

