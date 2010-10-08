package trickplay;

import WsController;

class CategoryController extends WsController {
    def scaffold = true;

    def all = {
        def list = Category.list()
        if (list != null) {
            render(contentType:'application/json') {
                stat = "ok"
                categories = array {
                    for(c in list) {
                        category (id:c.id,
                                  name:c.name)
                    }
                }
            }
        } else {
            forward(action:"error", params:[http_status:404, error_string:"No categories found."]);
        }
    }

}
