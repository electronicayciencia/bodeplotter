function plot_fracdiv(X1, Y1, str)
%plot_fracdiv(X1, Y1)
%  X1:  vector of x data
%  Y1:  vector of y data
%  str: annotation data 

% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1,...
    'Position',[0.0713080168776371 0.114864864864865 0.89440783611194 0.791704478200829]);
hold(axes1,'on');

% Create plot
plot(X1,Y1,'LineWidth',2,...
    'Color',[0.850980401039124 0.325490206480026 0.0980392172932625]);

% Create xlabel
xlabel('Frequency (Hz)');

% Create title
t = title('Fractionary divisor analysis');
%P = get(t,'Position');
set(t,'Position',[66 2 0]);

% Create ylabel
ylabel('Power (dB)');


box(axes1,'on');
% Set the remaining axes properties
set(axes1,'Color',[0.894117653369904 0.941176474094391 0.901960790157318],...
    'XGrid','on','YGrid','on');
% Create textbox
annotation(figure1,'textbox',...
    [0.59 0.67 0.28 0.21],...
    'String',str,...
    'LineStyle','none',...
    'FontName','Consolas',...
    'FitBoxToText','on',...
    'EdgeColor','none',...
    'BackgroundColor',[0.945098042488098 0.968627452850342 0.949019610881805]);

set( figure1, 'Units', 'normalized', 'Position', [ 0.1, 0.1, 0.7, 0.6 ] )
