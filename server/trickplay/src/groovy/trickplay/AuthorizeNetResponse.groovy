package trickplay;

import groovy.util.XmlSlurper;

/**
 */
class AuthorizeNetResponse {

    static AuthorizeNetResponse(stream) {
        def result = new XmlSlurper().parse(stream);
    }

}
