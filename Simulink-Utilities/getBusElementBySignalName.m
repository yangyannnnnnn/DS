function out = getBusElementBySignalName(Dataset,signalName)
    arguments
        Dataset (1,1) Simulink.SimulationData.Dataset
        signalName (1,1) string
    end
    if contains(signalName,'.') % Struct
        fname = extractAfter(signalName,'.');
        signalName = extractBefore(signalName,'.');
    end
    busNames = getElementNames(Dataset);
    for i = 1:length(busNames)
        if isfield(Dataset{i}.Values,signalName)
            out = Dataset{i}.Values.(signalName);
            if isa(out,'struct')
                out = out.(fname);
            end
            return;
        end
    end
    error("Error in getBusElementBySignalName: Signal '" + signalName + "' not found in dataset");
end

