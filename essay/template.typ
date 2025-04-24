#import "format.typ": *
#set text(lang: "zh", region: "cn")
#show: project.with(
  lab_name: "对单一酸水溶液体系作为缓冲溶液的研究",
  sub_name:"
  ——分析化学第一次大作业",
  stu_name: "王歆喆",
  stu_num: "PB24000073",
  department: "少年班学院",
  teach:"邵利民",
  date: (2025, 4, 15),
  show_content: false,
  show_content_figure: false,
)

#head[摘要]
本文简要分析了共轭酸碱对作为缓冲体系和单一弱酸不能作为缓冲溶液的理论依据，并提出同浓度共轭酸碱对比单一弱酸抵抗外来强碱能力更强的猜想。进而通过计算机计算，根据观察到的事实修正这一猜想，探究溶液缓冲容量的影响因素。最终得出结论：酸性越强的弱酸溶液的缓冲能力越强，甚至可以超过共轭酸碱对的缓冲能力。

#head(level: 2)[关键词]

缓冲溶液；缓冲容量；数值计算

= 理论论证

在只有一种弱酸的水溶液体系中，存在平衡：

$ "HA"  ⇌ "A"^- +"H"^+ $

外加的碱消耗氢离子从而改变pH值，总反应为：

$ "HA" + "OH"^-  ⇌ "A"^- +"H"_2"O" $

在弱酸体系中该反应大量发生，对pH影响巨大。而在缓冲溶液体系中，大量 $"A"^-$的存在，由于化学平衡中的勒夏特列原理阻止了该反应的大量发生，即减少了外来碱对氢离子的消耗量，从而在外来碱较少时将pH维持在一个相对稳定的水平。因此共轭酸碱对溶液可以作为缓冲溶液，其中共轭碱主要起到了抑制平衡右移改变原来pH的作用；而弱酸没有这种作用。

因此我们做出符合直觉的预期，对于一个弱酸，单一酸体系的缓冲能力不如共轭酸碱对溶液的缓冲能力。

= 通过计算验证

以上理论推演得出的预期可能忽略了部分因素，因此需要利用计算来验证。

类比缓冲溶液中缓冲容量的定义，定义使一个体系pH增大1的强碱的物质的量为“缓冲容量”。
（以下除非特殊说明，酸均指弱酸）

为客观比较缓冲能力，应当保持弱酸的总分析浓度相等，本文设计两个体积为25mL的水溶液体系A和B，其中体系A含有 $c "mol/L"$的酸，体系B含有$c/2"mol/L"$的酸和$c/2"mol/L"$的共轭碱，则由CBE可以列出外来强碱物质的量$n$与$["H"]^+$的关系，从而绘制 $n"-pH"$的图像。（参考课本附录6程序6.1）@AC

以下是示例MATLAB代码（设定$c=0.2"mol/L"$和$K_"a"=1.8 times 10^(-5) $）相应代码已上传至
#link("https://github.com/gold3fluoride/2025spr.ustc.019175.05.wxz/blob/main/trial0329_0.m","GitHub gold3fluoride的仓库")。
```MATLAB 
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
```
#figure(
  image("0.2acetic.png",width:80%),
  caption: [同浓度（0.2mol/L）乙酸/乙酸钠缓冲溶液和乙酸溶液 $n"-pH"图$],
)<0.2acetic>

如@fig:0.2acetic 所示，酸碱缓冲体系的缓冲容量为2.0456mmol，而单一酸体系的“缓冲容量”为0.4260mmol。可见缓冲体系的缓冲容量更大，符合预期。
= 对该结论普适性的探究
为验证该规律是否具有普适性，更改相关参数进行试验。
== 更换酸的浓度（以醋酸为例）
#figure(
  image("0.05acetic.png",width:60%),
  caption: [同浓度（0.05mol/L）乙酸/乙酸钠缓冲溶液和乙酸溶液 $n"-pH"图$],
)<0.05acetic>
#figure(
  image("0.1acetic.png",width:60%),
  caption: [同浓度（0.1mol/L）乙酸/乙酸钠缓冲溶液和乙酸溶液 $n"-pH"图$],
)<0.1acetic>
#figure(
  image("0.15acetic.png",width:60%),
  caption: [同浓度（0.15mol/L）乙酸/乙酸钠缓冲溶液和乙酸溶液 $n"-pH"图$],
)<0.15acetic>
#figure(
  image("0.25acetic.png",width:60%),
  caption: [同浓度（0.25mol/L）乙酸/乙酸钠缓冲溶液和乙酸溶液 $n"-pH"图$],
)<0.25acetic>
#figure(
  image("0.3 acetic.png",width:60%),
  caption: [同浓度（0.3mol/L）乙酸/乙酸钠缓冲溶液和乙酸溶液 $n"-pH"图$],
)<0.3acetic>
均符合预期，且随着浓度上升，缓冲容量之差也增加，是因为较浓的溶液对抵抗外界变化能力更强。
== 更改酸的种类
#figure(
  image("0.2hydrofluoro.png",width:60%),
  caption: [同浓度（0.2mol/L）氢氟酸/氟化钠缓冲溶液和氢氟酸溶液 $n"-pH"图$],
)<0.2fluoro>
#figure(
  image("0.2formic.png",width:60%),
  caption: [同浓度（0.2mol/L）甲酸/甲酸钠缓冲溶液和甲酸溶液 $n"-pH"图$],
)<0.2formic>

#figure(
  image("0.2para-nitrophenol.png",width:60%),
  caption: [同浓度（0.2mol/L）对硝基苯酚/对硝基苯酚钠缓冲溶液和对硝基苯酚溶液 $n"-pH"图$],
)<0.2pnphen>

