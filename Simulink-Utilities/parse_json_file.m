function [json_data] = parse_json_file(json_filename)

try
    if nargin<1
        [filename, pathname]=uigetfile('*.json','Select JSON File');
        fid=fopen([pathname filename]);
    else
        fid=fopen(json_filename);
    end
    line=fgetl(fid);
    string='';
    
    while line~=-1
        string = [string strtrim(line)];
        line=fgetl(fid);
    end
    [~]=fclose(fid);
    
    [raw_json_data, ~] = parse_json(string);
    json_data=raw_json_data{1};
    
    clear ans string line fid status
catch
    
end
