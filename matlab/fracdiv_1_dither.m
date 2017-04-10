% Simulation of BCM2835 Fractionary Divider on Raspberry Pi
% electronicayciencia  20170325

% Main loop. Call from fracdiv_common.
% Simplified version: uniform dithering

icounter = 0;
fcounter = 0;
last_v   = 0;
vout     = 0;

f = floor(fcounter_max);

for i = 1:length(w);
    v = w(i);
    
    if (v == 1) && (v ~= last_v) % raising edge
        fcounter = fcounter + 1;

        if (fcounter == f)
            f = floor(fcounter_max + rand);
            fcounter = 0;
        else
            icounter = icounter + 1;
        end
        
    end

    if (icounter >= icounter_max)
        vout = 1 - vout; % toogle output
        icounter = 0;
    end
    
    out(i) = vout;
    last_v = v;
end

