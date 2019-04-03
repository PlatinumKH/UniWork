files = dir('*.GIF');
vclass = zeros(2, 10);
tclass = zeros(2, 10);
sclass = zeros(2, 10);
T = [];
S = [];
V = [];
figure

for file = files'
f = imread(file.name);
sname = strrep(file.name, '.GIF', '');
letter = sname(1);

if (letter ~= 'X') | (letter ~= 'A') | (letter ~= 'B')
z = fft2(double(f));
q = fftshift(z);
Magq = abs(q);

A = sum(Magq);
B = sum(Magq, 2);

x = 0;
cx = 201;
cy = 321;
for i = 100:522
    for j = 100:201
        if ((cx - j)^2 + (cy - i)^2 < 50^2) && (atand(abs((j-cx)/(i-cy))) < 80) && (atand(abs((j-cx)/(i-cy))) > 55);
            x = x + Magq(j, i);
        end
    end
end

y = 0;

for i = 320:322
    y = y + A(i);
end
for j = 200:202
    y = y + B(j);
end

if letter == 'S'
    index = find(sclass==0,1,'first');
    sclass(index) = y;
    index = find(sclass==0,1,'first');
    sclass(index) = x;
    S = [S; sclass(index - 1) sclass(index)];
elseif letter == 'V'
    index = find(vclass==0,1,'first');
    vclass(index) = y;
    index = find(vclass==0,1,'first');
    vclass(index) = x;
    V = [V; vclass(index - 1) vclass(index)];
elseif letter == 'T'
    index = find(tclass==0,1,'first');
    tclass(index) = y;
    index = find(tclass==0,1,'first');
    tclass(index) = x;
    T = [T; tclass(index - 1) tclass(index)];
end
hold all
end
end

inc = 1000;
x1Range = [0.6 1.5]*10^6;
x2Range = [0 3]*10^5;
[X1 X2] = meshgrid(x1Range(1):inc:x1Range(2), x2Range(1):inc:x2Range(2), inc);
result = [X1(:) X2(:)];

%CODE FOR THE NEAREST CENTROID CLASSIFIER

sclassmean = mean(sclass.');
tclassmean = mean(tclass.');
vclassmean = mean(vclass.');
constraint1 = 1;
constraint2 = 2;
constraint3 = 3;
data = [sclassmean; vclassmean; tclassmean];
idx = knnsearch(data,result);
labeledResult = [result, idx];
class1 = find(labeledResult(:,3) == 1); %S
class1 = labeledResult(class1,1:2);
class2 = find(labeledResult(:,3) == 2); %V
class2 = labeledResult(class2,1:2);
class3 = find(labeledResult(:,3) == 3); %T
class3 = labeledResult(class3,1:2);

%{ 
CODE FOR THE NEAREST NEIGHBOUR CLASSIFIER

constraint1 = 10;
constraint2 = 20;
constraint3 = 30;
data = [sclass.'; vclass.'; tclass.'];
idx = knnsearch(data,result);
labeledResult = [result, idx];
class1 = find(labeledResult(:,3)<=10); %S
class1 = labeledResult(class1,1:2);
class2 = find((labeledResult(:,3)>10) & (labeledResult(:,3)<=20)); %V
class2 = labeledResult(class2,1:2);
class3 = find((labeledResult(:,3)>20) & (labeledResult(:,3)<=30)); %T
class3 = labeledResult(class3,1:2);
%}

scatter(class1(:,1),class1(:,2), '.c');
scatter(class2(:,1),class2(:,2), '.y');
scatter(class3(:,1),class3(:,2), '.m');

scatter(T(:,1),T(:,2),'g','+');
scatter(V(:,1),V(:,2),'b','+');
scatter(S(:,1),S(:,2),'r','+');

XT = [];
XS = [];
XV = [];

for file = files'
f = imread(file.name);
sname = strrep(file.name, '.GIF', '');
letter = sname(1);

if (letter == 'X') | (letter == 'A') | (letter == 'B')

z = fft2(double(f));
q = fftshift(z);
Magq = abs(q);

A = sum(Magq);
B = sum(Magq, 2);

x = 0;
cx = 201;
cy = 321;
for i = 100:522
    for j = 100:201
        if ((cx - j)^2 + (cy - i)^2 < 50^2) && (atand(abs((j-cx)/(i-cy))) < 80) && (atand(abs((j-cx)/(i-cy))) > 55);
            x = x + Magq(j, i);
        end
    end
end

y = 0;

for i = 320:322
    y = y + A(i);
end
for j = 200:202
    y = y + B(j);
end

idx = knnsearch(data,[y x]);

if (idx <= constraint1)
    %Reads in the letter as 'S'
    if letter == 'X'
        scatter(y, x, 'r', '*');
    elseif letter == 'A'
        scatter(y, x, 'r', 'd');
    elseif letter == 'B'
        scatter(y, x, 'r', 's');
    end
elseif ((idx > constraint1) & (idx <=constraint2))
    % Reads in the letter as 'V'
    if letter == 'X'
        scatter(y, x, 'b', '*');
    elseif letter == 'A'
        scatter(y, x, 'b', 'd');
    elseif letter == 'B'
        scatter(y, x, 'b', 's');
    end
elseif ((idx > constraint2) & (idx <= constraint3))
    % Reads in the letter as 'T'
    if letter == 'X'
        scatter(y, x, 'g', '*');
    elseif letter == 'A'
        scatter(y, x, 'g', 'd');
    elseif letter == 'B'
        scatter(y, x, 'g', 's');
    end
end
hold all
end
end
