function updatedFFTLMS(originalWav, receivedWav)
[x0, fs0] = audioread(originalWav);
X=x0(:,1);
[y0, fs1] = audioread(receivedWav);
Y=y0(:,1);

%Compare two audio, get the same lengh of time
samples_X = length(X);
time_X = samples_X/fs0;
sampleDuration_X = 1/fs0; 

samples_Y = length(Y);
time_Y = samples_Y/fs1;
sampleDuration_Y = 1/fs1; 

% mse_location = 64720;% for t1_1m_0in
% location_end = 64720+samples_X-1;
% YY_new = Y(mse_location:location_end);
% Y_new=Y(differentSamples+1:end);
% samples_New_Y = length(YY_new);

if samples_New_Y~=samples_X
    error('Oop! MAKE sure two audio have same length');
end

if sampleDuration_X~=sampleDuration_Y
    error('Oop! MAKE sure two audio have same FS');
end

windowDuration = 2;
windowLength = windowDuration*fs0;
hopSize = fs0;

%vectors to store
original = [];
received = [];

endingPoint = samples_X-windowLength;
%endingPoint = floor((samples_X-windowLength)/hopSize)+1;

for i=1:hopSize:endingPoint
    originalWindow = X(i:i+windowLength-1);

    originalFFT = fft(originalWindow); 
    n = length(originalFFT);
    fshift = (0:n/2-1)*(fs0/n); % frequency range from 0 to Nyquist frequency
    powershift = abs(originalFFT(1:n/2)).^2/n; % power for positive frequencies only
    % plot(fshift,powershift)
    
    % Store only the first half of high-frequency data
    cut_index = ceil(length(powershift)/4);
    original = [original; ifft(powershift(1:cut_index))]; 
  
end

% received 
endingPoint = samples_New_Y-windowLength;
for i=1:hopSize:endingPoint
    receivedWindow = YY_new(i:i+windowLength-1);

    receivedFFT = fft(receivedWindow); 
    n_y = length(receivedFFT);
    fshift_Y = (0:n_y/2-1)*(fs1/n_y); % frequency range from 0 to Nyquist frequency
    powershift_Y = abs(receivedFFT(1:n_y/2)).^2/n_y; % power for positive frequencies only
    % plot(fshift_Y,powershift_Y)
    
    % Store only the first half of high-frequency data
    cut_index = ceil(length(powershift_Y)/4);
    received = [received; ifft(powershift(1:cut_index))]; 
  
end


if length(original)~=length(received)
    error('Oop! Check the length of new data!');
end

%X_new = real(original);
%Y_new = real(received);

%audiowrite('cut_Orig.wav', X_new, fs0);
%audiowrite('cut_1m_0in.wav', Y_new, fs1);
X_new = abs(original);
Y_new = abs(received);

m = 5;
n = m*2;

W = zeros(size(original));
predict_Y = zeros(size(received));
error = zeros(size(received));
YY = zeros(size(received));
error_W = zeros(n,1);
W_updated = zeros(n,1);

WW= W(1:n);% 1-64
WW_F = fft(WW); % zeros here
N = length(received)-m;
XX = zeros(m,n);
for i=m+1:m:N
    for j=1:m
        for k=1:n
            XX(j,k)=X(j+k-1);
        end
    end
    %matrix_X = reshape(X_new, [32, 64]);
    XX_W =fft(X_new(i-m:(i+(m-1))));% 1-64
    XX_F = fft(XX);
    YY = Y_new(i-m:(i+m));
    YY_F = fft(YY);
   
    predict = XX_F*WW_F;
    %precdict_second = predict(33:64);
    predict_Y(i:(i+(m-1)))=predict; % store the second 32 
    error_re = YY_F((m+1):n)- predict;
    error(i:(i+(m-1))) = ifft(error_re); 
    %disp(['EE(', num2str(i), ':', num2str(i + (m-1)), ') = ', num2str(error(i:(i+(m-1)))')]);
    error_W((m+1):n) =ifft(error_re);
    error_F = fft(error_W);
    W_updated = WW_F +10*error_F.*XX_W;
    W_Second = W_updated(1:m);
    WW_F(1:m)=W_Second;
    W(i:(i+(m-1)))= ifft(W_Second);
    
    %disp(['W(', num2str(i), ':', num2str(i + (m-1)), ') = ', num2str(W(i :(i+(m-1)))')]);
    % something wrong here, the result of updated w 
end

% Plotting
M = length(Y_new);
t = (0:M-1) / fs0; % Adjusted time vector starting from 0

figure;

subplot(3, 1, 1);
plot(t, Y_new, 'b', 'LineWidth', 1.5);
title('Original Signal (Y)');
xlabel('Time (seconds)');
ylabel('Amplitude');

hold on;

subplot(3, 1, 2);
plot(t, predict_Y(1:M), 'r', 'LineWidth', 1.5);
title('Predicted Signal (predict\_Y)');
xlabel('Time (seconds)');
ylabel('Amplitude');

subplot(3, 1, 3);
plot(t, error, 'g', 'LineWidth', 1.5);
title('Error Signal');
xlabel('Time (seconds)');
ylabel('Amplitude');

hold off;
%{
% Plotting
M= length(Y_new);
E = length(error);
YYY = length(YY);
t = (0:M-1) / fs0; % Adjusted time vector starting from 0

figure;

subplot(3, 1, 1);
plot(t(1:M), Y_new, 'b', 'LineWidth', 1.5);
title('Original Signal (Y)');
xlabel('Time (seconds)');
ylabel('Amplitude');

hold on;

subplot(3, 1, 2);
plot(t(1:M), YY(1:M), 'r', 'LineWidth', 1.5);
title('Predicted Signal (predict\_Y)');
xlabel('Time (seconds)');
ylabel('Amplitude');

subplot(3, 1, 3);
plot(t(1:M), error, 'g', 'LineWidth', 1.5);
title('Error Signal');
xlabel('Time (seconds)');
ylabel('Amplitude');

hold off;
%}
end

 

 %{
    [maxval_X,idx_X] = max(magxF_X);

    store = magxF_X(mid_X:idx_X);
   
    plot(store);
    title('Modified Magnitude Spectrum_X');
    a = ifft(ifftshift(maxval_X));
    %original(i:i+windowLength-1) = ifft(ifftshift(magxF_X));

    receivedFFT = fft(receivedWindow);
    magxF_Y=abs(fftshift(receivedFFT)); 
    plot(magxF_Y);
    mid_Y = ceil(length(magxF_Y) / 2);
    [maxval_Y,idx_Y] = max(magxF_Y);
    magxF_Y(1:idx_Y) = 0; % zero out the lower part
    plot(magxF_Y);
    title('Modified Magnitude Spectrum_Y');
    received(i:i+windowLength-1) = ifft(ifftshift(magxF_Y));
     %}

%receivedWindow = Y_new(i:i+windowLength-1);
% Plot the originalFFT
 %{  
    figure;
    subplot(2,1,1);
    plot(abs(original));
    title('Original Signal');
    
    % Plot the receivedFFT
    subplot(2,1,2);
    plot(abs(received));
    title('Received Signal');
%}   

% Write original and received vectors to audio files
% audiowrite('original_3.27.wav', real(original), fs0);
% audiowrite('received_3.27.wav', real(received), fs0);

