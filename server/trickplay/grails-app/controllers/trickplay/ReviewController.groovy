package trickplay;

import WsController;

class ReviewController extends WsController {
    def scaffold = true;

    def sessionKeyService;

    def add = {
        if (params.token == null ) {
            forward(action:"error", params:[http_status:400, error_string:"Token required."]);
        } else if (params.id == null || params.stars == null) {
            forward(action:"error", params:[http_status:400, error_string:"Application ID and # stars are required."]);
        } else {
            SessionKey sessionKey = sessionKeyService.getSessionKey(params.token);
            Application app = Application.get(params.id);
            if (sessionKey == null) {
                forward(action:"error", params:[http_status:401, error_string:"Unknown token."]);
            } else if (sessionKey.expired()) {
                forward(action:"error", params:[http_status:401, error_string:"Expired token."]);
            } else if (app == null) {
                forward(action:"error", params:[http_status:401, error_string:"Application ID ${params.id} not found."]);
            } else {
                Review r = Review.findByUserAndApplication(sessionKey.user, app);
                if (r != null) {
                    forward(action:"error", params:[http_status:403, error_string:"Duplicate."]);
                } else {
                    r = new Review(user:sessionKey.user,
                                   application:app,
                                   stars:params.stars,
                                   comment:params.comment);
                    if (r.save(flush:true)) {
                        response.status = 201;
                        render(contentType:'application/json') {
                            stat = "ok"
                            review = {
                                username = sessionKey.user.username
                                application = app.id
                                stars = params.stars
                                comment = params.comment
                                date = r.dateCreated
                            }
                        }
                    } else {
                        forward(action:"error", params:[http_status:403, error_string:"Duplicate."]);
                    }
                }
            }
        }
    }

    def remove = {
        if (params.token == null ) {
            forward(action:"error", params:[http_status:400, error_string:"Token required."]);
        } else if (params.id == null) {
            forward(action:"error", params:[http_status:400, error_string:"Application ID required."]);
        } else {
            SessionKey sessionKey = sessionKeyService.getSessionKey(params.token);
            Application app = Application.get(params.id);
            if (sessionKey == null) {
                forward(action:"error", params:[http_status:401, error_string:"Unknown token."]);
            } else if (sessionKey.expired()) {
                forward(action:"error", params:[http_status:401, error_string:"Expired token."]);
            } else if (app == null) {
                forward(action:"error", params:[http_status:401, error_string:"Application ID ${params.id} not found."]);
            } else {
                Review r = Review.findByUserAndApplication(sessionKey.user, app);
                if (r != null) {
                    r.delete(flush:true);
                    response.status = 200;
                    render(contentType:'application/json') {
                        stat = "ok"
                        review (username:sessionKey.user.username,
                                application:app.id,
                                stars:r.stars,
                                comment:r.comment,
                                date:r.dateCreated);
                    }
                } else {
                    //no review for that app
                    forward(action:"error", params:[http_status:400, error_string:"No review for ${params.id} found."]);
                }
            }
        }
    }
}
