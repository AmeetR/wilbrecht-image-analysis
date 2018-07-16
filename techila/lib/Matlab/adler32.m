% Compute ADLER-32 checksum

% Copyright 2010-2012 Techila Technologies Ltd.

function output=adler32(input)
ADLER_MOD=65521;
a=1;
b=0;
for i=1:length(input)
    a = mod((a + double(input(i))), ADLER_MOD);
    b = mod((b + a), ADLER_MOD);
end
output = bitshift(b,16) + a;
end
