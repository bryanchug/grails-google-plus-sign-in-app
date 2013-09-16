import grails.converters.JSON

import javax.servlet.http.HttpServletResponse

import org.codehaus.groovy.grails.plugins.springsecurity.SpringSecurityUtils

import org.springframework.security.authentication.AccountExpiredException
import org.springframework.security.authentication.CredentialsExpiredException
import org.springframework.security.authentication.DisabledException
import org.springframework.security.authentication.LockedException
import org.springframework.security.core.context.SecurityContextHolder as SCH
import org.springframework.security.web.WebAttributes
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter
import com.google.api.client.googleapis.auth.oauth2.GoogleTokenResponse
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeTokenRequest
import com.google.api.client.http.HttpTransport
import com.google.api.client.json.JsonFactory
import com.google.api.client.http.javanet.NetHttpTransport
import com.google.api.client.json.jackson2.JacksonFactory
import com.google.api.client.auth.oauth2.TokenResponseException
import com.google.api.client.googleapis.auth.oauth2.GoogleCredential
import com.google.api.services.oauth2.Oauth2
import com.google.api.services.oauth2.model.Tokeninfo
import app.User

class LoginController {

    private static final HttpTransport TRANSPORT = new NetHttpTransport()
    private static final JsonFactory JSON_FACTORY = new JacksonFactory()
    private static final String CLIENT_ID = '541774029905.apps.googleusercontent.com'
    private static final String CLIENT_SECRET = 'sw7w6MwWUYJoJT07FtIAOPJd'

	/**
	 * Dependency injection for the authenticationTrustResolver.
	 */
	def authenticationTrustResolver

	/**
	 * Dependency injection for the springSecurityService.
	 */
	def springSecurityService

	/**
	 * Default action; redirects to 'defaultTargetUrl' if logged in, /login/auth otherwise.
	 */
	def index = {
		if (springSecurityService.isLoggedIn()) {
			redirect uri: SpringSecurityUtils.securityConfig.successHandler.defaultTargetUrl
		}
		else {
			redirect action: 'auth', params: params
		}
	}

    /**
     * Reference:
     * https://developers.google.com/+/web/signin/server-side-flow#step_8_initialize_the_google_api_client_library_and_start_the_google_service
     */
    def plus = {

        String gPlusId = params.gPlusId
        String code = params.code
        String email = params.email

        // Upgrade the authorization code into an access and refresh token.
        GoogleTokenResponse tokenResponse =
            new GoogleAuthorizationCodeTokenRequest(TRANSPORT, JSON_FACTORY,
                    CLIENT_ID, CLIENT_SECRET, code, "postmessage").execute();

        // Create a credential representation of the token data.
        GoogleCredential credential = new GoogleCredential.Builder()
                .setJsonFactory(JSON_FACTORY)
                .setTransport(TRANSPORT)
                .setClientSecrets(CLIENT_ID, CLIENT_SECRET).build()
                .setFromTokenResponse(tokenResponse);

        // Check that the token is valid.
        Oauth2 oauth2 = new Oauth2.Builder(
                TRANSPORT, JSON_FACTORY, credential).build();
        Tokeninfo tokenInfo = oauth2.tokeninfo()
                .setAccessToken(credential.getAccessToken()).execute();

        // If there was an error in the token info, abort.
        if (tokenInfo.containsKey("error")) {
            response.sendError 401
            return
        }

        // Make sure the token we got is for the intended user.
        if (tokenInfo.getUserId() != gPlusId || tokenInfo.email != email) {
            response.sendError 401
            return
        }

        // Make sure the token we got is for our app.
        if (!tokenInfo.getIssuedTo().equals(CLIENT_ID)) {
            response.sendError 401
            return
        }

        User user = User.findByUsername(tokenInfo.email)

        if (!user) {
            user = new User(username: tokenInfo.email).save()
        }

        springSecurityService.reauthenticate(user.username)

        def jsonResponse = [
                status: 'success',
                redirectUri: SpringSecurityUtils.securityConfig.successHandler.defaultTargetUrl
        ]

        render(jsonResponse as JSON)

    }

	/**
	 * Show the login page.
	 */
	def auth = {

		def config = SpringSecurityUtils.securityConfig

		if (springSecurityService.isLoggedIn()) {
			redirect uri: config.successHandler.defaultTargetUrl
			return
		}

		String view = 'auth'
		String postUrl = "${request.contextPath}${config.apf.filterProcessesUrl}"
		render view: view, model: [postUrl: postUrl,
		                           rememberMeParameter: config.rememberMe.parameter]
	}

	/**
	 * The redirect action for Ajax requests.
	 */
	def authAjax = {
		response.setHeader 'Location', SpringSecurityUtils.securityConfig.auth.ajaxLoginFormUrl
		response.sendError HttpServletResponse.SC_UNAUTHORIZED
	}

	/**
	 * Show denied page.
	 */
	def denied = {
		if (springSecurityService.isLoggedIn() &&
				authenticationTrustResolver.isRememberMe(SCH.context?.authentication)) {
			// have cookie but the page is guarded with IS_AUTHENTICATED_FULLY
			redirect action: 'full', params: params
		}
	}

	/**
	 * Login page for users with a remember-me cookie but accessing a IS_AUTHENTICATED_FULLY page.
	 */
	def full = {
		def config = SpringSecurityUtils.securityConfig
		render view: 'auth', params: params,
			model: [hasCookie: authenticationTrustResolver.isRememberMe(SCH.context?.authentication),
			        postUrl: "${request.contextPath}${config.apf.filterProcessesUrl}"]
	}

	/**
	 * Callback after a failed login. Redirects to the auth page with a warning message.
	 */
	def authfail = {

		def username = session[UsernamePasswordAuthenticationFilter.SPRING_SECURITY_LAST_USERNAME_KEY]
		String msg = ''
		def exception = session[WebAttributes.AUTHENTICATION_EXCEPTION]
		if (exception) {
			if (exception instanceof AccountExpiredException) {
				msg = g.message(code: "springSecurity.errors.login.expired")
			}
			else if (exception instanceof CredentialsExpiredException) {
				msg = g.message(code: "springSecurity.errors.login.passwordExpired")
			}
			else if (exception instanceof DisabledException) {
				msg = g.message(code: "springSecurity.errors.login.disabled")
			}
			else if (exception instanceof LockedException) {
				msg = g.message(code: "springSecurity.errors.login.locked")
			}
			else {
				msg = g.message(code: "springSecurity.errors.login.fail")
			}
		}

		if (springSecurityService.isAjax(request)) {
			render([error: msg] as JSON)
		}
		else {
			flash.message = msg
			redirect action: 'auth', params: params
		}
	}

	/**
	 * The Ajax success redirect url.
	 */
	def ajaxSuccess = {
		render([success: true, username: springSecurityService.authentication.name] as JSON)
	}

	/**
	 * The Ajax denied redirect url.
	 */
	def ajaxDenied = {
		render([error: 'access denied'] as JSON)
	}
}
