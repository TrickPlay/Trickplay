import trickplay.User
import trickplay.Role
import trickplay.UserRole
import trickplay.Device
import trickplay.SessionKey
import trickplay.SessionKeyService

/**
 * User controller.
 */
class UserController extends WsController {

    def authenticateService;
    def sessionKeyService;

    static final String[] END_USER_ROLES = [ "ROLE_USER" ];
    static final String[] ADMIN_USER_ROLES = [ "ROLE_USER", "ROLE_ADMIN" ];
    static final String[] DEVELOPER_USER_ROLES = [ "ROLE_USER", "ROLE_DEVELOPER" ];

    def authorize = {
        if (params.key == null || params.username == null || params.password == null) {
            forward(action:"error", params:[http_status:400, error_string: "Parameters username, password, and device key are required."]);
        } else {
            def userDetails = sessionKeyService.authenticate(params.username, params.password);
            log.info "Generating token for: ${userDetails}";
            Device dev = Device.findByDeviceKey(params.key);
            if (userDetails != null && dev != null) {

                // TODO: Validate the user is in fact the owner of the Device?

                User user = sessionKeyService.getUser(userDetails);
                SessionKey sessionKey = sessionKeyService.newToken(user, dev);
                response.status = 200;
                render(contentType:'application/json') {
                    stat = "ok"
                    auth = {
                        username = user.username
                        device = dev.deviceKey
                        token = sessionKey.token
                    }
                }
            } else {
                forward(action:"error", params:[http_status:401, error_string:"Unable to authenticate ${params.username}."]);
            }
        }
    }
    
    def add = {
        if (params.username == null || params.email == null || params.password == null) {
            forward(action:"error", params:[http_status:400, error_string: "Parameters username, email, and password are required."]);
        } else {
            def u = new User(username:params.username,
                             userRealName:params.realname,
                             email:params.email,
                             passwd:authenticateService.encodePassword(params.password),
                             enabled:true);
            if (u.save(flush:true)) {
                //def urs = addDefaultRoles(u, END_USER_ROLES);
                def urs = []
                addDefaultRoles(u, DEVELOPER_USER_ROLES).each {
                    urs.add(it.role.authority)
                }
                response.status = 201;
                render(contentType:'application/json') {
                    stat = "ok"
                    user = {
                        username = u.username
                        realname = u.userRealName
                        email = u.email 
                        roles = urs
                    }
		}
            } else {
                if (u.hasErrors()){
                    println u.errors
                }
                forward(action:"error", params:[http_status:401, error_string:"Duplicate user."]);
            }
        }
    }
    
    def full = {
        if (params.token == null) {
            forward(action:"error", params:[http_status:400, error_string:"Token required."]);
        } else {
            SessionKey sessionKey = SessionKey.findByToken(params.token);
            if (sessionKey == null) {
                forward(action:"error", params:[http_status:401, error_string:"Unknown token."]);
            } else if (sessionKey.expired()) {
                forward(action:"error", params:[http_status:401, error_string:"Expired token."]);
            } else {
                def u = sessionKey.user;
                def rs = [];
                u.authorities.each {
                    rs.add(it.authority);
                }
                render(contentType:'application/json') {
                    stat = "ok"
                    user = {
                        username = u.username
                        realname = u.userRealName
                        email = u.email
                        roles = rs
                    }                
                }
            }
        }
    }

    def payment = {
        if (params.token == null) {
            forward(action:"error", params:[http_status:400, error_string:"Token required."]);
        } else {
            SessionKey sessionKey = SessionKey.findByToken(params.token);
            if (sessionKey == null) {
                forward(action:"error", params:[http_status:401, error_string:"Unknown token."]);
            } else if (sessionKey.expired()) {
                forward(action:"error", params:[http_status:401, error_string:"Expired token."]);
            } else {
                def pps = sessionKey.user.paymentProfiles;
                render(contentType:'application/json') {
                    stat = "ok"
                    profiles = array {
                        for(pp in pps) {
                            profile (id:pp.id,
                                     name:pp.canonicalName,
                                     description:pp.canonicalIdentifier);
                        }
                    }
                }
            }
        }
    }

    def reviews = {
        if (params.token == null) {
            forward(action:"error", params:[http_status:400, error_string:"Token required."]);
        } else {
            SessionKey sessionKey = SessionKey.findByToken(params.token);
            if (sessionKey == null) {
                forward(action:"error", params:[http_status:401, error_string:"Unknown token."]);
            } else if (sessionKey.expired()) {
                forward(action:"error", params:[http_status:401, error_string:"Expired token."]);
            } else {
                def rs = sessionKey.user.reviews;
                render(contentType:'application/json') {
                    stat = "ok"
                    delegate.reviews = array {
                        for(r in rs) {
                            review (application:r.application.id,
                                    stars:r.stars,
                                    comment:r.comment,
                                    date:r.dateCreated);
                        }
                    }
                }
            }
        }
    }

