clc;
clear all;
close all;

imageName = 'house.bmp';


Img = imread(imageName); %Your Image goes here

if size(Img,3) > 1
    Img = rgb2gray(Img);
end


N = numel(Img);

[row, col] = size(Img);

row = int2str(row);
col = int2str(col);

imageSize = [row 'x' col];

%*******************************Kernels for deblurring********************
K = fspecial('gaussian', [7 7], 5); % Gaussian Blur
%K     =   fspecial('average',9); % Average Blur
                                     
                                     


%K     =   fspecial('average',1); % For denoising
f = imfilter(Img,K,'circular');


%************ Add Impulse noise  ***********
f  = impulsenoise(f,0.3,0);
f  = double(f);
% *************************************************

%*************Parameters*********************

opts.lam       = 120; % Play around with lambda values,
opts.omega     =1.2;  % and with the omega to smoothen out left over artifacts
opts.grpSz     = 3; % OGS group size
opts.Nit       = 400;
opts.Nit_inner = 5;
opts.tol       = 1e-4;
opts.p         = 0.9;
opts.p_r       = 0.5;


out = HNHOTV_OGS_Impulse(f, double(Img), K, opts);


%Show results

figure;
imshow(uint8(Img));
title('Original');

figure;
imshow(f,[]);
title(sprintf('Noisy(PSNR = %3.3f dB,SSIM = %3.3f, SNR = %3.3f) ',...
                       psnr_fun(f,double(Img)),ssim_index(f,double(Img)),snr_fun(f,double(Img))));

figure;
imshow(out.sol,[])
title(sprintf('HNHOTV-OGS Deblurred (PSNR = %3.3f dB,SSIM = %3.3f, SNR = %3.3f ) ',...
                       psnr_fun(out.sol,double(Img)),ssim_index(out.sol,double(Img)),snr_fun(out.sol,double(Img)) ));
                   


%%%%%%%%%%%%% Plot convergence of relative Error %%%%%%%%%%%%%%%%%                   
figure;
semilogy(out.relativeError,'Linewidth',3.0,'Color','black');
xlabel('Iterations (k)','FontSize',25,'interpreter','latex');
ylabel('Relative Error','FontSize',25,'interpreter','latex');
axis tight;
grid on;
l = legend('HNHOTV-OGS');
set(l,'interpreter','latex','FontSize', 25);
set(gca, 'FontSize',20)
                   
                   
