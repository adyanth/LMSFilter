clc;
close all;
secs=input('Enter number of seconds to record (0 to use previous value) : ');
if secs>0
    % desired output
    rec=audiorecorder;
    input('Press enter to record audio.');
    recordblocking(rec,secs);
    d=getaudiodata(rec)';

    % Surrounding / Ambient noise
    input('Press enter to record noise.');
    recordblocking(rec,secs);
    x=getaudiodata(rec)';
    lf=0.03
else
    d = [0 heaviside(1:998) 0];
    x = [zeros(1,200) sin(1:600) zeros(1,200)];
    final_output = 0;
    lf=0.01
end

% learning rate
% filter taps
tap=60;
%Graph max and min y axis
ymax=3;
ymin=-1;

% Sets the length to the smaller number of samples
if (length(d) < length(x))
 len = length(d);
else
 len = length(x);
end

% initialize coefficients to 0, and buffers to 0
W = zeros(tap,1);
buffer_input = [zeros(tap,1)];
buffer_desire = [zeros(tap,1)];
% Run through for each sample available
for t = 1:len

 % Add the new values to the end of the buffers
 buffer_input = [buffer_input(2:tap);(x(t) - d(t))];
 buffer_desire = [buffer_desire(2:tap);(-(x(t) - d(t)))];
 
 % Calculate output and error
 output = W'*buffer_input;
 e = buffer_desire(tap) - output;

 % Update coefficients
 W = W + lf*buffer_input*conj(e);

 % Final output is just current outputs
 final_output(t) = output;
end 

subplot(3,2,1)
plot(d)
title('Desired Signal')
ylim([ymin ymax])
subplot(3,2,2)
plot(x)
title('Ambient Noise')
ylim([ymin ymax])
subplot(3,2,3)
plot(real(final_output))
title('Output from the filter')
ylim([ymin ymax])
subplot(3,2,4)
plot(d+x)
title('Output combined with noise without filter')
ylim([ymin ymax])
subplot(3,1,3)
plot(real(final_output)+x)
title('Output of filter combined with noise')
ylim([ymin ymax])

input('Press enter to play input to filter.');
soundsc(x+d);
input('Press enter to play output from filter.');
soundsc(x+final_output);