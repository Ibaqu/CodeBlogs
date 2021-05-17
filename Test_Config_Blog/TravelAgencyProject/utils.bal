import ballerina/log;

function handleError(error? result) {
    if (result is error) {
        log:printError(result.message());
    }
}

