% Plot the error in those frequencies that can be generated
% by both sources to determine wether it worths switch sources

n = 10000;

int_freq = 19200000;
pll_freq = 500000000;

int_min = int_freq / 4096;
pll_min = pll_freq / 4096;

int_max = int_freq / 2;
pll_max = pll_freq / 2;

x = logspace(log10(int_max), log10(pll_min), n);

int_freqs = int_freq ./ round(int_freq ./ x);
pll_freqs = pll_freq ./ round(pll_freq ./ x);

delta_int = (x-int_freqs)./x;
delta_pll = (x-pll_freqs)./x;

plot(x/1e6, abs(delta_int), '-', x/1e6, abs(delta_pll), '-');
grid;

%%
% Convert y-axis values to percentage values 
a=[cellstr(num2str(get(gca,'ytick')'*100))]; 
pct = char(ones(size(a,1),1)*'%'); 
new_yticks = [char(a),pct];
set(gca,'yticklabel',new_yticks) 
