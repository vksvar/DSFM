function SAV=Wiener_DWT_Filter(Im,wname,Factor,MASKL,MASKH)
%%%  De-noise image using Wiener filter for Low frequency domain
%    and using new equation as a soft-Thresolding for de-noise High-frequenceis domains
%   This apporach is gives better results than (DWT or Wiener) de-noisng 
%   This Method created by Mohammed Mustafa Siddeq
%   Created 2011/10/24
% input to this program :-
%     Im : --> Noise image
%     wname: --> Wavelet family name
%     MASKL : --> Mask filter used for Low-freqeuncy sub-band [3 3] or [5 5] or [7 7].. 
%     MASKH : --> Mask filter used for High-freqeuncy sub-band [3 3] or [5 5] or [7 7]..  
%     Factor:--> this parameter is >=0.001, this parameter is used to
%     decrease or increase Estimated power of a Noise used by the Wiener Filter 
%----------- EXAMPLE ------------------------------------
%  DE_Noise=Wiener_DWT_Filter(Im,'db3',0.1,[5 5],[7 7]);
% the output is Denoised image ..... Good Luck
%---------------------------------------------------------

%%%% old parameters are used in this program , may be yu need it.....
%Original=imread('D:\lectures\images\image1.bmp'); 
%Varin=0.05;
%wname='db5';
%Factor=0.2;
%Im = imnoise(Im,'gaussian',0,Varin); %  Gaussian noise 
%imshow(uint8(Im)),figure,


%%%% Check Number of layers....
S_=size(Im);
S_T=size(S_);
Layer_C=0;
if (S_T(2)==3)
    Layer_C=3;
else
    if (S_T(2)==2) Layer_C=2; end;
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

'Wait ......'
%%%% Process the noisy-image 
for Color_Size=1:Layer_C %% Color layer for bitmap images
Or1(:,:)=Im(:,:,Color_Size);
Or1=double(Or1);
 
  %%%  using two Level DWT  %%%%%%%%%%%%%%%%%%%

  [A,B,C,D]=dwt2(Or1,wname);                     %%%%%%%%%%%%%%%%%%
  [AA,AB,AC,AD]=dwt2(A,wname);                   %%%%%%%%%%%%%%%%%%
 
    
  B=DWT_Shrink(MASKH,B); %% Apply soft-Thresolding %%%%%%%%%%%%%%
  C=DWT_Shrink(MASKH,C); %% Apply soft-Thresolding %%%%%%%%%%%%%%
  D=DWT_Shrink(MASKH,D); %% Apply soft-Thresolding %%%%%%%%%%%%%%
  %---------Second-Level--------------           %%%%%%%%%%%%%%%%%%
  AB=DWT_Shrink(MASKH,AB); %% Apply soft-Thresolding %%%%%%%%%%%%
  AC=DWT_Shrink(MASKH,AC);                     %%%%%%%%%%%%%%%%%% 
  AD=DWT_Shrink(MASKH,AD);                     %%%%%%%%%%%%%%%%%%
  %--------------------------                    %%%%%%%%%%%%%%%%%%
            S=size(AB); T=0; T=AA; AA=0;         %%%%%%%%%%%%%%%%%%
             for i=1:S(1)                        %%%%%%%%%%%%%%%%%%
               for j=1:S(2)                      %%%%%%%%%%%%%%%%%%
                AA(i,j)=T(i,j);                 %%%%%%%%%%%%%%%%%%
               end;                              %%%%%%%%%%%%%%%%%%
             end;                                %%%%%%%%%%%%%%%%%%
  
                       
            [T,NN] = wiener2(AA,MASKL); 
            AA = wiener2(AA,MASKL,NN.*Factor);%%
            A=idwt2(AA,AB,AC,AD,wname); % Apply inverse DWT for 2nd Level% 
         
       S=size(A);S2=size(B);                                    %%%%%%%%%%%%
      %%%%%%%%%%%%%%% check Column %%%%%%%%%%%%%%%
       if (S(1)>S2(1))
         T0=A;A=0;
         A(1:S2(1),1:S(2))=T0(1:S2(1),1:S(2));
       else
        T1=B; T2=C; T3=D; B=0;C=0; D=0;
        B(1:S(1),1:S2(2))=T1(1:S(1),1:S2(2));
        C(1:S(1),1:S2(2))=T2(1:S(1),1:S2(2));
        D(1:S(1),1:S2(2))=T3(1:S(1),1:S2(2));
       end;
       %%%%%%%%%%%%%%%%% Check Row %%%%%%%%%%%%%%%%
       S=size(A);S2=size(B);
       if (S(2)>S2(2))
         T0=A;A=0;
         A(1:S(1),1:S2(2))=T0(1:S(1),1:S2(2));
       else
        T1=B; T2=C; T3=D; B=0;C=0; D=0;
        B(1:S2(1),1:S(2))=T1(1:S2(1),1:S(2));
        C(1:S2(1),1:S(2))=T2(1:S2(1),1:S(2));
        D(1:S2(1),1:S(2))=T3(1:S2(1),1:S(2));
       end;
       
 %  %%%%%Inverse for 1st level DWT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  X=idwt2(A,B,C,D,wname);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   %%% save De-noised image
    SAV(:,:,Color_Size)=X(:,:);
     SAV=double(SAV);
     
end;
imshow(uint8(SAV)); %%% if you need to show the result
'Finished'
end
