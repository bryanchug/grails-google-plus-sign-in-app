import app.User

class BootStrap {

    def init = { servletContext ->

        if( !User.findByUsername('bryan.chug@gmail.com') ){
            new User(username: 'bryan.chug@gmail.com', password: 'password', favoriteColor: 'Blue').save()
        }

    }
    def destroy = {
    }
}
