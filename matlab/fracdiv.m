% Simulation of BCM2835 Fractionary Divider on Raspberry Pi
% electronicayciencia  20170325
% 

%-------------------------------------
% Main options
Fc    = 500;     % clock frequency
Tfreq = 27.155;  % Target frequency
Order = 0;       % Fractional order

DIV  = Fc / Tfreq;

%-------------------------------------
% Main loop
n  = 2000000;  % number of points
SR = 20*Fc;    % sampling rate
T  = n/SR;     % sampling time (s)

t = 0:1/SR:T-1/SR; % time vector

% dividing by 1 result in toogling output every period
% so we get half the original frequency
% double the frequency so we get Fc pulses per second after divide by 1
w = square(2*pi*2*Fc*t);

if (Order > 0)
    icounter_max = floor(DIV);
else
    icounter_max = round(DIV);
end

% remainder of fractional divider
rem = mod(Fc,Fc/DIV);

fcounter_max = Order * (Fc-rem)/rem;
fcounter_max = round(fcounter_max);
fprintf ('Swallow %d every %d source pulses\n', Order, fcounter_max);

out = zeros(1,n);

mcounter = 0;
icounter = 0;
fcounter = 0;
last_v   = 0;
vout     = 0;

for i = 1:length(w);
    v = w(i);
    
    if (v == 1) && (v ~= last_v) % raising edge
        if (Order > 0) && (fcounter >= fcounter_max)
            mcounter = mcounter + 1;
            if (mcounter >= Order)
                mcounter = 0;
                fcounter = 0;
            end
        else
            icounter = icounter + 1;
            fcounter = fcounter + 1;
        end
    end

    if (icounter >= icounter_max)
        vout = 1 - vout; % toogle output
        icounter = 0;
    end
    
    out(i) = vout;
    last_v = v;
end


%-------------------------------------
% Output
ft = linspace(SR/2/n,SR/2,n/2-1);
ff = abs(fft(out)) / (n/2);
ff = 20*log(ff);
ff = ff(2:n/2);

[val,pos] = max(ff);
peakfreq = ft(pos);

meanfreq = sum(diff(out) < 0)/T;


s1   = sprintf('Source frequency: %4.3fHz', Fc);
s2   = sprintf('Fractional order: %d', Order);
str1 = sprintf('Target frequency: %4.3fHz', Tfreq);
str2 = sprintf('Main frequency:   %4.3fHz (%4.2fdB)', ...
    peakfreq, val);
str3 = sprintf('\\bf{Mean frequency:   %4.3fHz} (Error: %+4.2f%%)', ...
    meanfreq, ...
    (meanfreq - Tfreq)/Tfreq * 100);


disp(str1);
disp(str2);
disp(str3);
fprintf('\n');


str = {s1,s2,'',str1,str2,str3};
plot_fracdiv(ft,ff,str);
xlim([0 5*Tfreq]);
ylim([-80 0]);