#figure(
  image("0.2hypochloro.png",width:60%),
  caption: [同浓度（0.2mol/L）次氯酸/次氯酸钠缓冲溶液和次氯酸溶液 $n"-pH"图$],
)<0.2hypocl>

@fig:0.2fluoro 到 @fig:0.2hypocl 与 @fig:0.2acetic 展现了同样的规律，即单一酸体系的缓冲容量比缓冲体系的缓冲容量小对于许多弱酸是成立的。并且可以看出随着酸性减弱（即$K_a $减小），两个缓冲容量间的差值越来越大。这也是符合预期的，因为酸性较弱的酸对外来碱的抵抗能力肯定不如更强的酸，而由缓冲溶液pH的近似公式@AC,缓冲溶液的缓冲容量差异不大。因此该差值随着酸性增强而减小。对于这些酸，较高浓度的酸并不能提供比共轭酸碱对好的缓冲能力。

然而在实验中注意到，对于一氯乙酸，如@fig:0.2monocl 所示，两个缓冲容量是相当的，甚至酸的缓冲能力更强。
#figure(
  image("0.2monochloroace.png",width:60%),
  caption: [同浓度（0.2mol/L）一氯乙酸/一氯乙酸钠缓冲溶液和一氯乙酸溶液 $n"-pH"图$],
)<0.2monocl>

猜想是一氯乙酸酸性较强导致的结果。

固定$c=0.2"mol/L"$,使用python编写程序绘制A体系和B体系缓冲容量之差与 $"p"K_"a"$的函数关系。代码已上传至
#link("https://github.com/gold3fluoride/2025spr.ustc.019175.05.wxz/blob/main/analchem.py","GitHub gold3fluoride的仓库")。


运行结果如@fig:pkaz 所示
#figure(
  image("pkaz.png",width:90%),
  caption: [在 $c=0.2 "mol/L"$情况下，体系A与体系B缓冲容量之差$z$与$"p"K_"a"$的函数关系],
)<pkaz>
由@fig:pkaz 所示，酸性越强，缓冲能力越强。

利用Python解得，当 $"p"K_"a"$小于3.02(称为$c=0.2"mol/L"$时的“临界”$"p"K_"a"$)时，体系B的缓冲容量比体系A的缓冲容量大，即单一酸的缓冲能力比共轭酸碱对能力强。分析可知是因为这些酸酸性较强，可以视作“强酸”，而已知强酸浓度越大越能够抵御外来碱导致的pH变化。在这些较强的酸组成的体系中，这一点占据主导地位，导致结果和最初分析不一致。

由于 $"p"K_"a"<3.02$不是很苛刻的条件，有许多酸可以实现这一点，如@fig:0.2dicl 中的二氯乙酸和 @fig:0.2tricl 中的三氯乙酸。

#figure(
  image("0.2dichloroace.png",width:60%),
  caption: [同浓度（0.2mol/L）二氯乙酸/二氯乙酸钠缓冲溶液和二氯乙酸溶液 $n"-pH"图$],
)<0.2dicl>
#figure(
  image("0.2trichloroace.png",width:60%),
  caption: [同浓度（0.2mol/L）三氯乙酸/三氯乙酸钠缓冲溶液和三氯乙酸溶液 $n"-pH"图$],
)<0.2tricl>

不过考虑到一般缓冲溶液要求的pH很少达到3以下，可以认为以上讨论的这种情况在现实中不常见。

== c与“临界”$"p"K_"a"$

为研究多强的酸可以有超出共轭酸碱对的缓冲容量，称使上述体系A和B缓冲容量相等的弱酸$"p"K_"a"$为“临界”$"p"K_"a"$，显然“临界”$"p"K_"a"$与$c$有关。利用python绘制c与“临界”$"p"K_"a"$的函数曲线（声明：借助AI）。代码上传至
#link("https://github.com/gold3fluoride/2025spr.ustc.019175.05.wxz/blob/main/analchem2.py","GitHub gold3fluoride的仓库")。
运行结果为：

#figure(
  image("pkac.png",width:90%),
  caption: [c与“临界”$"p"K_"a"$关系图],
)<pkac>

可见溶液越浓，“临界”$"p"K_"a"$越小，所需的酸越强。则对于大部分高浓度的缓冲溶液及其酸溶液（$"p"K_"a">2$）不会出现酸体系缓冲容量大的情况。

= 结论
本文通过理论讨论和数值计算分析单一弱酸体系和共轭酸碱对体系的缓冲容量，得出结论：在总浓度一定的情况下，若该弱酸的酸性相对较强（$c=0.2"mol/L"$时，$"p"K_"a">3.02$），则高浓度弱酸的缓冲能力较强，强于对应的共轭酸碱对溶液；否则单一弱酸的缓冲能力较差，不如共轭酸碱对的缓冲能力。

本文还有不足：为了简化问题，本文主要讨论一元酸，实际应用中的部分缓冲溶液（如碳酸、磷酸）是多元酸。此外，在3.2节和3.3节中没有研究$c$与$z$,$c$与“临界”$"p"K_"a"$的具体函数表达。


#pagebreak()

#bibliography("works.bib", title: [参考文献])
#hide[
  @AC
]

#head(level: 1)[致谢]
感谢邵老师提出的这个问题让我对这个问题的观点发生了变化。第一次写小论文，#underline[格式内容难免有错误或者表达不准确之处，还请老师指出]。

感谢Deepseek生成3.2节代码框架。