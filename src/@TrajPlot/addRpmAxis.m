function [] = addRpmAxis(obj)
axes(obj.aSp)
yyaxis left
limits = obj.aSp.YLim;
axes(obj.aSp)
yyaxis right
ylim(limits./360.*60) %/s -> rpm
ylabel('$\dot{\theta} \, [rpm]$')
set(gca,'YColor','k');

end

