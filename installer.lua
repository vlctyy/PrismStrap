local cloneref: () -> () = cloneref or function(...): (...any) -> (...any) return (...) end
local config: table = {
    path = '';
    setup = getgenv().autoexecute;
};
local httpservice = cloneref(game:GetService('HttpService'))
local getasync: () -> () = function(string: string): (string) -> (string)
    return game:HttpGet(string, true)
end
if isfolder('Bloxstrap') then delfolder('Bloxstrap') end
makefolder('Bloxstrap');
makefolder('Bloxstrap/Main');
makefolder('Bloxstrap/Main/Functions');
makefolder('Bloxstrap/Main/Configs');

local install: () -> () = function(config: {path: string, setup: boolean}): (table) -> ()
    config = config or {}
    for i: number, v: table in httpservice:JSONDecode(getasync('https://api.github.com/repos/qwertyui-is-back/Bloxstrap/contents/')) do
        if v.name:find('.lua') then
            writefile(`Bloxstrap/{v.name}`, `return loadstring(game:HttpGet('https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/refs/heads/main/{v.name}', true))()`);
        end;
    end;
    writefile(`Bloxstrap/Main/Bloxstrap.lua`, `return loadstring(game:HttpGet('https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/refs/heads/main/Main/Bloxstrap.lua', true))()`);
    for i: number, v: table in httpservice:JSONDecode(getasync('https://api.github.com/repos/qwertyui-is-back/Bloxstrap/contents/Main/Functions')) do
        writefile(`Bloxstrap/Main/Functions/{v.name}`, `return loadstring(game:HttpGet('https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/refs/heads/main/Main/Functions/{v.name}.lua`);
    end;
    if config.setup then
        return loadfile('Bloxstrap/Initiate.lua')();
    end;
end;

install(getgenv().autosetup or {})
print('successfully installed.')
