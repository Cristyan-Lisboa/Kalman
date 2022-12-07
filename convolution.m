% Convolu��o de tempo discreto - soma de convolu��o
% Dado x[n] e h[n] calcula y[n] = sum_{k = -inf}^{inf} x[k]h[n-k]
close all
clearvars
clc
xn = [0 0 0 0 1 1 1 1];           % Vetor zero based
h  = [0 0 0 0 0 0 1 1 1 1 1];     % Vetor zero based
yn = conv(xn,h)                   % Soma de convolu��o
k  = 0:length(yn)-1;              % Vetor de �ndices
xm = zeros(1,length(yn));         % Ajustar vetor da entrada
xm(1:length(xn)) = xn;            % Ajustar vetor da entrada

% Gr�ficos
figure(1)
subplot(2,1,1)
stem(k,xm,'k','MarkerFaceColor','k')
subplot(2,1,2)
stem(k,yn,'k','MarkerFaceColor','k')