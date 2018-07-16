% Compute crcsum for file

% Copyright 2010-2012 Techila Technologies Ltd.

function crcsum=crcsum(file)
    crc = java.util.zip.CRC32;
    fid = fopen(file);
    if fid < 0
        fprintf('Unable to open file %s\n', file);
        error('Unable to open file %s\n', file);
    end
    count = 0;
    bytes = [];
    try 
        [bytes, count] = fread(fid, 100000, 'uchar');
    catch ME
        fprintf('Error in getting crcsum of %s\n', file);
        rethrow(ME)
    end
    while (count > 0)
        crc.update(bytes);
        [bytes, count] = fread(fid, 100000, 'uchar');
    end
    fclose(fid);
%    crcsum = num2str(crc.getValue);
    crcsum = crc.getValue;
end
