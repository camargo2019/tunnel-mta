Client = {}

Client.GetPlayerInfo = function()
    return "CMR Dev"
end

_CMR.BindInterface("camargo", Client); --- Cadastrando as função cliente pro server chamar


Server = _CMR.GetInterface("camargo"); --- Pegando a interface do server
addEventHandler("onClientResourceStart", getResourceRootElement(), function()
    Server.GetInfo(function(...)
        print("Resultado: ", ...) --- Resultado do server
    end)
end)