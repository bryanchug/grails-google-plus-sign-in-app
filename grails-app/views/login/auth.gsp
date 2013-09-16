<html>
<head>
	<meta name='layout' content='main'/>
	<title>Login</title>
    <style>
    body {
        padding-top: 40px;
        padding-bottom: 40px;
        background-color: #eee;
    }

    .form-signin {
        max-width: 330px;
        padding: 15px;
        margin: 0 auto;
    }
    .form-signin .form-signin-heading,
    .form-signin .checkbox {
        margin-bottom: 10px;
    }
    .form-signin .checkbox {
        font-weight: normal;
    }
    .form-signin .form-control {
        position: relative;
        font-size: 16px;
        height: auto;
        padding: 10px;
        -webkit-box-sizing: border-box;
        -moz-box-sizing: border-box;
        box-sizing: border-box;
    }
    .form-signin .form-control:focus {
        z-index: 2;
    }
    .form-signin input[type="text"] {
        margin-bottom: -1px;
        border-bottom-left-radius: 0;
        border-bottom-right-radius: 0;
    }
    .form-signin input[type="password"] {
        margin-bottom: 10px;
        border-top-left-radius: 0;
        border-top-right-radius: 0;
    }
    #signinButton{
        margin-top: 10px;
    }
    </style>
</head>

<body>

<form action='${postUrl}' method='POST' id='loginForm' class='form-signin' autocomplete='off'>
    <g:if test='${flash.message}'>
        <div class='alert'>${flash.message}</div>
    </g:if>

    <h2 class="form-signin-heading">Please sign in</h2>

    <input type="text" class="form-control" placeholder="Email address" name="j_username" autofocus>
    <input type="password" class="form-control" placeholder="Password" name="j_password">

    <label class="checkbox">
        <input type='checkbox' value="remember-me" name='${rememberMeParameter}' <g:if test='${hasCookie}'>checked='checked'</g:if>/>
        <label for='remember_me'><g:message code="springSecurity.login.remember.me.label"/></label>
    </label>

    <button class="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>

    <div id="signinButton">
        <span
                class="g-signin"
                data-callback="signinCallback"
                data-clientid="541774029905.apps.googleusercontent.com"
                data-cookiepolicy="single_host_origin"
                data-requestvisibleactions="http://schemas.google.com/AddActivity"
                data-scope="https://www.googleapis.com/auth/plus.login https://www.googleapis.com/auth/userinfo.email">
        </span>
    </div>
</form>

<script>
    function signinCallback(authResult) {
        if (authResult['access_token']) {

            console.log( authResult );

            // Successfully authorized
            // Hide the sign-in button now that the user is authorized, for example:
            document.getElementById('signinButton').setAttribute('style', 'display: none');

            gapi.client.load('plus', 'v1', function(){
                var request = gapi.client.plus.people.get({
                    'userId': 'me'
                });
                request.execute(function(resp) {
                    console.log(resp);
                });
            });

            gapi.client.load('oauth2', 'v2', function() {
                var request = gapi.client.oauth2.userinfo.get();
                request.execute(function(obj){
                    console.log(obj);
                });
            });

        } else if (authResult['error']) {
            // There was an error.
            // Possible error codes:
            //   "access_denied" - User denied access to your app
            //   "immediate_failed" - Could not automatically log in the user
            // console.log('There was an error: ' + authResult['error']);
        }
    }
</script>

</body>
</html>
