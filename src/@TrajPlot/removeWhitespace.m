function [] = removeWhitespace(obj)
ax=obj.aTr;
ax.OuterPosition = [0 0.75 1 0.25];
outerpos = ax.OuterPosition;
pos = ax.Position;
ti = ax.TightInset;
left = pos(1);
bottom = outerpos(2) + ti(2);
ax_width = pos(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

ax=obj.aSp;
ax.OuterPosition = [0 0.5 1 0.25];
outerpos = ax.OuterPosition;
pos = ax.Position;
ti = ax.TightInset;
left = pos(1);
bottom = outerpos(2) + ti(2);
ax_width = pos(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

ax=obj.aAc;
ax.OuterPosition = [0 0.25 1 0.25];
outerpos = ax.OuterPosition;
pos = ax.Position;
ti = ax.TightInset;
left = pos(1);
bottom = outerpos(2) + ti(2);
ax_width = pos(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

ax=obj.aTm;
ax.OuterPosition = [0 0 1 0.25];
outerpos = ax.OuterPosition;
pos = ax.Position;
ti = ax.TightInset;
left = pos(1);
bottom = outerpos(2) + ti(2);
ax_width = pos(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
end

