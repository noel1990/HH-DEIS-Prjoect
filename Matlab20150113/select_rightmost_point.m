function P_rightmost = select_rightmost_point(P,a)
    if a>-135&&a<=-45    % take the one has minimum x
        [A,IX] = min(P);
        P_rightmost = P(IX(1),:);
    elseif a>-45&&a<=45  % take the one has minimum y
        [A,IX] = min(P);
        P_rightmost = P(IX(2),:);
    elseif a>45&&a<=135  % take the one has maximum x
        [A,IX] = max(P);
        P_rightmost = P(IX(1),:);
    else                 % take the one has maximum y
        [A,IX] = max(P);
        P_rightmost = P(IX(2),:);
    end
end