    def wishlist = {
        if (params.token == null) {
            forward(action:"error", params:[http_status:400, error_string:"Token required."]);
        } else {
            SessionKey sessionKey = SessionKey.findByToken(params.token);
            if (sessionKey == null) {
                forward(action:"error", params:[http_status:401, error_string:"Unknown token."]);
            } else if (sessionKey.expired()) {
                forward(action:"error", params:[http_status:401, error_string:"Expired token."]);
            } else {
                def ws = sessionKey.user.wishes;
                render(contentType:'application/json') {
                    stat = "ok"
                    wishes = array {
                        for(w in ws) {
                            wish (application:w.application.id,
                                  date:w.dateCreated);
                        }
                    }
                }
            }
        }
    }

    private List addDefaultRoles(person, roles) {
        def userRoles = [];
        for (String role in roles) {
            userRoles.add(UserRole.create(person, Role.findByAuthority(role), true));
        }
        return userRoles;
    }


/* Generated code below */

	// the delete, save and update actions only accept POST requests
	static Map allowedMethods = [delete: 'POST', save: 'POST', update: 'POST']

	def index = {
		redirect action: list, params: params
	}

	def list = {
		if (!params.max) {
			params.max = 10
		}
		[personList: User.list(params)]
	}

	def show = {
		def person = User.get(params.id)
		if (!person) {
			flash.message = "User not found with id $params.id"
			redirect action: list
			return
		}
		List roleNames = []
		for (role in person.authorities) {
			roleNames << role.authority
		}
		roleNames.sort { n1, n2 ->
			n1 <=> n2
		}
		[person: person, roleNames: roleNames]
	}

	/**
	 * Person delete action. Before removing an existing person,
	 * he should be removed from those authorities which he is involved.
	 */
	def delete = {

		def person = User.get(params.id)
		if (person) {
			def authPrincipal = authenticateService.principal()
			//avoid self-delete if the logged-in user is an admin
			if (!(authPrincipal instanceof String) && authPrincipal.username == person.username) {
				flash.message = "You can not delete yourself, please login as another admin and try again"
			}
			else {
				//first, delete this person from People_Authorities table.
				//Role.findAll().each { it.removeFromPeople(person) }
                            UserRole.removeAll(person)
				person.delete()
				flash.message = "User $params.id deleted."
			}
		}
		else {
			flash.message = "User not found with id $params.id"
		}

		redirect action: list
	}

	def edit = {

		def person = User.get(params.id)
		if (!person) {
			flash.message = "User not found with id $params.id"
			redirect action: list
			return
		}

		return buildPersonModel(person)
	}

	/**
	 * Person update action.
	 */
	def update = {

		def person = User.get(params.id)
		if (!person) {
			flash.message = "User not found with id $params.id"
			redirect action: edit, id: params.id
			return
		}

		long version = params.version.toLong()
		if (person.version > version) {
			person.errors.rejectValue 'version', "person.optimistic.locking.failure",
				"Another user has updated this User while you were editing."
				render view: 'edit', model: buildPersonModel(person)
			return
		}

		def oldPassword = person.passwd
		person.properties = params
		if (!params.passwd.equals(oldPassword)) {
			person.passwd = authenticateService.encodePassword(params.passwd)
		}
		if (person.save()) {
			//Role.findAll().each { it.removeFromPeople(person) }
                    UserRole.removeAll(person)
			addRoles(person)
			redirect action: show, id: person.id
		}
		else {
			render view: 'edit', model: buildPersonModel(person)
		}
	}

	def create = {
		[person: new User(params), authorityList: Role.list()]
	}

	/**
	 * Person save action.
	 */
	def save = {

		def person = new User()
		person.properties = params
		person.passwd = authenticateService.encodePassword(params.passwd)
		if (person.save()) {
			addRoles(person)
			redirect action: show, id: person.id
		}
		else {
			render view: 'create', model: [authorityList: Role.list(), person: person]
		}
	}

	private void addRoles(person) {
		for (String key in params.keySet()) {
			if (key.contains('ROLE') && 'on' == params.get(key)) {
				//Role.findByAuthority(key).addToPeople(person)
                        UserRole.create(person, Role.findByAuthority(key))
			}
		}
	}

	private Map buildPersonModel(person) {

		List roles = Role.list()
		roles.sort { r1, r2 ->
			r1.authority <=> r2.authority
		}
		Set userRoleNames = []
		for (role in person.authorities) {
			userRoleNames << role.authority
		}
		LinkedHashMap<Role, Boolean> roleMap = [:]
		for (role in roles) {
			roleMap[(role)] = userRoleNames.contains(role.authority)
		}

		return [person: person, roleMap: roleMap]
	}
}
