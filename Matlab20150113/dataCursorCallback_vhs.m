function output_txt = dataCursorCallback(obj,event_obj)
% Display the position of the data cursor, and the RGB data to 6 decimal places.

pos = get(event_obj,'Position');
output_txt = {['X: ',num2str(pos(1),4), ' ',...
    'Y: ',num2str(pos(2),4)]};

h = get(event_obj,'target');
cdata = get (h, 'CData');
cmap = colormap;
hsv= rgb2hsv(cdata(pos(2),pos(1),:));
%output_txt{end+1} = ['VHS: ' num2str(hsv(3),'%.4f') ', '  num2str(mod(hsv(1),2*pi)*180/pi,' %.1f') ', '  num2str(hsv(2),'%.4f')];
output_txt{end+1} = ['V: ' num2str(hsv(3),'%.3f') ' H: '   num2str(hsv(1)*2*pi,' %.3f')];
