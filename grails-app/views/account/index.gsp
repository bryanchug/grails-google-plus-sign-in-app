<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">
    <meta name="layout" content="main">

    <title>Welcome</title>

    <!-- Bootstrap core CSS -->
    <g:external uri="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css"/>
    <style>
    body {
        padding-top: 50px;
    }
    .section {
        padding: 40px 15px;
        text-align: center;
    }
    </style>
</head>

<body>

<div class="navbar navbar-inverse navbar-fixed-top">
    <div class="container">
        <div class="navbar-header">
            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="#">App</a>
        </div>
        <div class="collapse navbar-collapse">
            <ul class="nav navbar-nav">
                <li class="active"><a href="#">Home</a></li>
            </ul>
        </div><!--/.nav-collapse -->
    </div>
</div>

<div class="container">

    <div class="section">
        <h1>Welcome, ${user} <g:link class="btn btn-warning" uri="/logout">Log out</g:link></h1>
    </div>

    <div class="row">
        <div class="col-md-6">
            <div class="well">
                <h4>App User Profile</h4>
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>
                                Description
                            </th>
                            <th>
                                Value
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Username</td>
                            <td>${user.username}</td>
                        </tr>
                        <tr>
                            <td>Favorite Color</td>
                            <td>${user.favoriteColor ?: ''}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <div class="col-md-6">
            <div class="well">
                <h4>Google+ User Profile</h4>
                <table id="gplus-profile" class="table table-striped">
                    <thead>
                    <tr>
                        <th>
                            Description
                        </th>
                        <th>
                            Value
                        </th>
                    </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        //hack to prevent toast message from reappearing
        window.___gcfg = { isSignedOut: true };

        function signinCallback(authResult){

            gapi.client.load('oauth2', 'v2', function() {
                var request = gapi.client.oauth2.userinfo.get();
                request.execute(function(obj){
                    console.log(obj);

                    if( obj.email != "${user.username}" ){
                        location.href = '/logout';
                        return;
                    }

                    if (obj.email) {
                        $('#gplus-profile tbody').append("<tr><td>Email</td><td>" + obj.email + "</td>");
                    }

                    gapi.client.load('plus', 'v1', function(){
                        var request = gapi.client.plus.people.get({
                            'userId': 'me'
                        });
                        request.execute(function(resp) {
                            console.log(resp);
                            var tbody = $('#gplus-profile tbody');
                            if(resp.name){
                                if( resp.name.givenName ){
                                    tbody.append("<tr><td>Given Name</td><td>"+resp.name.givenName+"</td>");
                                }
                                if( resp.name.familyName ){
                                    tbody.append("<tr><td>Family Name</td><td>"+resp.name.familyName+"</td>");
                                }
                            }
                            if(resp.image && resp.image.url){
                                tbody.append("<tr><td>Photo</td><td><img src='"+resp.image.url+"'/></td>");
                            }
                            if(resp.url){
                                tbody.append("<tr><td>Google+ Profile</td><td><a href='"+resp.url+"'>"+resp.url+"</a></td>");
                            }
                            if(resp.result && resp.result.gender){
                                tbody.append("<tr><td>Gender</td><td>"+resp.result.gender+"</td>");
                            }
                        });
                    });
                });
            });

        }
    </script>

</div><!-- /.container -->

</body>
</html>
