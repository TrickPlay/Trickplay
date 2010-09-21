package trickplay;

import WsController;

class WishController extends WsController {
    def scaffold = true;

    def sessionKeyService;

    def add = {
        if (params.token == null ) {
            forward(action:"error", params:[http_status:400, error_string:"Token required."]);
        } else if (params.id == null) {
            forward(action:"error", params:[http_status:400, error_string:"Application ID required."]);
        } else {
            SessionKey sessionKey = SessionKey.findByToken(params.token);
            Application app = Application.get(params.id);
            if (sessionKey == null) {
                forward(action:"error", params:[http_status:401, error_string:"Unknown token."]);
            } else if (sessionKey.expired()) {
                forward(action:"error", params:[http_status:401, error_string:"Expired token."]);
            } else if (app == null) {
                forward(action:"error", params:[http_status:401, error_string:"Application ID ${params.id} not found."]);
            } else {
                Wish w = Wish.findByUserAndApplication(sessionKey.user, application);
                if (w != null) {
                    forward(action:"error", params:[http_status:403, error_string:"Duplicate."]);
                } else {
                    w = new Wish(user:sessionKey.user,
                                    application:app);
                    if (w.save(flush:true)) {
                        response.status = 201;
                        render(contentType:'application/json') {
                            stat = "ok"
                            wish = {
                                username = sessionKey.user.username
                                application = app.id
                                date = w.dateCreated
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
                Wish w = Wish.findByUserAndApplication(sessionKey.user, app);
                if (w != null) {
                    wish.delete(flush:true);
                    response.status = 200;
                    render(contentType:'application/json') {
                        stat = "ok"
                        wish = {
                            username = sessionKey.user.username
                            application = app.id
                            date = w.dateCreated
                        }
                    }
                } else {
                    //no review for that app
                    forward(action:"error", params:[http_status:400, error_string:"No wish for ${params.id} found."]);
                }
            }
        }
    }

}
