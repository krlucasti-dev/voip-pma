-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÃO
-----------------------------------------------------------------------------------------------------------------------------------------
src = {}
Tunnel.bindInterface("vrp_radio",src)
vCLIENT = Tunnel.getInterface("vrp_radio")
-----------------------------------------------------------------------------------------------------------------------------------------
-- ACTIVEFREQUENCY
-----------------------------------------------------------------------------------------------------------------------------------------
function src.activeFrequency(freq)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if parseInt(freq) >= 1 and parseInt(freq) <= 999 then
			if parseInt(freq) == 1 then
				if vRP.hasPermission(user_id,"staff.permissao") then
					vCLIENT.startFrequency(source,parseInt(1))
					TriggerClientEvent("Notify",source,"sucesso","Entrou na frequência <b>1</b> da <b>Staff</b>.",8000)
				else
					TriggerClientEvent("Notify",source,"aviso","Você não tem permissão para entrar nesta frequência.",8000)
				end
			elseif parseInt(freq) == 2 then
				if vRP.hasPermission(user_id,"dono.permissao") then
					vCLIENT.startFrequency(source,parseInt(2))
					TriggerClientEvent("Notify",source,"sucesso","Entrou na frequência <b>2</b> dos <b>Donos/Devs.</b>.",8000)
				else
					TriggerClientEvent("Notify",source,"aviso","Você não tem permissão para entrar nesta frequência.",8000)
				end
			elseif parseInt(freq) == 911 then
				if vRP.hasPermission(user_id,"policia.permissao") then
					vCLIENT.startFrequency(source,parseInt(911))
					TriggerClientEvent("Notify",source,"sucesso","Entrou na frequência <b>911</b> da <b>Policia</b>.",8000)
				else
					TriggerClientEvent("Notify",source,"aviso","Você não tem permissão para entrar nesta frequência.",8000)
				end
			elseif parseInt(freq) == 112 then
				if vRP.hasPermission(user_id,"medico.permissao") then
					vCLIENT.startFrequency(source,parseInt(112))
					TriggerClientEvent("Notify",source,"sucesso","Entrou na frequência <b>112</b> do <b>Hospital</b>.",8000)
				else
					TriggerClientEvent("Notify",source,"aviso","Você não tem permissão para entrar nesta frequência.",8000)
				end
			elseif parseInt(freq) == 115 then
				if vRP.hasPermission(user_id,"mcdonalds.permissao") then
					vCLIENT.startFrequency(source,parseInt(115))
					TriggerClientEvent("Notify",source,"sucesso","Entrou na frequência <b>115</b> do <b>McDonalds</b>.",8000)
				else
					TriggerClientEvent("Notify",source,"aviso","Você não tem permissão para entrar nesta frequência.",8000)
				end
			elseif parseInt(freq) == 700 then
				if vRP.hasPermission(user_id,"mecanico.permissao") then
					vCLIENT.startFrequency(source,parseInt(700))
					TriggerClientEvent("Notify",source,"sucesso","Entrou na frequência <b>700</b> da <b>LsCustoms</b>.",8000)
				else
					TriggerClientEvent("Notify",source,"aviso","Você não tem permissão para entrar nesta frequência.",8000)
				end
			elseif parseInt(freq) == 315 then
				if vRP.hasPermission(user_id,"Bennys.permissao") then
					vCLIENT.startFrequency(source,parseInt(315))
					TriggerClientEvent("Notify",source,"sucesso","Entrou na frequência <b>315</b> da <b>Redline Performance</b>.",8000)
				else
					TriggerClientEvent("Notify",source,"aviso","Você não tem permissão para entrar nesta frequência.",8000)
				end
			elseif parseInt(freq) == 915 then
				if vRP.hasPermission(user_id,"policia.permissao") then
					vCLIENT.startFrequency(source,parseInt(915))
					TriggerClientEvent("Notify",source,"sucesso","Entrou na frequência <b>915</b> da <b>Policia em ação</b>.",8000)
				else
					TriggerClientEvent("Notify",source,"aviso","Você não tem permissão para entrar nesta frequência.",8000)
				end
			else
				vCLIENT.startFrequency(source,parseInt(freq))
				TriggerClientEvent("Notify",source,"sucesso","Entrou na frequência <b>"..parseInt(freq).."</b>.",8000)
			end
		else
			TriggerClientEvent("Notify",source,"aviso","Frequência não encontrada.",8000)
		end
	end
end

function src.checkRadio()
	local source = source
	local user_id = vRP.getUserId(source)
	if vRP.getInventoryItemAmount(user_id,"radio") >= 1 then
		return true
	else
		TriggerClientEvent("Notify",source,"importante","Você precisa comprar um <b>Rádio</b> na <b>Loja de Departamento</b>.",8000)
		return false
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKRADIO
-----------------------------------------------------------------------------------------------------------------------------------------
function src.defaultRadio()
	local source = source
	local user_id = vRP.getUserId(source)
	if vRP.getInventoryItemAmount(user_id,"radio") == 0 then
		return true
	end
end
