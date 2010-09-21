package trickplay

class ApplicationFileController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index = {
        redirect(action: "list", params: params)
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [applicationFileInstanceList: ApplicationFile.list(params), applicationFileInstanceTotal: ApplicationFile.count()]
    }

    def create = {
        //def applicationFileInstance = new ApplicationFile()
        //applicationFileInstance.properties = params
        //return [applicationFileInstance: applicationFileInstance]

        log.debug "Uploaded application file with id=${params.ufileId}"
        [applicationFileInstance: ApplicationFile.get(params.ufileId)]
    }

    def save = {
        def applicationFileInstance = new ApplicationFile(params)
        if (applicationFileInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'applicationFile.label', default: 'ApplicationFile'), applicationFileInstance.id])}"
            redirect(action: "show", id: applicationFileInstance.id)
        }
        else {
            render(view: "create", model: [applicationFileInstance: applicationFileInstance])
        }
    }

    def show = {
        def applicationFileInstance = ApplicationFile.get(params.id)
        if (!applicationFileInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'applicationFile.label', default: 'ApplicationFile'), params.id])}"
            redirect(action: "list")
        }
        else {
            [applicationFileInstance: applicationFileInstance]
        }
    }

    def edit = {
        def applicationFileInstance = ApplicationFile.get(params.id)
        if (!applicationFileInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'applicationFile.label', default: 'ApplicationFile'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [applicationFileInstance: applicationFileInstance]
        }
    }

    def update = {
        def applicationFileInstance = ApplicationFile.get(params.id)
        if (applicationFileInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (applicationFileInstance.version > version) {
                    
                    applicationFileInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'applicationFile.label', default: 'ApplicationFile')] as Object[], "Another user has updated this ApplicationFile while you were editing")
                    render(view: "edit", model: [applicationFileInstance: applicationFileInstance])
                    return
                }
            }
            applicationFileInstance.properties = params
            if (!applicationFileInstance.hasErrors() && applicationFileInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'applicationFile.label', default: 'ApplicationFile'), applicationFileInstance.id])}"
                redirect(action: "show", id: applicationFileInstance.id)
            }
            else {
                render(view: "edit", model: [applicationFileInstance: applicationFileInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'applicationFile.label', default: 'ApplicationFile'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete = {
        def applicationFileInstance = ApplicationFile.get(params.id)
        if (applicationFileInstance) {
            try {
                applicationFileInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'applicationFile.label', default: 'ApplicationFile'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'applicationFile.label', default: 'ApplicationFile'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'applicationFile.label', default: 'ApplicationFile'), params.id])}"
            redirect(action: "list")
        }

//
        def ufile = ApplicationFile.get(params.id)
        ufile.delete()
        redirect action:index

    }
}
