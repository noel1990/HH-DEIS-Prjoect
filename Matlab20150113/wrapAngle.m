function result = wrapAngle(angle)
    if angle>180
        while angle>180
            angle = angle-360;
        end
    end
    if angle<-180
        while angle<-180
            angle = angle+360;
        end
    end
    result = angle;
end
