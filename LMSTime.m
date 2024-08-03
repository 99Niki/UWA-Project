function LMSTime(originalWav, receivedWav)
[x0, fs0] = audioread(originalWav);
X1=x0(:,1);
X = X1(4:end);
[y0, fs1] = audioread(receivedWav);
Y1=y0(:,1);
Y = Y1(4:end);
%[B0, fsb] = audioread(backgroundWav);
%B=B0(:,1);

%Signal = Y-B; 

if length(Y)~=length(X)
    error('Oop! MAKE sure two audio have same length');
end

if fs0~=fs1
    error('Oop! MAKE sure two audio have same FS');
end

m = 1;
n = m*2;

W = zeros(length(X),1);
predict_Y = zeros(length(Y),1);
error = zeros(length(Y),1);
error_V = zeros(n,1);
%error_V = zeros(m,1);
W_updated = zeros(n,1);
X_V = zeros(m,1);
WW_V= zeros(n,1);% w vector

%N = length(Y)-n;
N = length(Y)-564690;
XX = zeros(m,n);
EE = zeros(m,n);

for i=m+1:m:N
    for j=1:m
        if (i+j-1+n-1) <= length(X)
            XX(j, :) = X(i+j-1:i+j-1+n-1); % Extract appropriate segment of X
        else
            XX(j, :) = 0; % Handle case where indices are out of bounds
        end
        %XX(j,:) = X(i+j-1:i+j-1+n-1);
       % for k=1:n
       %     XX(j,k)=X(j+k-1);
        %end
    end
    predict_V = XX*WW_V;
    predict_Y(i-m:(i-1))=predict_V; % m+1-m, i-1
    %calculate error
   % Error_new = Y(i:(i+(m-1)))-predict_Y(i:i+(m-1));
    Error_new = Y(i-m:(i-1))-predict_Y(i-m:(i-1));
    %Error_new = Signal(i:(i+(m-1)))-predict_Y(i:i+(m-1));
    error(i-m:(i-1))= Error_new;% save the second half back to the error
    error_V(1:m) = Error_new;
    %disp(['EE(', num2str(i), ':', num2str(i + (m-1)), ') = ', num2str(error(i:(i+(m-1)))')]);

  % for l=1:n
    %    EE(l,l:end)= error_V(1:(n+1-l));
    %end
    X_V=X(i-m:i-1);
    W_updated = WW_V(1:m)+0.01*Error_new.*(X_V/(norm(X_V)));

    W(i:(i+(m-1)))= W_updated;% save  back to the error
    WW_V(m+1:2*m) = W_updated; % updated the W vector

    disp(['W(', num2str(i), ':', num2str(i + (m-1)), ') = ', num2str(W(i :(i+(m-1)))')]);
    % something wrong here, the result of updated w 
end

Left = length(Y)- N;
e = length(Y);
% use the first-half or w to get the second-half of predict_Y
for i=N+1:m:e
    for j=1:m
        if (i+j-1+n-1) <= length(X)
            XX(j, :) = X(i+j-1:i+j-1+n-1); % Extract appropriate segment of X
        else
            XX(j, :) = 0; % Handle case where indices are out of bounds
        end
        
    end
    WW_V = W(i-N:i-N+n-1);
    predict_V = XX*WW_V;
   % disp(predict_V);

    predict_Y(i:(i+(m-1)))=predict_V;
    %calculate error
    Error_new = Y(i:(i+(m-1)))-predict_Y(i:i+(m-1));
    error(i:(i+(m-1)))= Error_new;% save the second half back to the error
    error_V(1:m) = Error_new;
 
end

avgAbsValue = mean(error.^2);
fprintf("The average of error is %f \n",avgAbsValue);

% Write predict_Y and error as audio files
audiowrite('predict_Y_10m_1m_30cm.wav', predict_Y, fs1);
%audiowrite('Signal_Y_10m_1m_30cm.wav', Signal, fs1);
audiowrite('error_10m_1m_30cm.wav', error, fs1);

% Plot X, predict_Y, and error
figure;
subplot(3, 1, 1);
plot(Y);
%plot(Signal);
title('Original Recieved Signal (Y)');
subplot(3, 1, 2);
plot(predict_Y);
title('Predicted Recieved Signal (predict\_Y)');
subplot(3, 1, 3);
plot(error);
title('Error Signal');
xlabel('Sample Number');
end
