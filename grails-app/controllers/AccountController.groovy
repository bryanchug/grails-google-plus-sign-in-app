import app.*
import grails.plugins.springsecurity.SpringSecurityService

class AccountController {

    SpringSecurityService springSecurityService

    def index = {
        [user: springSecurityService.currentUser]
    }

}
