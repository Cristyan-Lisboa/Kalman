% Trabalho de processos estoc�sticos - 30NOV22
% Aluno: Cristyan Lisb�a
% Projeto de filtro de Kalman
%% Organiza��o dos dados
clear all, close all, clc
vetor = importdata('dados_linhas.txt'); % Importar dados no vetor de n amostras
n = length(vetor);                      % Quantidade de amostras da sen�ide
%% Gr�fico dos dados
figure(1)
l = 22;
a = 35;
plot([0:length(vetor)-1],vetor,'k')
set(gca,'FontName','Arial')
set(gca,'FontSize',l)
set(gcf, 'Name', 'Dados do experimento')
ylabel('$y_k$','Interpreter','latex','FontSize',a)
xlabel('$k$','Interpreter','latex','FontSize',a)
axis([0 n -5 5])
%% Estat�stica dos dados
mediav      = mean(vetor);              % M�dia
variancia   = var(vetor);               % Vari�ncia
desviop     = std(vetor);               % Desvio padr�o
valormax    = max(vetor);               % Valor m�ximo
valormin    = min(vetor);               % Valor m�nimo
[coef,lags] = xcorr(vetor,'unbiased');    % Autocorrela��o de Xt
[coef1,lags1] = xcorr(vetor,'biased');    % Autocorrela��o de Xt
%% C�lculo da FFT do sinal com ruido
L = n;
Y = fft(vetor);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = 1/1*(0:(L/2))/L;
amplitude = 1.2*max(P1);                % Estimativa da amplitude da sen�ide
fft(normrnd(0,0.01,[1,5]));
periodo = 1/f(find(P1 == max(P1)));     % Estimativa do per�odo
for k = 1:n
    x(k,1) = amplitude/2*cos(2*pi*k/(1/f(find(P1 == max(P1))))); % C�lculo da autocorrela��o Zt
end
%% Gr�fico da FFT do sinal com ru�do
figure(2)
l = 22;
a = 35;
plot(f,P1,'k') 
set(gca,'FontName','Arial')
set(gca,'FontSize',l)
set(gcf, 'Name', 'Espectro de xk')
ylabel('$S_y(f)$','Interpreter','latex','FontSize',a)
xlabel('$f$','Interpreter','latex','FontSize',a)
%% Ajuste da fase da sen�ide com amplitude determinda via FFT
figure(3)
l = 22;
a = 35;
plot([0:length(vetor)-1],vetor,'k')
set(gca,'FontName','Arial')
set(gca,'FontSize',l)
ylabel('$x_k$','Interpreter','latex','FontSize',a)
xlabel('$k$','Interpreter','latex','FontSize',a)
axis([0 n -5 5])
hold on
plot([0:length(vetor)-1],x(1:2000),'r','LineWidth',3)
hold off
%% Gr�fico da autocorrela��o de Rx e Rz
figure(4)
l = 22;
a = 35;
plot(lags(n:end),coef(n:end),'k','LineWidth',2)
set(gca,'FontName','Arial')
set(gca,'FontSize',l)
set(gcf, 'Name', 'Autocorrela��o de Rz e Rx')
ylabel('$r(k)$','Interpreter','latex','FontSize',a)
xlabel('$k$','Interpreter','latex','FontSize',a)
axis([-50 n -1 1.6])
hold on
plot(lags1(n:end),coef1(n:end),'--','Color',1*[0 0 1],'LineWidth',2)  % Biased
plot([0:n-1],x,'.','Color',[1 0 0],'LineWidth',2)      % Unbiased
%hold off
%legend({'$r_{yy}^{u}(k)$','$r_{yy}^{b}(k)$','$r_{zz}(k)$'},'Interpreter','latex','Location','northeast','FontSize',a);
%% Estimativa da vari�ncia do ru�do    Xt = Zt + Nt
variancia_senoide = amplitude^2/2; 
variancia_ruido = variancia - variancia_senoide;
%% C�lculo dos coeficientes do filtro - matlab � one-based por isso + 1 nos argumentos
ordem_filtro = 2000*1.8/100;                         % Ordem do filtro
Rzx          = x(1:ordem_filtro+1,1);                % Vetor de autocorrela��o Zt, Rzx = Rz
Rxx          = zeros(ordem_filtro+1,ordem_filtro+1); % Matriz de autocorrela��o Xt,Rxx
k = 0;
for i = 1:ordem_filtro+1
    Rxx(i:ordem_filtro+1,i) = coef1(n:n+ordem_filtro-k);
    k = k + 1;
