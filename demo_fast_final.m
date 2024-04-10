clc;
clear all;
close all;

warning('off','all');

tic;
%image = double(imread('03_outdoor_hazy.JPG'))/255;
%image = double(imread('05_outdoor_hazy.jpg'))/255;
%image = double(imread('08_outdoor_hazy.jpg'))/255;
%image = double(imread('21_outdoor_hazy.JPG'))/255;
%image = double(imread('24_outdoor_hazy.jpg'))/255;
image = double(imread('45_outdoor_hazy.jpg'))/255;

%image = double(imread('chengdu_22.png'))/255;
%image = double(imread('hangzhou_7.png'))/255;
%image = double(imread('hongkong_10.png'))/255;
%image = double(imread('nanchang_21.png'))/255;
%image = double(imread('tianjing_2.png'))/255;
%image = double(imread('wuhan_3.png'))/255;

%image = double(imread('01_hazy.png'))/255;
%image = double(imread('09_hazy.png'))/255;
%image = double(imread('18_hazy.png'))/255;
%image = double(imread('25_hazy.png'))/255;
%image = double(imread('45_hazy.png'))/255;
%image = double(imread('49_hazy.png'))/255;

image = imresize(image,[256 256]);
dark = get_dark_channel(image, 5);

G = toGrayscale(image);
%figure, imshow(G,[]);
%title('Grayscale Image');

% Convert into double format.
G=double(G);

%Filter Masks
Kblur=[1/9 1/9 1/9; 1/9 1/9 1/9; 1/9 1/9 1/9];
KGauss=[1/16 2/16 1/16; 2/16 4/16 2/16; 1/16 2/16 1/16];
KLap8=[1 1 1; 1 -8 1; 1 1 1];

% Convolve the image using Blur Filter
Iblur=conv2(G, Kblur, 'same');
% Display the image.
%figure, imshow(Iblur,[]);
%title('Output of Blur Filter');

% Convolve the image using Gaussian Filter
IGauss=conv2(Iblur, KGauss, 'same');
% Display the image.
%figure, imshow(IGauss,[]);
%title('Output of Gaussian Filter');

% Convolve the image using Laplacian Filter
ILap8=conv2(IGauss, KLap8, 'same');
% Display the image.
%figure, imshow(ILap8,[]);
%title('Output of Laplacian Filter');

%Element-wise addition
%ED = 0.52;
%EL = 0.48;

M1 = immultiply(dark, 0.65);
M2 = immultiply(ILap8, 0.35);
%M1 = double(M1);
%M2 = double(M2);
IDL = imadd(M1,M2);

%atm = get_atmosphere(image, dark);
atm = get_atmosphere(image, IDL);
tx = get_transmission_estimate(image, atm, 0.95, 5);
dcpoutput = dehaze_fast(image, 0.95, 5);

% Applying AGCWD
adpgamma = AGCWD(dcpoutput);

% Applying ACHME
adpcntr = ACHME(dcpoutput, 15);

% Applying WAAHE
wghadp = WAAHE(dcpoutput, 10, 0.5);

F1 = immultiply(adpgamma, 0.52);
F2 = immultiply(wghadp, 0.48);
Ifu = imfuse(F1,F2,'blend');

%Apply Two Dimensional Discrete Wavelet Transform
Red_achme=adpcntr(:,:,1);
Green_achme=adpcntr(:,:,2);
Blue_achme=adpcntr(:,:,3);
[LLr1,LHr1,HLr1,HHr1]=dwt2(Red_achme,'db2');
[LLg1,LHg1,HLg1,HHg1]=dwt2(Green_achme,'db2');
[LLb1,LHb1,HLb1,HHb1]=dwt2(Blue_achme,'db2');

Red_Ifu=Ifu(:,:,1);
Green_Ifu=Ifu(:,:,2);
Blue_Ifu=Ifu(:,:,3);
[LLr2,LHr2,HLr2,HHr2]=dwt2(Red_Ifu,'db2');
[LLg2,LHg2,HLg2,HHg2]=dwt2(Green_Ifu,'db2');
[LLb2,LHb2,HLb2,HHb2]=dwt2(Blue_Ifu,'db2');

%% Fusion Rules: Average Rule
%% Red Channel: LL sub-band
[k1,k2]=size(LLr1);

for i=1:k1
    for j=1:k2
        LLr3(i,j)=(LLr1(i,j)+LLr2(i,j))/2;
   end
end

