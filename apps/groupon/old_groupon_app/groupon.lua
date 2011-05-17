--[[

    This is an API to access the Groupon REST web services API

]]--

local API_KEY = '3851eef5ffb17de1f634e013b9b0791968041207'
local REGISTERED_TO = 'craig+groupon@rungie.com'

local get_status = function (self)
    return json:parse(URLRequest(self.BASE_URL..'status?client_id='..API_KEY):perform().body)
end

local get_divisions = function (self)
    return json:parse(URLRequest(self.API_VERSION_URL_PREFIX..'divisions?show=name&client_id='..API_KEY):perform().body)
end

local get_deals = function (self)
    local request = self.API_VERSION_URL_PREFIX..'deals?client_id='..API_KEY
    return json:parse(URLRequest(request):perform().body)
end

local GROUPON =
{
    BASE_URL = 'https://api.groupon.com/',
    API_VERSION_URL_PREFIX = 'https://api.groupon.com/v2/',
    get_status = get_status,
    get_divisions = get_divisions,
    get_deals = get_deals
}

return GROUPON
