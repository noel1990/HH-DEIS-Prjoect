position_list = [];
P = getNextPos(1);
position_list(end+1,:) = [P(1) P(2) 0];
TargetX = P(1);
TargetY = P(2);
TargetA = 0;

if ~isempty(instrfind)
    fclose(instrfind);
end