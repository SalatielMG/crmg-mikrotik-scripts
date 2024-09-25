:local url [/tool fetch url="http://127.0.0.1:8080" as-value output=user]
:local body [:pick $url 0 [:len $url]]
:log warning "Body request recibido: $body";
# :log info "Body request recibido: $body"
#:if ([:find $body "status=down"] != 0) do={
#   /system script run notifyAction
#}


:local url [/tool fetch url="http://127.0.0.1:8080" as-value output=user];
:if ([:find $url "notify"] != 0) do={
    :log warning "Notify Http Received";
    # /system script run notifyAction
}