%% Red Channel: LH, HL, HH sub-bands
for i=1:k1
    for j=1:k2
        LHr3(i,j)=(LHr1(i,j)+LHr2(i,j))/2;
        HLr3(i,j)=(HLr1(i,j)+HLr2(i,j))/2;
        HHr3(i,j)=(HHr1(i,j)+HHr2(i,j))/2;
    end
end

%% Green Channel: LL sub-band
for i=1:k1
    for j=1:k2
        LLg3(i,j)=(LLg1(i,j)+LLg2(i,j))/2;
   end
end

%% Green Channel: LH, HL, HH sub-bands
for i=1:k1
    for j=1:k2
        LHg3(i,j)=(LHg1(i,j)+LHg2(i,j))/2;
        HLg3(i,j)=(HLg1(i,j)+HLg2(i,j))/2;
        HHg3(i,j)=(HHr1(i,j)+HHg2(i,j))/2;
    end
end

%% Blue Channel: LL sub-band
for i=1:k1
    for j=1:k2
        LLb3(i,j)=(LLb1(i,j)+LLb2(i,j))/2;
   end
end
%% Blue Channel: LH, HL, HH sub-bands
for i=1:k1
    for j=1:k2
        LHb3(i,j)=(LHb1(i,j)+LHb2(i,j))/2;
        HLb3(i,j)=(HLb1(i,j)+HLb2(i,j))/2;
        HHb3(i,j)=(HHb1(i,j)+HHb2(i,j))/2;
    end
end

%% Inverse Wavelet Transform
First_Level_Decomposition(:,:,1)=idwt2(LLr3,LHr3,HLr3,HHr3,'db2',size(adpcntr));
First_Level_Decomposition(:,:,2)=idwt2(LLg3,LHg3,HLg3,HHg3,'db2',size(adpcntr));
First_Level_Decomposition(:,:,3)=idwt2(LLb3,LHb3,HLb3,HHb3,'db2',size(adpcntr));
wfus=uint8(First_Level_Decomposition);
%wfus = imlocalbrighten(wfus);
wfu = wfus;
% on Red channel
wfu(:,:,1)=histeq(wfu(:,:,1));
% on Green channel
wfu(:,:,2)=histeq(wfu(:,:,2));
% on Blue channel
wfu(:,:,3)=histeq(wfu(:,:,3));
%out_img = double(imsharpen(wfu))/255;
out_img = double(wfu)/255;
DE_Noise=Wiener_DWT_Filter(out_img,'db2',0.1,[5 5],[7 7]);
DE_Noise = imresize(DE_Noise,[256 256]);
toc;

%GTimage = double(imread('03_outdoor_GT.JPG'))/255;
%GTimage = double(imread('05_outdoor_GT.jpg'))/255;
%GTimage = double(imread('08_outdoor_GT.jpg'))/255;
%GTimage = double(imread('21_outdoor_GT.JPG'))/255;
%GTimage = double(imread('24_outdoor_GT.jpg'))/255;
%GTimage = double(imread('45_outdoor_GT.jpg'))/255;

%GTimage = double(imread('chengdu_clear.png'))/255;
%GTimage = double(imread('hangzhou_clear.png'))/255;
%GTimage = double(imread('hongkong_clear.png'))/255;
%GTimage = double(imread('nanchang_clear.png'))/255;
%GTimage = double(imread('tianjing_clear.png'))/255;
%GTimage = double(imread('wuhan_clear.png'))/255;

%GTimage = double(imread('01_GT.png'))/255;
GTimage = double(imread('09_GT.png'))/255;
%GTimage = double(imread('18_GT.png'))/255;
%GTimage = double(imread('25_GT.png'))/255;
%GTimage = double(imread('45_GT.png'))/255;
%GTimage = double(imread('49_GT.png'))/255;



GTimage = imresize(GTimage,[256 256]);
%PSNR = psnr(out_img, GTimage)
%MSE = immse(out_img, GTimage)

%% Displaying Outputs
figure, imshow(image)
%figure, imshow(dark)
%figure, imshow(M1)
%figure, imshow(M2)
%figure, imshow(IDL,[])
%figure, imshow(tx)
%figure, imshow(dcpoutput)
figure, imshow(adpgamma,[])
figure, imshow(adpcntr,[])
figure, imshow(wghadp,[])
%figure, imshow(Ifu,[]), title('Linear Fusion Image');
%figure, imshow(wfu,[]), title('DWT-based Fusion Image');
figure, imshow(out_img,[]), title('Final Dehazed Image');
figure, imshow(GTimage, []);

warning('on','all');