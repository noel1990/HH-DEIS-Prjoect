function boolean = OutSide(P,PIE_X_Coord)
    if nargin == 1
        x = P(1,1);
        y = P(1,2);
        boolean = 0;
        thre = -180;
        if(x < 0-thre || x > 3200+thre || y < 0-thre || y > 2400+thre)
            boolean = 1;
        end
    else
        x = P(1,1);
        y = P(1,2);
        boolean = 0;
        thre = -180;
        if(x < 0-thre || x > 3200+thre || y < 0-thre || y > 2400+thre)
            boolean = 1;
        else
            if (PIE_X_Coord < 1600)
                if (x > 1600+thre)
                    boolean = 1;
                end
                if x > 1300-180
                    if y>1000-180 && y<1400+180
                        boolean = 1;
                    end
                end
            else
                if (x < 1600-thre)
                    boolean = 1;
                end
                if x < 1900+180
                    if y>1000-180 && y<1400+180
                        boolean = 1;
                    end
                end
            end
        end
    end
end