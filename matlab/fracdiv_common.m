% Simulation of BCM2835 Fractionary Divider on Raspberry Pi
% electronicayciencia  20170325
% Common framework

Fc    = 10;  % clock frequency
Tfreq = 2.2; % Target frequency

% working options
n  = 200000;  % number of points
SR = 20*Fc;   % sampling rate
T  = n/SR;    % sampling time (s)

% working vectors
t = 0:1/SR:T-1/SR; % time vector
w = square(2*pi*2*Fc*t);
out = zeros(1,n);

% calculate counters
idiv = Fc / Tfreq;
rem  = mod(Fc,Tfreq);
icounter_max = floor(idiv);
fcounter_max = Fc/rem;


% Call the appropiate fracdiv script
%-----------------------------------
%fracdiv_1
%fracdiv_1_rnd
%fracdiv_1_dither
fracdiv_1_ns
%-----------------------------------


% Output
ft = linspace(SR/2/n,SR/2,n/2-1);
ff = abs(fft(out)) / (n/2);
ff = 20*log(ff);
ff = ff(2:n/2);
ff(ff < -1000) = -1000;

[val,pos] = max(ff);
peakfreq = ft(pos);

meanfreq = sum(diff(out) < 0)/T;


s1   = sprintf('Source frequency: %4.3fHz', Fc);
str1 = sprintf('Target frequency:  %4.3fHz', Tfreq);
str2 = sprintf('Main frequency:    %4.3fHz (%4.2fdB)', ...
    peakfreq, val);
str3 = sprintf('Mean frequency:    %4.3fHz (Error: %+4.2f%%)', ...
    meanfreq, ...
    (meanfreq - Tfreq)/Tfreq * 100);


disp(s1);
disp(str1);
fprintf ('Swallow %d every %d source pulses\n', 1, fcounter_max);

disp(str2);
disp(str3);
fprintf('\n');


str = {s1,'',str1,str2,str3};
plot_fracdiv(ft,ff,str);
xlim([0 5*Tfreq]);
ylim([-120 0]);