end
Rxx = Rxx + Rxx' - Rxx(1,1)*eye(i); % Ajusta a matriz
h = inv(Rxx)*Rzx;                   % C�lculo dos coeficientes do filtro
%var(conv(h,vetor(1:n)))/mean(conv(h,vetor(1:n)))*100, var(vetor)/mean(vetor)*100
%% Gr�fico do sinal Zt e sua estimativa Yt
figure(5)
l = 22;
a = 35;
plot([0:n-1],vetor,'k')
set(gca,'FontName','Arial')
set(gca,'FontSize',l)
set(gcf, 'Name', 'Dados do experimento')
ylabel('$x_k$','Interpreter','latex','FontSize',a)
xlabel('$k$','Interpreter','latex','FontSize',a)
axis([0 n -5 5])
zt_estimador = conv(h,vetor(1:n));
hold on
plot([0:1:n],zt_estimador(1:n+1),'-','Color',1*[1 0 0],'LineWidth',2)
legend({'$X_t$','$Y_t^{L}$'},'Interpreter','latex','Location','northeast','FontSize',a);
hold off
%erro = immse(vetor,zt_estimador(1:n));
%erro = immse(saida(1:n),zt_estimador(1:n))
%erro = x(1,1) - h(1:ordem_filtro)'*x(1:ordem_filtro,1); % 1.2
%% Implementa��o do filtro linear - s� usar comando conv e plotar grafico corretamente
% Convolu��o conferida - tudo certo os gr�ficos se sobrepoem - avisar Bruno
%matriz_dados = zeros(ordem_filtro+1,ordem_filtro+1); % Matriz de dados
%k = 0;
%for i = 1:ordem_filtro+1
%    matriz_dados(i:ordem_filtro+1,i) = vetor(1:1+ordem_filtro-k);
%    k = k + 1;
%end
%yt = matriz_dados*h;                   % Estima��o do sinal \hat{Yt} = Zt
%plot([0:1:ordem_filtro],yt,'k','LineWidth',2)
% Fazendo por loops for
est_zt = zeros(n,1);
j = 1;
for i = 1:n
    if i <= ordem_filtro
        est_zt(i,1) = sum(vetor(i:-1:1,1)'*h(1:j,1)); 
        j = j + 1;
    else
        est_zt(i,1) = sum(vetor(i:-1:i-ordem_filtro,1)'*h(1:j,1));
    end
end
figure(5)
hold on
plot([0:n-1],est_zt,'--g','LineWidth',2)
hold off
%% Implementa��o do filtro de kalman
% Parametros iniciais
sys = c2d(ss([0 1;-2*pi/100 0],[0;1],[1 0],[0]),100,'zoh');
%ftdt = tf([sin(2*pi/periodo) 0], [1 -2*cos(2*pi/periodo) 1],-1); 
%[A,B,C,D] = tf2ss([1*sin(2*pi/100) 0], [1 -2*cos(2*pi/100) 1]);
A = 1.2*sys.A; B = sys.B; C = sys.C; D = sys.D; 
idpoly(sys);
%state = [1 0]';                      
%for i = 1:500
%    state(1:2,i+1) = A*state(1:2,i);
%    y(i,1) = C*state(1:2,i);
%end
%figure(1)
%stem(y)
% Simulacao do filtro de Kalman - predi��o-corre��o: propaga��o-assimila��o      
% Parametros de sintonia
%vetor = 2*ones(n,1) + rand(n,1); A = 1; B = 0; C = 1;
Q = 0.00001*eye(length(B));             % Matriz de covari�ncia do ru�do de processo
R = 1.1; Q = 1e-5*eye(length(B)); R = 1.1;                                % Matriz de covari�ncia do ru�do de medi��o
P = 1e-0*eye(length(B));                   % Matriz de covari�ncia do erro de estado
traco_P = trace(P);                     % Traco da matriz P
I = eye(length(B));                     % Matriz identidade de ordem 2
estado = zeros(length(B),n);            % Estado estimado
estado(:,1) = [1;0];                    % Estado estimado inicial
saida(1,1) = C*estado(:,1);             % Valor inicial da sa�da
for k = 2:n
     % Etapa de predi��o - propaga��o
     estado(:,k) = A*estado(:,k-1) + B*0;
     % Predict the covariance
     P(:,:,k) = A*P(:,:,k-1)*A' + I*Q*I;
     % Calculate the Kalman gain matrix
     K = P(:,:,k)*C'/(C*P(:,:,k)*C' + R);  % K = [0.1;-0.2]; % K =[0.3;-0.2] 
     % Update the state vector
     estado(:,k) = estado(:,k) + K*(vetor(k) - C*estado(:,k)); 
     % Update the covariance
     P(:,:,k) = (I - K*C)*P(:,:,k);
     saida(k,1) = C*estado(:,k);
     traco_P(k,1) = trace(P(:,:,k));
end
% Gr�fico da estimativa usando filtro de kalman
figure(6)
%l = 22;
%a = 35;
plot([0:n-1-1000],vetor(1:n-1000,1),'k')
%set(gca,'FontName','Arial')
%set(gca,'FontSize',l)
%set(gcf, 'Name', 'Resultado principal')
%ylabel('$x_k$','Interpreter','latex','FontSize',a)
%xlabel('$k$','Interpreter','latex','FontSize',a)
%axis([0 n -5 5])
%zt_estimador = conv(h,vetor(1:n));
hold on
%plot([0:1:n-1],zt_estimador(1:n),'-','Color',1*[1 0 0],'LineWidth',2)
plot([0:1:n-1-1000],saida(1:n-1000),'-','Color',1*[0 0 1],'LineWidth',2)
%legend({'$X_t$','$Y_t^{L}$','$Y_t^{K}$'},'Interpreter','latex','Location','northeast','FontSize',a);
hold off
axis([0 n-1000 -10 10])
%erro = immse(vetor,saida(1:n));
for kk = 1:n
    erro1(kk,1) = (vetor(kk,1) - saida(kk,1));
end  

L1 = n;
Y1 = fft(saida);
P21 = abs(Y1/L1);
P11 = P21(1:L1/2+1);
P11(2:end-1) = 2*P11(2:end-1);
f1 = 1/1*(0:(L1/2))/L1;
sum(traco_P(1:600))/length(traco_P(1:600))
%
figure(1)
l = 22;
a = 35;
plot(f1,P1,'k')
hold on
plot(f1,abs(P1-P11),'r')
hold off
set(gca,'FontName','Arial')
set(gca,'FontSize',l)
set(gcf, 'Name', 'Espectro do erro')
ylabel('$S_e(f)$','Interpreter','latex','FontSize',a)
xlabel('$f$','Interpreter','latex','FontSize',a)
axis([0 0.5 0 1])
%clearvars saida
sum(traco_P)/length(traco_P)
%% Traco da matriz de covari�ncia do erro de estado
figure(7)
l = 22;
a = 35; bb = 1400;aa=n-1-bb;
plot([0:1:aa],traco_P(1:aa+1),'-','Color',1*[0 0 0],'LineWidth',2)
set(gca,'FontName','Arial')
set(gca,'FontSize',l)
set(gcf, 'Name', 'Traco da matriz de convari�ncia do erro de estado')
ylabel('$tr(P_k)$','Interpreter','latex','FontSize',a)
xlabel('$k$','Interpreter','latex','FontSize',a)
%axis([0 aa 0 3])
%% Filtro de m�dia m�vel
janela  = 20;
for i = 1:n
    if i <= janela
        hat_zt(i,1) = sum(vetor(1:i,1))/i;
    else
        hat_zt(i,1) = sum(vetor(i-janela:i,1))/janela;
    end
end
hold on
plot([0:n-1],hat_zt,'g')
%% Figura 1 do artigo
figure(10)
s = subplot(7,1,1:4);
s.Position = [0.08,0.52,0.775,0.451160714285714];
l = 22;
a = 35;
plot([0:length(vetor)-1],vetor,'k')
set(gca,'FontName','Arial')
set(gca,'FontSize',l)
set(gcf, 'Name', 'Dados do experimento')
ylabel('$y_k$','Interpreter','latex','FontSize',a)
xlabel('$k$','Interpreter','latex','FontSize',a)
axis([0 n -5 5])

s = subplot(7,1,5:7);
%s.position = [0.13,0.651951531288667,0.775,0.273048468711333];
l = 22;
a = 35;
plot(f,P1,'k') 
set(gca,'FontName','Arial')
set(gca,'FontSize',l)
set(gcf, 'Name', 'Espectro de xk')
ylabel('$S_y(f)$','Interpreter','latex','FontSize',a)
xlabel('$f$','Interpreter','latex','FontSize',a)
%% Figura 2 do artigo
figure(11)
s = subplot(2,1,1);
l = 22;
a = 35;
plot([0:length(vetor)-1],vetor,'k')
set(gca,'FontName','Arial')
set(gca,'FontSize',l)
set(gcf, 'Name', 'Dados do experimento')
ylabel('$y_k$','Interpreter','latex','FontSize',a)
xlabel('$k$','Interpreter','latex','FontSize',a)
axis([0 n -5 5])
hold on
plot([0:1:n],zt_estimador6(1:n+1),'-','Color',1*[1 0 0],'LineWidth',5)
%plot([0:1:n],zt_estimador5(1:n+1),'-','Color',1*[0 1 0],'LineWidth',3)
plot([0:1:n],zt_estimador4(1:n+1),'-','Color',1*[0 0 1],'LineWidth',2)
hold off
%legend({'$y_k$','$N = 360$','$N = 300$','$N = 100$',},'Interpreter','latex','Location','northeast','FontSize',22);

s = subplot(2,1,2);
l = 22;
a = 35;
plot([0:length(vetor)-1],vetor,'k')
set(gca,'FontName','Arial')
set(gca,'FontSize',l)
set(gcf, 'Name', 'Dados do experimento')
ylabel('$y_k$','Interpreter','latex','FontSize',a)
xlabel('$k$','Interpreter','latex','FontSize',a)
axis([0 n -5 5])
hold on
plot([0:1:n],zt_estimador1(1:n+1),'-','Color',1*[1 0 0],'LineWidth',5)
%plot([0:1:n],zt_estimador2(1:n+1),'-','Color',1*[0 1 0],'LineWidth',3)
plot([0:1:n],zt_estimador3(1:n+1),'-','Color',1*[0 0 1],'LineWidth',2)
hold off
legend({'$y_k$','$N = 350$','$N = 36$'},'Interpreter','latex','Location','northeast','FontSize',22);
%legend({'$y_k$','$0,2\%$','$1,0\%$','$5,0\%$',},'Interpreter','latex','Location','northeast','FontSize',22);
%% Figura 3 do artigo
figure(12)
%s = subplot(2,1,1);
l = 22;
a = 35;
plot([0:length(vetor)-1],vetor,'k')
set(gca,'FontName','Arial')
set(gca,'FontSize',l)
set(gcf, 'Name', 'Dados do experimento')
ylabel('$y_k$','Interpreter','latex','FontSize',a)
xlabel('$k$','Interpreter','latex','FontSize',a)
axis([0 n -5 5])
hold on
plot([0:1:n-1],saida1,'-','Color',1*[1 0 0],'LineWidth',2.5)
plot([0:1:n-1],saida2,'-','Color',1*[0 0 1],'LineWidth',2)
%plot([0:1:n-1],saida3,'-','Color',1*[0 0 1],'LineWidth',1.8)
hold off
%legend({'$y_k$','$Q = 10^{-2}$','$Q = 10^{-3}$','$Q = 10^{-5}$',},'Interpreter','latex','Location','northeast','FontSize',22);
legend({'$y_k$','$Q = 10^{-1}I$','$Q = 10^{-5}I$'},'Interpreter','latex','Location','northeast','FontSize',22);

s = subplot(2,1,2);
l = 22;
a = 35;
plot([0:length(vetor)-1],vetor,'k')
set(gca,'FontName','Arial')
set(gca,'FontSize',l)
set(gcf, 'Name', 'Dados do experimento')
ylabel('$y_k$','Interpreter','latex','FontSize',a)
xlabel('$k$','Interpreter','latex','FontSize',a)
axis([0 n -5 5])
hold on
plot([0:1:n-1],saida4,'-','Color',1*[1 0 0],'LineWidth',5)
plot([0:1:n-1],saida5,'-','Color',1*[0 1 0],'LineWidth',3)
plot([0:1:n-1],saida6,'-','Color',1*[0 0 1],'LineWidth',1.8)
hold off
legend({'$y_k$','$R = 10^{-3}$','$R = 10^{-2}$','$R = 1,0$',},'Interpreter','latex','Location','northeast','FontSize',22);
%% Figura 4 do artigo
figure(13)
s = subplot(2,2,[1,3]);
l = 22;
a = 35;
plot([0:1:600-1],vetor(1:600),'k')
set(gca,'FontName','Arial')
set(gca,'FontSize',l)
set(gcf, 'Name', 'Dados do experimento')
ylabel('$y_k$','Interpreter','latex','FontSize',a)
xlabel('$k$','Interpreter','latex','FontSize',a)
axis([0 600 -5 5])
hold on
plot([0:1:600-1],saida7(1:600),'-','Color',1*[1 0 0],'LineWidth',2)
plot([0:1:600-1],saida8(1:600),'-','Color',1*[0 1 0],'LineWidth',2)
plot([0:1:600-1],saida9(1:600),'-','Color',1*[0 0 1],'LineWidth',2)
hold off
legend({'$y_k$','$P_0 = 10^{-5}I$','$P_0 = 10^{-2}I$','$P_0 = 10^{0}I$',},'Interpreter','latex','Location','northeast','FontSize',22);

s = subplot(2,2,2);
l = 22;
a = 35; bb = 1500;aa=n-1-bb;
plot([0:1:aa],traco_P1(1:aa+1),'-','Color',1*[1 0 0],'LineWidth',2)
set(gca,'FontName','Arial')
set(gca,'FontSize',l)
set(gcf, 'Name', 'Traco da matriz de convari�ncia do erro de estado')
ylabel('$tr(P_k)$','Interpreter','latex','FontSize',a)
xlabel('$k$','Interpreter','latex','FontSize',a)
hold on
plot([0:1:aa],traco_P2(1:aa+1),'-','Color',1*[0 1 0],'LineWidth',2)
hold off
axis([0 500 0 0.11])

s = subplot(2,2,4);
l = 22;
a = 35; bb = 1500;aa=n-1-bb;
plot([0:1:aa],traco_P3(1:aa+1),'-','Color',1*[0 0 1],'LineWidth',2)
set(gca,'FontName','Arial')
set(gca,'FontSize',l)
set(gcf, 'Name', 'Traco da matriz de convari�ncia do erro de estado')
ylabel('$tr(P_k)$','Interpreter','latex','FontSize',a)
xlabel('$k$','Interpreter','latex','FontSize',a)
axis([0 500 0 2])
%% Figura 5 do artigo
figure(14)
l = 22;
a = 35;
plot([0:1:999],vetor(1:1000),'k')
set(gca,'FontName','Arial')
set(gca,'FontSize',l)
set(gcf, 'Name', 'Dados do experimento')
ylabel('$y_k$','Interpreter','latex','FontSize',a)
xlabel('$k$','Interpreter','latex','FontSize',a)
axis([0 1000 -10 10])
hold on
plot([0:1:999],saida10(1:1000),'-','Color',1*[1 0 0],'LineWidth',2)
plot([0:1:999],saida11(1:1000),'-','Color',1*[0 1 0],'LineWidth',2)
plot([0:1:999],saida12(1:1000),'-','Color',1*[0 0 1],'LineWidth',2)
hold off
legend({'$y_k$','$\hat{x}_1(0) = 100$','$\hat{x}_1(0) = 10$','$\hat{x}_1(0) = 0$',},'Interpreter','latex','Location','northeast','FontSize',22);
%% Figura 6 do artigo
figure(15)
l = 22;
a = 35;
plot([0:1:999],vetor(1:1000),'k')
set(gca,'FontName','Arial')
set(gca,'FontSize',l)
set(gcf, 'Name', 'Dados do experimento')
ylabel('$y_k$','Interpreter','latex','FontSize',a)
xlabel('$k$','Interpreter','latex','FontSize',a)
axis([0 1000 -5 5])
hold on
plot([0:1:999],saida13(1:1000),'-','Color',1*[1 0 0],'LineWidth',4)
plot([0:1:999],saida14(1:1000),'-','Color',1*[0 1 0],'LineWidth',3)
plot([0:1:999],saida15(1:1000),'-','Color',1*[0 0 1],'LineWidth',2)
hold off
legend({'$y_k$','$K = [0.3 \quad -0.2]^{\top}$','$K = [0.1 \quad -0.1]^{\top}$','Kalman'},'Interpreter','latex','Location','northeast','FontSize',22);
%% Figura 7 do artigo
figure(15)
l = 22;
a = 35;
plot([0:1:999],vetor(1:1000),'k')
set(gca,'FontName','Arial')
set(gca,'FontSize',l)
set(gcf, 'Name', 'Modelo Interno')
ylabel('$y_k$','Interpreter','latex','FontSize',a)
xlabel('$k$','Interpreter','latex','FontSize',a)
axis([0 1000 -5 5])
hold on
plot([0:1:999],saida16(1:1000),'-','Color',1*[1 0 0],'LineWidth',2)
plot([0:1:999],saida18(1:1000),'-','Color',1*[0 1 0],'LineWidth',2)
plot([0:1:999],saida17(1:1000),'-','Color',1*[0 0 1],'LineWidth',2)
hold off
legend({'$y_k$','$\alpha = 1,1$','$\alpha = 0,995$','$\alpha = 1$'},'Interpreter','latex','Location','northeast','FontSize',22);

%% Conferir xcorr
autocorrelacao = zeros(2000,1);
autocorrelacao(1,1) = 1;
for k = 2:1999
    for j = 1:1999-k
        autocorrelacao(k,1) = autocorrelacao(k,1) + vetor(k+j)*vetor(j);
    end
    autocorrelacao(k,1) = autocorrelacao(k,1)/2000;
end
figure(4)
hold on
plot([2:1:length(autocorrelacao)],autocorrelacao(2:end,1),'b')