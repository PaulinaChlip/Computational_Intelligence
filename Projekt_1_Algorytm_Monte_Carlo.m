%% Algorytm Monte Carlo 
close all; clear; clc;
rng(13,"twister");
N=[101, 1001, 5001, 10001, 50001, 100001];

f1=figure;
figure(f1);
for k=1:length(N)
    t=0:1/(N(k)-1):1;
    circle=sqrt(1-t.^2);
    points=rand([N(k),2]);

    mask=(points(:,1).^2+points(:,2).^2)<=1;
    circle_points=points(mask, :);
    not_circle_points=points(~mask, :);
    my_pi=4*(length(circle_points)/N(k));
    subplot(2,3,k)
    hold on
    plot(circle_points(:,1),circle_points(:,2),'.','Color','#752848')
    plot(not_circle_points(:,1),not_circle_points(:,2),'.','Color','#e2a532')
    plot(t,circle,'LineWidth',2,'Color','#752848')
    hold off
    title("N:"+(N(k)-1)+"; estymowane \pi:"+my_pi)
    xlabel('X')
    ylabel('Y')
end

%% MC - wizualizacja „dążenia” chwilowej estymowanej wartości pi wraz ze wzrostem liczby losowań
clear; clc;
rng(13,"twister");

estimated_pi=zeros(10000,1);
avg_pi=0;

f2=figure;
figure(f2);
hold on
grid on
for k=1:10
    points=rand([10000,2]);

    mask=(points(:,1).^2+points(:,2).^2)<=1;
    for j=1:10000
        estimated_pi(j)=4*sum(mask(1:j))/j;
    end
    avg_pi=avg_pi+estimated_pi(10000);
    plot(1:10000,estimated_pi,'Color','#752848')
    xlabel('Liczba losowań')
    ylabel('Estymowana wartość liczby \pi')
end
title("Średnie estymowane \pi:"+num2str(avg_pi/10, '%.6f'))
yline(pi,'LineWidth',2,'Color','#e2a532')
ylim([1, 4]);
hold off


%% MC - wizualizacja poprawy wyników estymacji wraz ze wzrostem N
clear; clc;
rng(13,"twister");

N = [10, 100, 1000, 10000];

f3=figure;
figure(f3);

for i=1:length(N)
    estimated_pi=zeros(N(i),10);
    subplot(2,2,i);
    hold on
    for j=1:10
        points=rand([N(i),2]);
        mask=(points(:,1).^2+points(:,2).^2)<=1;
        for k=1:N(i)
            estimated_pi(k,j)=4*sum(mask(1:k))/k;
        end
        if(N(i)>10)
            estimated_pi(1:20,j)=nan;
        end
    end

    h=boxplot(estimated_pi,'Symbol','.','Colors',[0.458, 0.156, 0.282]);
    set(findobj(h, 'Tag', 'Outliers'), 'MarkerEdgeColor', [0.529, 0.819, 0.361]);
    yline(pi,'LineWidth',2,'Color','#e2a532')
    hold off

    title("Dla "+N(i)+" losowań");
    xlabel("Nr serii");
    ylabel("Estymacja \pi");
    xticks(1:10);
    yticks(1:0.5:4.5);
    ylim([1.5 4.5]);
end