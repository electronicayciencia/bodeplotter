% Simulation of BCM2835 Fractionary Divider on Raspberry Pi
% electronicayciencia  20170325

% Main loop. Call from fracdiv_common.
% Simplified version.

icounter = 0;
fcounter = 0;
last_v   = 0;
vout     = 0;

for i = 1:length(w);
    v = w(i);
    
    if (v == 1) && (v ~= last_v) % raising edge
        fcounter = fcounter + 1;
        
        if (fcounter == fcounter_max)
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
