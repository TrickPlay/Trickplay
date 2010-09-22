package trickplay;

import WsController;

class DeviceController extends WsController {
    def scaffold = true;

    def provision = {
        if (params.key == null || params.type == null) {
            forward(action:"error", params:[http_status:400, error_string:"Parameters key and type are required."]);
        } else {
            User owner = null;
            if (params.username) {
                owner = User.findByUsername(params.username);
            }
            if (params.username && owner == null) {
                forward(action:"error", params:[http_status:403, error_string:"Unknown user ${params.username}."]);
            } else {
                Device d = Device.findByDeviceKey(params.key);
                if (d != null) {
                    d.deviceKey = params.key;
                    d.deviceType = params.type;
                    d.owner = owner;
                    d.provisioned = true;
                } else {
                    d = new Device(deviceKey:params.key, deviceType:params.type, owner:owner, provisioned:true);
                }
                if (d.save(flush:true)) {
                    response.status = 201;
                    render(contentType:'application/json') {
                        stat = "ok";
                        device = {
                            key = d.deviceKey
                            type = d.deviceType
                            username = params.username
                            provisioned = d.provisioned
                        }
                    }
                } else {
                    forward(action:"error", params:[http_status:500, error_string:"Problem provisioning device."]);
                }
            }
        }
    }
}
