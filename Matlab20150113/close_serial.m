global COM_1;


if isobject(COM_1)
    if isvalid(COM_1)
        fclose(COM_1);
    end
    delete(COM_1);
end
clear COM_1;

all_hardware = instrfind;

if isobject(all_hardware)
    if isvalid(all_hardware)
        fclose(all_hardware);
    end
    delete(all_hardware);
end
clear all_hardware;
