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
</form>

</body>
</html>
