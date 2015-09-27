--local crypto = require "crypto"
--local json = require "json"

function check_proof()
    local alphero_username_cookie_value = ngx.var["cookie_alphero_username"]
    local alphero_proof_cookie_value = ngx.var["cookie_alphero_proof"]
    if alphero_username_cookie_value == null or alphero_proof_cookie_value == null or string.len(alphero_username_cookie_value)<1 or string.len(alphero_proof_cookie_value)<1 then
      --  ngx.say(alphero_proof_cookie_value)

        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end
    local expected_proof = calculate_proof(alphero_username_cookie_value)
    if expected_proof ~= alphero_proof_cookie_value then
        ngx.say(alphero_username_cookie_value)
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end
end

function attempt_login()
    local reqType = ngx.var.request_method
    ngx.header.content_type = 'text/html';
    if reqType == 'GET' then 
        ngx.say([[<html>
        <head>
          <title>Proxy Login</title> 
        </head>
        <body>
            <form method="post" action="alphero_login">
            <p><input type="text" name="username" value="" placeholder="Username or Email"></p>
            <p><input type="password" name="password" value="" placeholder="Password"></p>
            <p class="remember_me">
              <label>
                <input type="checkbox" name="remember_me" id="remember_me">
                Remember me on this computer
              </label>
            </p>
            <p class="submit"><input type="submit" name="commit" value="Login"></p>
            </form>
        </body>
    </html>]])
        return
    elseif reqType == 'POST' then
        res = ngx.location.capture("/read_instance")
    else 
        error("invalid operation: " .. reqType)
    end


    local data = ngx.req.read_body()
    local args = ngx.req.get_post_args()

    local password = ""
    local username = ""
    for key, val in pairs(args) do
        if key == "username" then
            username = val
        elseif key == "password" then
            password = val
        end
    end

    if string.len(username) <1 then
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

    if password ~= "test" then
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

    local appsecret_proof = calculate_proof(username)

    local expires = 3600 * 24  -- 1 day
    ngx.header['Set-Cookie'] = {"alphero_username=" .. username .. "; path=/; Expires=" .. ngx.cookie_time(ngx.time() + expires) ,
         "alphero_proof=" .. appsecret_proof .. "; path=/; Expires=" .. ngx.cookie_time(ngx.time() + expires)}
    ngx.exit(ngx.HTTP_OK)

end


function calculate_proof(username)
    local APPSECRETID = "T*QrEQ(FyGxmj%Izz(>d-=EbOahccv^N<iQ+q6Xdi^sE3mKAYt[W.KuV}O^]pw="
    local proof = ngx.hmac_sha1(APPSECRETID, username)        
    --local proof = crypto.hmac.digest("sha256", username, APPSECRETID, false)
    return ngx.encode_base64(proof)
end