local cloneref: () -> () = cloneref or function(...): (...any) -> (...any) return (...) end

local install: () -> () = function(config: {path: string, setup: boolean}): (table) -> ()

end;

install()
if bloxstrap then
    bloxstrap.createnotification('Sucessfully installed and executed the script.', 10);
end;
