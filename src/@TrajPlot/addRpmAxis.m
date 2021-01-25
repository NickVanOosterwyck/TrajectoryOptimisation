function [] = addRpmAxis(obj)
limits = obj.aSp.Ylim;
yyaxis right
YLim(limits./360.*60) %/s -> rpm

end

