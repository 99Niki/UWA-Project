function LMSTimeAdp(originalWav,receivedWav,backgroundWav)
[x0, fs0] = audioread(originalWav);
X=x0(5:1129366,1);
[y0, fs1] = audioread(receivedWav);
Y=y0(5:1129366,1);
[B0, fs0] = audioread(backgroundWav);
B=B0(5:1129366,1);

m=2;% #of taps
H=zeros(length(Y),1);
%slove the first 50th H
for i = 1:m:50
    for j=1:m
        XX(j, :) = X(i+j-1:i+j-1+m-1); % Extract appropriate segment of X
    end
    YY = Y((i+m-1):(i+m-1+m-1));
    HH = inv(XX)*YY;
    H((i+m-1):(i+m-1+m-1))=HH;
end

predict_Y = zeros(length(Y),1);
error = zeros(length(Y),1);
for i=1:m:50
    for j=1:m
        XX_M(j, :) = X(i+j-1:i+j-1+m-1); % Extract appropriate segment of X
    end
    HH_V = H(i+1:(i+m));
    predict_V = XX_M*HH_V;
    predict_Y(i+1:(i+m))=predict_V;   
    %calculate error
    Error_V = Y(i+1:(i+m))-predict_Y(i+1:(i+m));
    error(i+1:(i+m))= Error_V;
 
end
%error = Y2(2:(length(Y1)-2))-predict_Y(2:(length(Y1)-2)); % get the errors
ending = length(Y)-2;
mu=0.5;
% adapt the rest
for i=50:m:ending
        %[x50,x51;x51,x52]
    for j=1:m
        XX_MR(j, :) = X(i+j-1:i+j); % Extract appropriate segment of X
    end
    HH_VR = H(i-m:i-m+1); %[H50;H51]
    predict_V = XX_MR*HH_VR;
    predict_Y(i+1:(i+m))=predict_V; % [Y51;Y52]
    Error_V = Y(i+1:(i+m))-predict_Y(i+1:(i+m));
    error(i+1:(i+m))= Error_V; %[E51;E52]

    X_V=X(i+1:i+m);%[X51;X52]
    H_updated = HH_VR+mu.*Error_V.*X_V;

    H(i+m:i+m+1)= H_updated; %[H52;H53]
    
end
avgAbsValue = mean(error.^2);

Noise = abs(error-B);
fprintf("The average of error is %f \n",avgAbsValue);

% Write predict_Y and error as audio files
audiowrite('predict_YY(t1_10m_0.5m_30cm.wav).wav', predict_Y, fs1);
%audiowrite('Signal_Y_10m_1m_30cm.wav', Signal, fs1);
audiowrite('error(withoutBgt1_10m_0.5m_30cm.wav).wav', Noise, fs1);

% Plot X, predict_Y, and error
figure;
    subplot(3, 1, 1);
    plot(Y);
    title('Original Received Signal (Y)');

    subplot(3, 1, 2);
    plot(predict_Y);
    title('Predicted Received Signal (predict\_Y)');

    subplot(3, 1, 3);
    plot(error);
    title('Error Signal');
    xlabel('Sample Number');
end





