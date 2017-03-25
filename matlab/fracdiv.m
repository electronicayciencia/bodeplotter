% Simulation of BCM2835 Fractionary Divider on Raspberry Pi
% electronicayciencia  20170325
% 

%-------------------------------------
% Main options
Fc    = 500;    % clock frequency
Tfreq = 108.75; % Target frequency
MASH  = 8;      % MASH stages filter level

DIV  = Fc / Tfreq;

%-------------------------------------
% Main loop
n  = 1000000;  % number of points
SR = 20*Fc;    % sampling rate
T  = n/SR;     % sampling time (s)

t = 0:1/SR:T-1/SR; % time vector

% dividing by 1 result in toogling output every period
% so we get half the original frequency
% double the frequency so we get Fc pulses per second after divide by 1
w = square(2*pi*2*Fc*t);

if (MASH > 0)
    icounter_max = floor(DIV);
else
    icounter_max = round(DIV);
end

% remainder of fractional divider
rem = mod(Fc,Fc/DIV);

fcounter_max = MASH * (Fc-rem)/rem;
fcounter_max = round(fcounter_max);
fprintf ('Swallow %d every %d source pulses\n', MASH, fcounter_max);

out = zeros(1,n);

mcounter = 0;
icounter = 0;
fcounter = 0;
last_v   = 0;
vout     = 0;

for i = 1:length(w);
    v = w(i);
    
    if (v == 1) && (v ~= last_v) % raising edge
        if (MASH > 0) && (fcounter >= fcounter_max)
            mcounter = mcounter + 1;
            if (mcounter >= MASH)
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


meanfreq = sum(abs( ...
    out(2:length(out)) - out(1:length(out)-1) ...
    )) /2 / T;

fprintf('Target frequency: %4.4fHz\n', Tfreq)

fprintf('Main frequency:   %4.4fHz (%4.2fdB)\n', ...
    peakfreq, val);

fprintf('Mean frequency:   %4.4fHz (Error: %+4.3f%%)\n\n', ...
    meanfreq, ...
    (meanfreq - Tfreq)/Tfreq * 100);


subplot(4,1,[1 2 3]);
plot(ft,ff);
xlim([0 5*Tfreq]);
ylim([-80 0]);
xlabel('Frecuencia (Hz)');
ylabel('Potencia (dB)');
title('Analisis de frecuencia');

subplot(4,1,4);
plot(t(1:n/T*3),out(1:n/T*3))

