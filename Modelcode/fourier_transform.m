%% fast fourier transform function
function [freq,power] = fourier_transform(x)
y = fft(x); % fast fourier transform
y(1) = [];
n = length(y);
power = abs(y(1:floor(n/2))).^2; % power of first half of transform data
maxfreq = 1/2;                   % maximum frequency
freq = (1:n/2)/(n/2)*maxfreq;    % equally spaced frequency grid
end