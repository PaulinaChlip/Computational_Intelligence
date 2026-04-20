%% Algorytm genetyczny -  problem komiwojażera - wersja finalna
%% Parametry do określenia
close all; clear; clc;

N = 40; %liczba miast do odwiedzenia
m = 100; %liczba osobników w populacji, musi być parzysta
a = 0.95; %prawdopodobieństwo krzyżowania
b = 0.05; %prawdopodobieństwo mutacji
c = 100; %liczba populacji bez poprawy jakości (warunek stopu)
elite = 0.05; %procent osobników elitarnych (przenoszonych do nowej populacji)
method="ungrouped"; %metoda selekcji osobników: "grouped" dla ruletki z grupowaniem, 
                %"ungrouped" dla ruletki bez grupowania
%------------------------------------------------
rng('shuffle');

%% PRZYGOTOWANIE: losowanie miast, tworzenie macierzy odległości, losowanie populacji początkowej
x=randi([0,250],1,N);
y=randi([0,250],1,N);

distance_matrix = squareform(pdist([x;y]', 'euclidean'));

population=zeros([m,N]);
for i=1:m
    population(i,:)=randperm(N,N);
end

%% ALGORYTM GENETYCZNY
% inicjalizacja zmiennych do pętli algorytmu
nr_of_not_improved_generations=0;
nr_of_generations=1;
best_fitnesses=zeros([1, c]);
avg_fitnesses=zeros([1, c]);
median_fitnesses=zeros([1, c]);

% inicjalizacja zmiennych potrzebnych do animacji
fitness_values_start=fitness_function(population,m,distance_matrix,N);
all_hist_data = cell(c,1);
edges = 0:200:ceil(max(fitness_values_start(:,2))/200)*200;
best_paths_table=population(fitness_values_start(1,1),:);
how_many_paths=1;
gen_nr_to_plot=1;
distances=round(fitness_values_start(1,2),2);

% główna pętla programu
if method=="grouped"
    while nr_of_not_improved_generations <= c
        fitness_values=fitness_function(population,m,distance_matrix,N);
        best_fitnesses(nr_of_generations)=fitness_values(1,2);
        avg_fitnesses(nr_of_generations)=mean(fitness_values(:,2));
        median_fitnesses(nr_of_generations)=median(fitness_values(:,2));
        if ~isequal(population(fitness_values(1,1),:),best_paths_table(how_many_paths,:))
            best_paths_table=[best_paths_table;population(fitness_values(1,1),:)];
            how_many_paths=how_many_paths+1;
            gen_nr_to_plot=[gen_nr_to_plot;nr_of_generations];
            distances=[distances;round(fitness_values(1,2),2)];
        end
        [counts, ~] = histcounts(fitness_values(:,2), edges);
        all_hist_data{nr_of_generations} = counts;

        population=modified_roulette_breeding(population,m,fitness_values,N,elite,a,b);

        if nr_of_generations > 1
            if best_fitnesses(nr_of_generations) < min(best_fitnesses(1:nr_of_generations-1))
                nr_of_not_improved_generations = 0;
            else
                nr_of_not_improved_generations = nr_of_not_improved_generations + 1;
            end
        end
        nr_of_generations=nr_of_generations+1;
    end
elseif method=="ungrouped"
    while nr_of_not_improved_generations <= c
        fitness_values=fitness_function(population,m,distance_matrix,N);
        best_fitnesses(nr_of_generations)=fitness_values(1,2);
        avg_fitnesses(nr_of_generations)=mean(fitness_values(:,2));
        median_fitnesses(nr_of_generations)=median(fitness_values(:,2));
        if ~isequal(population(fitness_values(1,1),:),best_paths_table(how_many_paths,:))
            best_paths_table=[best_paths_table;population(fitness_values(1,1),:)];
            how_many_paths=how_many_paths+1;
            gen_nr_to_plot=[gen_nr_to_plot;nr_of_generations];
            distances=[distances;round(fitness_values(1,2),2)];
        end
        [counts, ~] = histcounts(fitness_values(:,2), edges);
        all_hist_data{nr_of_generations} = counts;

        population=roulette_breeding(population,m,fitness_values,N,elite,a,b);

        if nr_of_generations > 1
            if best_fitnesses(nr_of_generations) < min(best_fitnesses(1:nr_of_generations-1))
                nr_of_not_improved_generations = 0;
            else
                nr_of_not_improved_generations = nr_of_not_improved_generations + 1;
            end
        end
        nr_of_generations=nr_of_generations+1;
    end
else
    disp("Ten program nie obsługuje innych metod :(");
    return;
end


% wizualizacja wyników
figure;
subplot(1,2,2);
hold on
plot(1:(nr_of_generations-1),best_fitnesses,'Color','#8BC856','LineWidth',1.4)
plot(1:(nr_of_generations-1),avg_fitnesses,'Color','#4C0061','LineWidth',1.4);
plot(1:(nr_of_generations-1),median_fitnesses,'Color','#B4E4F8','LineWidth',1.4);
hold off
grid on
title('Najlepsza i średnia wartość funkcji dopasowania',"osiągnięta wartość funkcji: "+round(best_fitnesses(end),2));
legend('najlepsza wartość funkcji dopasowania','średnia wartość funkcji dopasowania', ...
    'mediana wartości funkcji dopasowania');
xlabel('numer pokolenia'); ylabel('wartość funkcji dopasowania');
xlim([0,nr_of_generations+20]);

best_path=population(fitness_values(1,1),:);
subplot(1,2,1);
hold on
start_city=best_path(1); 
plot(x,y,'o','MarkerSize',8,'MarkerFaceColor','#a98fff','MarkerEdgeColor','#000');
plot(x(start_city),y(start_city),'o','MarkerSize',8,'MarkerFaceColor',"#c9ff99",'MarkerEdgeColor','#000');
draw_path(best_path,x,y);
hold off
axis equal
legend('miasta', 'miasto startowo/końcowe','trasa','Location','southoutside');
ylim([0, 250]); xlim([0, 250]);
title('Najlepsza trasa komiwojażera')

% animacja trasy
figure;
ax_button = axes('Position', [0.05 0.02 0.1 0.05]);
axis(ax_button, 'off');
ax_main = axes('Position', [0.1 0.1 0.8 0.8]);
uicontrol('Style', 'pushbutton', 'String', 'Play', ...
          'Position', [20 20 100 30], ...
          'Callback', @(src,event)play_animation(ax_main,how_many_paths, ...
          best_paths_table, gen_nr_to_plot, x, y,distances));

% animacja histogramu
figure;
ax_button_hist = axes('Position', [0.05 0.02 0.1 0.05]);
axis(ax_button_hist, 'off');
ax_main_hist = axes('Position', [0.1 0.1 0.8 0.8]);
uicontrol('Style', 'pushbutton', 'String', 'Play', ...
          'Position', [20 20 100 30], ...
          'Callback', @(src,event)play_hist_animation(ax_main,all_hist_data,edges,m));

%% definicja rozmnażania osobników metodą ruletki z sukcesją elitarną
function new_population=roulette_breeding(population,m,fitness_values,N,elite,a,b)
    num_elites = round(elite * m);
    if(mod(num_elites,2)==1)
        num_elites=num_elites+1;
    end

    elite_indices = fitness_values(1:num_elites,1);
    new_population = population(elite_indices, :);
    roulette = creating_roulette_wheel(fitness_values(:, 2), m);
    selected_indices = drawing_roulette_wheel(fitness_values(:, 1), roulette, m - num_elites);

    new_children = [];
    for i = 1:2:length(selected_indices)
        parent1 = population(selected_indices(i), :);
        parent2 = population(selected_indices(i + 1), :);

        if rand() < a
            [child1, child2] = crossover_new(parent1, parent2, N);
        else
            child1 = parent1;
            child2 = parent2;
        end

        new_children = [new_children; child1; child2];
    end

    for i = 1:size(new_children, 1)
        if rand() < b
            new_children(i, :) = mutation_ver2(new_children(i, :), N);
        end
    end

    new_population = [new_population; new_children];
end
%% modyfikacja metody ruletki do grupowania
function new_population=modified_roulette_breeding(population,m,fitness_values,N,elite,a,b)
    num_elites = round(elite * m);
    if(mod(num_elites,2)==1)
        num_elites=num_elites+1;
    end

    elite_indices = fitness_values(1:num_elites,1);
    new_population = population(elite_indices, :);
    selected_indices = drawing_grouped_roulette_wheel(fitness_values(:, 1), m);

    new_children = [];
    for i = 1:2:length(selected_indices)
        parent1 = population(selected_indices(i), :);
        parent2 = population(selected_indices(i + 1), :);

        if rand() < a
            [child1, child2] = crossover_new(parent1, parent2, N);
        else
            child1 = parent1;
            child2 = parent2;
        end

        new_children = [new_children; child1; child2];
    end

    for i = 1:size(new_children, 1)
        if rand() < b
            new_children(i, :) = mutation_ver2(new_children(i, :), N);
        end
    end

    new_population = [new_population; new_children];
end
%% definicja funkcji dopasowania
function fitness_values=fitness_function(population,m,distance_matrix,N)
    fitness=zeros([1,m]);
    for i=1:m
        suma=0;
        for j=1:(N-1)
            suma=suma+distance_matrix(population(i,j),population(i,j+1));
        end
        % dodanie odległości łączacej początek trasy z końcem
        suma=suma+distance_matrix(population(i,N),population(i,1));
        fitness(i)=suma;
    end

    fitness_by_individual=[1:m;fitness]';
    fitness_values=sortrows(fitness_by_individual,2,"ascend");
end
%% definicja operatora krzyżowania
% różnica między wersjami w rozwiązywaniu problemu podwójnych miast
function [child1, child2] = crossover_new(parent1,parent2,N)
    locus_start=randi([1,N]);
    crossover_length=randi([1,N]);
    if locus_start+crossover_length>N
        locus_end=N;
    else
        locus_end=locus_start+crossover_length;
    end
    cross1=parent1(locus_start:locus_end);
    cross2=parent2(locus_start:locus_end);
    child1=parent1; child1(locus_start:locus_end)=cross2;
    child2=parent2; child2(locus_start:locus_end)=cross1;

    %rozwiązanie sytuacji podwójnego odwiedzania miast
    double_cities=setxor(cross1,cross2,'stable');
    if(~isempty(double_cities))
        double_cities_child1=intersect(double_cities,cross2,'stable');
        double_cities_child2=intersect(double_cities,cross1,'stable');
        maska=true(size(child1));maska(locus_start:locus_end)=false;

        indices = find(ismember(child1, double_cities_child1) & maska);
        for k = 1:length(indices)
            child1(indices(k)) = double_cities_child2(k);
        end

        indices = find(ismember(child2, double_cities_child2) & maska);
        for k = 1:length(indices)
            child2(indices(k)) = double_cities_child1(k);
        end
    end
end
function [child1, child2] = crossover_old(parent1,parent2,N)
    locus_start=randi([1,N]);
    crossover_length=randi([1,N]);
    if locus_start+crossover_length>N
        locus_end=N;
    else
        locus_end=locus_start+crossover_length;
    end
    cross1=parent1(locus_start:locus_end);
    cross2=parent2(locus_start:locus_end);
    child1=parent1; child1(locus_start:locus_end)=cross2;
    child2=parent2; child2(locus_start:locus_end)=cross1;

    %rozwiązanie sytuacji podwójnego odwiedzania miast
    double_cities=setxor(cross1,cross2);
    if(~isempty(double_cities))
        double_cities_child1=intersect(double_cities,cross2);
        double_cities_child2=intersect(double_cities,cross1);
        maska=true(size(child1));maska(locus_start:locus_end)=false;

        for i=1:length(double_cities_child1)
            ind=(child1==double_cities_child1(i))&maska;
            child1(ind)=double_cities_child2(i);
        end

        for i=1:length(double_cities_child2)
            ind=(child2==double_cities_child2(i))&maska;
            child2(ind)=double_cities_child1(i);
        end
    end
end
%% definicja operatora mutacji wersja 2 - przesunięcie grupy alleli
function child = mutation_ver2(individual,N)
    locus_1=randi([1,N]);
    locus_2=randi([1,N]);
    while(locus_2==locus_1)
        locus_2=randi([1,N]);
    end
    child = individual;

    if locus_1 < locus_2
        child(locus_1:locus_2) = [individual(locus_2), individual(locus_1:locus_2-1)];
    else
        child(locus_2:locus_1) = [individual(locus_1), individual(locus_2:locus_1-1)];
    end
end
%% definicja koła ruletki i losowanie; ruletka grupowana
function roulette = creating_roulette_wheel(fitness_values,m)
    inv_fitness=1./fitness_values;
    sum_of_fitness=sum(inv_fitness);
    p_s=inv_fitness/sum_of_fitness;
    v=p_s*100;

    roulette = zeros(1, m+1);
    for i = 1:m
        roulette(i+1) = roulette(i) + v(i);
    end
end
function new_indices = drawing_roulette_wheel(individual_indices,roulette_wheel,m)
    numbers = rand(1, m) * 100;
    bins = discretize(numbers, roulette_wheel);
    bins(bins == m+1) = m;
    new_indices = individual_indices(bins);
end
function new_indices = drawing_grouped_roulette_wheel(fitness_values,m)
    numbers = rand(1, m) * 100;
    roulette_wheel=[0,30, 55, 75, 90, 100];
    bins = discretize(numbers, roulette_wheel);
    bins(bins == m+1) = m;

    bin_width = floor(m / 5);
    remainder = mod(m, 5);   
    start = 1;
    groups = cell(5, 1);
    extra = [remainder >= 1, remainder >= 2, remainder >= 3, remainder >= 4, false];

    for i = 1:5
        group_size = bin_width + extra(i);
        groups{i} = fitness_values(start : start + group_size - 1);
        start = start + group_size;
    end

    highest_20 = groups{1};
    high_20 = groups{2};
    mid_20  = groups{3};
    low_20   = groups{4};
    lowest_20  = groups{5};
    
    new_indices = zeros([length(fitness_values),1]);
    for i=1:length(bins)
        if bins(i)==1
            rand_ind=randi(length(highest_20));
            ind=highest_20(rand_ind);
        elseif bins(i)==2
            rand_ind=randi(length(high_20));
            ind=high_20(rand_ind);
        elseif bins(i)==3
            rand_ind=randi(length(mid_20));
            ind=mid_20(rand_ind);
        elseif bins(i)==4
            rand_ind=randi(length(low_20));
            ind=low_20(rand_ind);
        else
            rand_ind=randi(length(lowest_20));
            ind=lowest_20(rand_ind);
        end
        new_indices(i)=ind;
    end
end
%% rysowanie ścieżki
function draw_path(path,x_coords,y_coords)
    for k = 1:length(path)-1
        current_city = path(k);
        next_city = path(k+1);

        plot([x_coords(current_city), x_coords(next_city)], [y_coords(current_city), ...
            y_coords(next_city)], 'Color',[0 0 0], 'LineWidth', 1.7);
    end

    plot([x_coords(path(length(path))), x_coords(path(1))], [y_coords(path(length(path))), ...
            y_coords(path(1))], 'Color', [0 0 0], 'LineWidth', 1.7);
end
%% animacja ścieżek
function play_animation(ax_main,how_many_paths,paths_table,gen_nr_to_plot,x,y,distances)
    for frame = 1:how_many_paths
        cla(ax_main);
        hold on;
        xlabel('x');
        ylabel('y');
       
        axis equal;
        grid on;

        path = paths_table(frame,:);
        draw_path(path,x,y)
        start_city=path(1); 
        plot(x,y,'o','MarkerSize',8,'MarkerFaceColor','#a98fff','MarkerEdgeColor','#000');
        plot(x(start_city),y(start_city),'o','MarkerSize',8,'MarkerFaceColor',"#c9ff99",'MarkerEdgeColor','#000');

        ylim([0, 250]); xlim([0, 250]);

        txt = "Nr generacji: "+gen_nr_to_plot(frame);
        if(frame == how_many_paths)
            txt = txt+ " (końcowa ścieżka)";
        end
        txt=txt+"    funkcja dopasowania: "+distances(frame);
        title('Animacja kolejnych tras i nr generacji, w której pojawiły się po raz pierwszy',txt);
        hold off;
        drawnow;
        pause(0.15);
    end
end
%% animacja histogramu 
function play_hist_animation(ax_main,all_hist_data,edges,m)
    x_min = edges(1);
    x_max = edges(length(edges)); 
    len=length(all_hist_data);
    for frame = 1:len
        cla(ax_main)
        counts = all_hist_data{frame,1};

        histogram('BinEdges', edges, 'BinCounts', counts,'EdgeColor',"#c9ff99", ...
            'FaceColor',"#c9ff99",'FaceAlpha',0.5);
        txt = "Nr generacji: "+frame;
        if(frame == len)
            txt = txt+ " (końcowa generacja)";
        end
        title('Animacja rozkładu funkcji dopasowania kolejnych generacji',txt);
        xlabel('wartości funkcji dopasowania');
        ylabel('liczebność');
        xlim([x_min, x_max]);
        ylim([0, m]);
        grid on;

        drawnow;
        pause(0.2);
    end
end
