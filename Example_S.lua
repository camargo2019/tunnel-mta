Server = {}

Server.GetInfo = function()
    local player = client; -- Player que chamou a função

    return "Servidor Ok"
end

_CMR.BindInterface("camargo", Server); --- Registrando a função pro client

Client = _CMR.GetInterface("camargo"); --- Pegando a interface do cliente

setTimer(function()
    local player = getPlayerFromName("JaxTeller"); --- Player que vai ser trigado
    Client.GetPlayerInfo(function(...) --- Chamando a função do cliente
        print("Resultado chamado client: ", ...)
    end, player);
end, 2000, 1)