function LMSTimeOne(originalWav,receivedWav,receivedWavTwo,background)
[x0, fs0] = audioread(originalWav);
%X=x0(:,1);
X=x0(5:1129366,1);
[y0, fs1] = audioread(receivedWav);
%Y1=y0(:,1);
Y1=y0(5:1129366,1);
[y20, fs2] = audioread(receivedWavTwo);
Y2=y20(5:1129366,1);
%Y=B0(:,1);
[b0, fsb] = audioread(background);
B=b0(5:1129366,1);


if length(Y2)~=length(X)
    error('Oop! MAKE sure two audio have same length');
end

if fs0~=fs1
    error('Oop! MAKE sure two audio have same FS');
end

%slove the H from receivedWav
H = zeros(length(Y1),1);

m=2;% #of taps

endingPoint = length(Y1)-2*m;
for i = 1:m:endingPoint
    for j=1:m
        XX(j, :) = X(i+j-1:i+j-1+m-1); % Extract appropriate segment of X
    end
    YY = Y1((i+m-1):(i+m-1+m-1));
    %XX_I =inv(XX);
    %I = XX_I*XX;
    HH = inv(XX)*YY;% inv(XX)
    %P_Y= XX*HH;
    H((i+m-1):(i+m-1+m-1))=HH;
end

predict_Y = zeros(length(Y2),1);
%error = zeros(length(Y)-1,1);
sum=0;
for i=1:m:endingPoint
    for j=1:m
        XX_M(j, :) = X(i+j-1:i+j-1+m-1); % Extract appropriate segment of X
    end
    HH_V = H(i+1:(i+m));
    predict_V = XX_M*HH_V;
    predict_Y(i+1:(i+m))=predict_V;
   
    %calculate error
    %Error_new = Y(i:(i+(m-1)))-predict_Y(i:i+(m-1));
    %error(i:(i+(m-1)))= Error_new;% save the second half back to the error
 
end
error = Y2(2:(length(Y1)-2))-predict_Y(2:(length(Y1)-2)); % get the errors
sum=0;
ending= length(error);
for i=1:1:ending
    E = error(i)*error(i);
    sum = sum+E;
end
fprintf("The sum is %f \n",sum);
avgAbsValue = sum/ending;
e  = error.^2;
Realerror = abs(error-B(2:(length(B)-2)));

%avgAbsValue = sum(error.^2)/length(error);
avgAbsValue_Nobg = mean(Realerror.^2);

fprintf("The average of error is %f \n",avgAbsValue_Nobg);

% Write predict_Y and error as audio files
audiowrite('predict_Y(t1_10m_0.5m_30cm.wav).wav', predict_Y, fs1);
%audiowrite('Signal_Y_10m_1m_30cm.wav', Signal, fs1);
audiowrite('Realerror(WithoutBg_t1_10m_0.5m_30cm.wav).wav', Realerror, fs1);

% Plot X, predict_Y, and error
figure;
    subplot(3, 1, 1);
    plot(Y1);
    title('Original Received Signal (Y)');

    subplot(3, 1, 2);
    plot(predict_Y);
    title('Predicted Received Signal (predict\_Y)');

    subplot(3, 1, 3);
    plot(ending);
    title('Error Signal');
    xlabel('Sample Number');

    figure;
    plot(error);
    title('Error Signal');
    xlabel('Sample Number');
    ylabel('Amplitude');

    % Plot Realerror
    figure;
    plot(Realerror);
    title('Real Error Signal (Without Background)');
    xlabel('Sample Number');
    ylabel('Amplitude');

end

