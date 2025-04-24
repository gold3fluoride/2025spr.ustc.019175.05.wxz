%0.2M acetic acid titrated with 0.01M sodium hydroxide
%0.1M acetic acid and 0.1M sodium acetate titrated with 0.01M sodium hydroxide
c=0.2;
Ka=1.76e-5;
Kw=1e-14;
nLowerLimit=0;
nUpperLimit=5;
pH=linspace (1,14,1e5);
H = 10.^-pH;

eqn = @(H) (Ka./(H +Ka)*c+1e-14./H- H-c/2)*25;   
HA_positive = fzero(eqn, [1e-14,1]); % 初始猜测区间
pHA = -log(HA_positive)./log(10);

eqn = @(H) (Ka./(H + Ka)*c + 1e-14./H -H)*25;   
HB_positive = fzero(eqn, [1e-14,1]); % 初始猜测区间
pHB = -log(HB_positive)./log(10);

HAe=10.^-(pHA+1);
nAe=(Ka./(HAe +Ka)*c+1e-14./HAe- HAe-c/2)*25;
HBe=10.^-(pHB+1);
nBe=(Ka./(HBe + Ka)*c + 1e-14./HBe -HBe)*25;
display(nAe);
display(nBe);

nA= (Ka./(H +Ka)*c+1e-14./H- H-c/2)*25;
FilA = find((nA>nLowerLimit)&(nA<nUpperLimit));

nB=(Ka./(H + Ka)*c + 1e-14./H -H)*25;
FilB = find((nB>nLowerLimit)&(nB<nUpperLimit));

figure;pA=plot(nA(FilA),pH(FilA));
hold on;
pB=plot(nB(FilB),pH(FilB));
hold on;

yline(pHA+1,"k--");yline(pHB+1,"k--");
hold on;
%title('比较体系A与体系B的“缓冲容量”');
plot(nAe,pHA+1,"ko",'MarkerSize', 5, 'MarkerFaceColor', 'y');hold on;
text(nAe,pHA+1,...
        sprintf('(%.4f, %.2f)', nAe, pHA+1))
plot(nBe,pHB+1,"ko", 'MarkerSize', 5, 'MarkerFaceColor', 'y');hold on;
text(nBe,pHB+1,...
        sprintf('(%.4f, %.2f)', nBe, pHB+1))
text(0.2,13,sprintf('c=%.2f \nKa=%.2e',c,Ka));
hold off;
xlabel('n/mmol');
ylabel('pH');
legend([pA, pB], {'缓冲体系', '酸体系'},"Location","best","Box","off");





