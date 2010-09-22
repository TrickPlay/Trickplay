package trickplay

class MediaFileController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index = {
        redirect(action: "list", params: params)
    }

    def list = {
        params.max = Math.min(params.max ? params.int('max') : 10, 100)
        [mediaFileInstanceList: MediaFile.list(params), mediaFileInstanceTotal: MediaFile.count()]
    }

    def create = {
        def mediaFileInstance = new MediaFile()
        mediaFileInstance.properties = params
        return [mediaFileInstance: mediaFileInstance]
    }

    def save = {
        def mediaFileInstance = new MediaFile(params)
        if (mediaFileInstance.save(flush: true)) {
            flash.message = "${message(code: 'default.created.message', args: [message(code: 'mediaFile.label', default: 'MediaFile'), mediaFileInstance.id])}"
            redirect(action: "show", id: mediaFileInstance.id)
        }
        else {
            render(view: "create", model: [mediaFileInstance: mediaFileInstance])
        }
    }

    def show = {
        def mediaFileInstance = MediaFile.get(params.id)
        if (!mediaFileInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'mediaFile.label', default: 'MediaFile'), params.id])}"
            redirect(action: "list")
        }
        else {
            [mediaFileInstance: mediaFileInstance]
        }
    }

    def edit = {
        def mediaFileInstance = MediaFile.get(params.id)
        if (!mediaFileInstance) {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'mediaFile.label', default: 'MediaFile'), params.id])}"
            redirect(action: "list")
        }
        else {
            return [mediaFileInstance: mediaFileInstance]
        }
    }

    def update = {
        def mediaFileInstance = MediaFile.get(params.id)
        if (mediaFileInstance) {
            if (params.version) {
                def version = params.version.toLong()
                if (mediaFileInstance.version > version) {
                    
                    mediaFileInstance.errors.rejectValue("version", "default.optimistic.locking.failure", [message(code: 'mediaFile.label', default: 'MediaFile')] as Object[], "Another user has updated this MediaFile while you were editing")
                    render(view: "edit", model: [mediaFileInstance: mediaFileInstance])
                    return
                }
            }
            mediaFileInstance.properties = params
            if (!mediaFileInstance.hasErrors() && mediaFileInstance.save(flush: true)) {
                flash.message = "${message(code: 'default.updated.message', args: [message(code: 'mediaFile.label', default: 'MediaFile'), mediaFileInstance.id])}"
                redirect(action: "show", id: mediaFileInstance.id)
            }
            else {
                render(view: "edit", model: [mediaFileInstance: mediaFileInstance])
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'mediaFile.label', default: 'MediaFile'), params.id])}"
            redirect(action: "list")
        }
    }

    def delete = {
        def mediaFileInstance = MediaFile.get(params.id)
        if (mediaFileInstance) {
            try {
                mediaFileInstance.delete(flush: true)
                flash.message = "${message(code: 'default.deleted.message', args: [message(code: 'mediaFile.label', default: 'MediaFile'), params.id])}"
                redirect(action: "list")
            }
            catch (org.springframework.dao.DataIntegrityViolationException e) {
                flash.message = "${message(code: 'default.not.deleted.message', args: [message(code: 'mediaFile.label', default: 'MediaFile'), params.id])}"
                redirect(action: "show", id: params.id)
            }
        }
        else {
            flash.message = "${message(code: 'default.not.found.message', args: [message(code: 'mediaFile.label', default: 'MediaFile'), params.id])}"
            redirect(action: "list")
        }
    }
}
