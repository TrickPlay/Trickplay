import grails.converters.*
import javax.servlet.http.HttpServletResponse;

/**
 * Abstract webservice controller with common methods.
 */
//abstract class WsController {
class WsController {

    //forward(action:"error", params:[http_status:123, error_string:""]);
    //forward(action:"error", params:[http_status:123, error_code:123, error_string:""]);
    def error = {
        def err = [:];
        def httpStatus = HttpServletResponse.SC_BAD_REQUEST;
        if (params.http_status != null) httpStatus = params.http_status.toInteger();
        if (params.error_code != null) err.put("code", params.error_code);
        if (params.error_string != null) err.put("message", params.error_string);
        def result = [ stat:"error", error:err ];
        response.status = httpStatus;
        render result as JSON;
    }

    def sendFile(address, response) {
        def file = new File(address);
        response.setContentType("application/octet-stream");
        response.setHeader("Content-disposition", "attachment;filename=${file.getName()}");
        response.outputStream << file.newInputStream(); // Performing a binary stream copy
    }
}
